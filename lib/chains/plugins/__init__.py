# Copyright 2022 DeChainers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import ctypes as ct
import logging
import os
import weakref
from dataclasses import dataclass, field
from typing import List, Type, Union

from bcc import XDPFlags
from bcc.table import ArrayBase, QueueStack, TableBase

from ..ebpf import BPF, EbpfCompiler, MetricFeatures, Program, SwapStateCompile
from ..exceptions import (HookDisabledException, MetricUnspecifiedException,
                          NoCodeProbeException)
from ..utility import ctype_to_normal, get_logger


@dataclass
class HookSetting:
    """Class to represent the configuration of a hook (ingress/egress)

    Attributes:
        required (bool): True if the hook is required for compilation. Default to False
        cflags (List[str]): List of cflags to be used when compiling eBPF programs. Default to [].
        code (str): The source code program. Default to None.
    """
    required: bool = False
    cflags: List[str] = field(default_factory=list)
    code: str = None
    program_ref: Type[weakref.ReferenceType] = lambda: None


@dataclass
class Probe:
    """Class to represent a base probe and deliver common functionalities to
    further developed probes.

    Attributes:
        name (str): The name of the Probe.
        interface (str): The interface to which attach the programs.
        mode (int): The mode of inserting the programs. Default to BPF.SCHED_CLS.
        flags (int): The flags to be used if BPF.XDP mode. Default to XDPFlags.SKB_MODE.
        ingress (HookSetting): The configuration of the ingress hook. Default to HookSetting().
        ingress (HookSetting): The configuration of the egress hook. Default to HookSetting().
        debug (bool): True if the programs should be compiled in debug mode. Default to False.
        log_level (Union[str, int]): The level of logging to be used. Default to logging.INFO.
        flags (int): Flags used to inject eBPF program when in XDP mode, later inferred. Default to 0.
        _logger (logging.Logger): The probe logger.
    Raises:
        NoCodeProbeException: When the probe does not have either ingress nor egress code.
    """
    name: str
    interface: str
    plugin_id: int
    probe_id: int
    mode: int = BPF.SCHED_CLS
    flags: int = XDPFlags.SKB_MODE
    ingress: HookSetting = field(default_factory=HookSetting)
    egress: HookSetting = field(default_factory=HookSetting)
    debug: bool = False
    log_level: Union[str, int] = logging.INFO

    def __post_init__(self, path=__file__):
        if isinstance(self.log_level, str):
            self.log_level = logging._nameToLevel[self.log_level]
        self._logger: logging.Logger = get_logger(
            f"{self.name}{self.probe_id}", log_level=self.log_level)

        if not self.ingress.required and not self.egress.required:
            raise NoCodeProbeException(
                "No Ingress/Egress hook specified for the probe {}".format(self.name))

        for ttype in ["ingress", "egress"]:
            hook: HookSetting = getattr(self, ttype)
            hook.code = None
            if not hook.required:
                continue
            tmp = os.path.join(os.path.dirname(path), "{}.c".format(ttype))
            if not os.path.isfile(tmp):
                tmp = os.path.join(os.path.dirname(path), "ebpf.c")
            if os.path.isfile(tmp):
                with open(tmp, "r") as fp:
                    hook.code = fp.read()
            if not hook.code:
                raise NoCodeProbeException(
                    "No code for hook {} for the probe {}".format(ttype, self.name))

            hook.program_ref = EbpfCompiler().compile_hook(
                ttype, hook.code, self.interface, self.mode,
                self.flags, hook.cflags + self.additional_cflags(), self.debug, self.plugin_id,
                self.probe_id, self.log_level)

    def __del__(self):
        """Method to clear all resources associated to the probe, including
        eBPF program and logger."""
        if not hasattr(self, "_logger"):
            return
        self._logger.manager.loggerDict.pop(self._logger.name)
        del self._logger
        for ttype in ["ingress", "egress"]:
            EbpfCompiler().remove_hook(ttype, getattr(self, ttype).program_ref())
        del self.ingress
        del self.egress

    def __getitem__(self, key: str) -> Union[str, Program]:
        """Method to access directly Programs in the class

        Args:
            key (str): The key to search into the Programs dictionary

        Returns:
            Union[str, Program]: the compiled Program
        """
        return getattr(self, key.lower()).program_ref()

    @property
    def plugin_name(self) -> str:
        """Property to return the name of the plugin.

        Returns:
            str: The name of the plugin.
        """
        return self.__class__.__name__.lower()

    def handle_packet_cp(self, event: Type[ct.Structure], cpu: int):
        """Method to handle a packet received from the apposite data plane code
        and forwarded from the Controller. Probes that wants to send packets
        to the userspace must override and implement this method

        Args:
            metadata (Metadata): The Metadata retrieved from the probe.
            log_level (int): Log Level to be used.
            message (ct.Array): The message as a ctype.
            args (ct.Array): The list of arguments used to format the message.
            cpu (int): The number of the CPU handling the message.
        """
        self._logger.info(f'Received Packet to handle from CPU {cpu}')

    def log_message(self, event: Type[ct.Structure], cpu: int):
        """Method to log a message received from the apposite data plane code and
        forwarded from the Controller.

        Args:
            metadata (Metadata): The Metadata retrieved from the probe.
            log_level (int): Log Level to be used.
            message (ct.Array): The message as a ctype.
            args (ct.Array): The list of arguments used to format the message.
            cpu (int): The number of the CPU handling the message.
        """
        decoded_message = event.message.decode()
        args = tuple([event.args[i]
                      for i in range(0, decoded_message.count('%'))])
        formatted = decoded_message % args
        self._logger.log(event.level, 'Message from CPU={}, Hook={}, Mode={}: {}'.format(
            cpu,
            "ingress" if event.metadata.ingress else "egress",
            "xdp" if event.metadata.xdp else "TC",
            formatted
        ))

    @staticmethod
    def __do_retrieve_metric(map_ref: Union[QueueStack, TableBase], features: MetricFeatures) -> any:
        """Method internally used to retrieve data from the underlying eBPF map.

        Args:
            map_ref (Union[QueueStack, TableBase]): The reference to the eBPF map.
            features (MetricFeatures): The features associated to the map.

        Returns:
            any: The list of values if multiple ones, or just the first one if it is the only one
        """
        ret = []
        if isinstance(map_ref, QueueStack):
            ret = [ctype_to_normal(x) for x in map_ref.values()]
        elif isinstance(map_ref, ArrayBase):
            ret = [ctype_to_normal(v) for _, v in map_ref.items_lookup_batch(
            )] if EbpfCompiler.is_batch_supp() else [ctype_to_normal(v) for v in map_ref.values()]
            if features.empty:
                length = len(ret)
                keys = (map_ref.Key * length)()
                new_values = (map_ref.Leaf * length)()
                holder = map_ref.Leaf()
                for i in range(length):
                    keys[i] = ct.c_int(i)
                    new_values[i] = holder
                map_ref.items_update_batch(keys, new_values)
        else:
            exception = False
            if EbpfCompiler.is_batch_supp()():
                try:
                    for k, v in map_ref.items_lookup_and_delete_batch() if features.empty else map_ref.items_lookup_batch():
                        ret.append((ctype_to_normal(k), ctype_to_normal(v)))
                except Exception:
                    exception = True
            if not ret and exception:
                for k, v in map_ref.items():
                    ret.append((ctype_to_normal(k), ctype_to_normal(v)))
                    if features.empty:
                        del map_ref[k]
        return ret

    def retrieve_metric(self, program_type: str, metric_name: str = None) -> any:
        """Method to retrieve metrics from a hook, if any. If also the name is provided, then
        only the requested metric is returned.

        Args:
            program_type (str): The program type (Ingress/Egress).
            metric_name (str): The name of the metric.

        Raises:
            HookDisabledException: When there is no program attached to the hook.
            MetricUnspecifiedException: When the requested metric does not exist

        Returns:
            any: The value of the metric.
        """
        if not getattr(self, program_type):
            raise HookDisabledException(
                f"The hook {program_type} is not active for this probe")
        phook: HookSetting = getattr(self, program_type).program_ref()

        if isinstance(phook, SwapStateCompile):
            phook.trigger_read()

        if metric_name:
            if metric_name not in phook.features or not phook.features[metric_name].export:
                raise MetricUnspecifiedException(
                    f"Metric {metric_name} unspecified")
            return self.__do_retrieve_metric(phook[metric_name], phook.features[metric_name])
        ret = {}
        for map_name, features in phook.features.items():
            if not features.export:
                continue
            ret[map_name] = self.__do_retrieve_metric(
                phook[map_name], features)
        return ret

    def patch_hook(self, program_type: str, new_code: str = None, new_cflags: List[str] = []):
        """Method to patch the code of a specific hook of the probe.

        Args:
            program_type (str): The hook to be patched
            new_code (str): The new code to be used. Default None.
            new_cflags (List[str]): The new cflags to be used. Default [].
        """
        if not new_code and not new_cflags:
            self._logger.info("No difference, skipping patch.")
        hook_ref: HookSetting = getattr(self, program_type)
        hook_ref.code = new_code or hook_ref.code
        hook_ref.cflags = new_cflags or hook_ref.cflags
        hook_ref.program_ref = EbpfCompiler().patch_hook(
            program_type, hook_ref.program_ref(),
            hook_ref.code, hook_ref.cflags + self.additional_cflags(), self.log_level)

    def additional_cflags(self) -> List[str]:
        """Method to include additional cflags programmed ad-hoc for the plugin.

        Returns:
            List[str]: List of the additional cflags.
        """
        return []
