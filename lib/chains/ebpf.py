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
import atexit
import ctypes as ct
import logging
import os
import platform
import threading
import time
import weakref
from dataclasses import dataclass, field
from re import MULTILINE, finditer, sub
from threading import RLock
from typing import Callable, ClassVar, Dict, List, Tuple, Union

from bcc import BPF
from bcc.table import QueueStack, TableBase
from pyroute2 import IPRoute
from pyroute2.netlink.exceptions import NetlinkError

from . import exceptions
from .utility import Singleton, get_logger, remove_c_comments

########################################################################
#   #NOTE: generic/SKB (xdpgeneric), native/driver (xdp), and hardware offload (xdpoffload)
#   #define XDP_FLAGS_SKB_MODE      (1U << 1)
#   #define XDP_FLAGS_DRV_MODE      (1U << 2)
#   #define XDP_FLAGS_HW_MODE       (1U << 3)
########################################################################
BPF.TC_ACT_OK = 0
BPF.TC_ACT_SHOT = 2
BPF.TC_REDIRECT = 10
BPF.TC_STRUCT = '__sk_buff'
BPF.XDP_STRUCT = 'xdp_md'
BPF._MAX_PROGRAMS_PER_HOOK = 32


class Metadata(ct.Structure):
    """C struct representing the pkt_metadata structure in Data Plane programs
    Attributes:
        ifindex (c_uint32): The interface on which the packet was received
        ptype (c_uint32): The program type ingress/egress
        probe_id (c_uint64): The ID of the probe
    """

    _fields_ = [("ifindex", ct.c_uint32),
                ("length", ct.c_uint32),
                ("ingress", ct.c_uint8),
                ("xdp", ct.c_uint8),
                ("program_id", ct.c_uint16),
                ("plugin_id", ct.c_uint16),
                ("probe_id", ct.c_uint16)]


@dataclass
class MetricFeatures:
    """Class to represent all the possible features for an Adaptmon metric

    Attributes:
        swap(bool): True if the metric requires swapping programs, False otherwise
        empty(bool): True if the metric needs to be emptied, False otherwise
        export(bool): True if the metric needs to be exported, False otherwise
    """
    swap: bool = False
    empty: bool = False
    export: bool = False


@dataclass
class Program:
    """Program class to handle both useful information and BPF program.

    Attributes:
        interface (str): The interface to attach the program to
        idx (int): The interface's index, retrieved using IPDB
        mode (int): The program mode (XDP or TC)
        flags (int): The flags used for injecting the program.
        code (str): The source code.
        program_id (int): The ID of the program.
        debug (bool): True if the program is compiled with debug info. Default to False.
        cflags (List[str]): List of cflags for the program. Default to [].
        features (Dict[str, MetricFeatures]): The map of features if any. Default {}.
        offload_device (str): Device used for offloading the program. Default to None
        bpf (BPF): The eBPF compiled program
        f (BPF.Function): The function loaded from the program injected in the chain.
    """

    interface: str
    idx: int
    mode: int
    flags: int
    code: str
    program_id: int
    probe_id: int
    plugin_id: int
    debug: bool = False
    cflags: List[str] = field(default_factory=list)
    features: Dict[str, MetricFeatures] = field(default_factory=dict)
    offload_device: str = None

    bpf: BPF = field(init=False)
    f: BPF.Function = field(init=False)

    def __post_init__(self):
        self.bpf: BPF = BPF(text=self.code, debug=self.debug,
                            cflags=self.cflags, device=self.offload_device)
        self.f: BPF.Function = self.bpf.load_func(
            'internal_handler', self.mode, device=self.offload_device)
        atexit.unregister(self.bpf.cleanup)

    def __del__(self):
        """Method to clear resources deployed in the system"""
        # Calling the BCC defined cleanup function which would have been called while exitting
        if not hasattr(self, "bpf"):
            return
        self.bpf.cleanup()
        del self.bpf
        del self.f

    def trigger_read(self):
        pass

    def __getitem__(self, key: str) -> Union[QueueStack, TableBase]:
        """Method to access directly the BPF map providing a key.

        Args:
            key (str): The name of the map.

        Returns:
            Union[QueueStack, TableBase]: The eBPF map requested.
        """
        return self.bpf[key]


@dataclass
class SwapStateCompile(Program):
    """Class storing the state of a program when the SWAP of at least 1 map is required.

    Attributes:
        index (int): The index of the current active program
        _programs (List[Program]): The list containing the two programs compiled.
        chain_map (TableBase): The eBPF table performing the chain.
        program_id (int): The ID of the programs.
        mode (int): The mode used for injecting eBPF programs.
        features (Dict[str, MetricFeatures]): The map of features if any. Default None.
    """
    chain_map: str = None
    code_1: str = None

    bpf_1: BPF = field(init=False)
    f_1: BPF.Function = field(init=False)
    index: int = 0

    def __post_init__(self):
        if not self.chain_map or not self.code_1:
            raise Exception(
                "Unable to build SwapStateConfig without all attributes")
        super().__post_init__()
        self.bpf_1: BPF = BPF(text=self.code_1, debug=self.debug,
                              cflags=self.cflags, device=self.offload_device)
        self.f_1: BPF.Function = self.bpf_1.load_func(
            'internal_handler', self.mode, device=self.offload_device)
        atexit.unregister(self.bpf_1.cleanup)

    def __del__(self):
        """Method to clear resoruces deployed in the system"""
        super().__del__()
        if not hasattr(self, "bpf_1"):
            return
        self.bpf_1.cleanup()
        del self.bpf_1
        del self.f_1

    def trigger_read(self):
        """Method to trigger the read of the maps, meaning to swap in and out the programs"""
        self.index = (self.index + 1) % 2
        self.bpf[self.chain_map][self.program_id -
                                 1] = ct.c_int(self.f.fd if self.index == 0 else self.f_1.fd)

    def __getitem__(self, key: any) -> any:
        """Method to read from a swapped-out program map the value, given the key

        Args:
            key (any): The key to be searched in the map

        Returns:
            any: The value corresponding to the provided key
        """
        index_to_read = int(not self.index)
        if isinstance(key, tuple):
            if bool(key[1]):
                index_to_read = self.index
            key = key[0]

        if index_to_read == 0 or key not in self.features or not self.features[key].swap:
            return self.bpf[key]

        return self.bpf_1["{}_1".format(key)]


@dataclass
class HookTypeHolder:
    """Class to hold current programs and free IDs available for a specific hook of an interface.

    Attributes:
        programs (List[Program]): List of eBPF program injected.
        ids (List[int]): List of available IDs to be used for new programs.
        lock (RLock): Lock for the hook.
    """
    programs: List[Union[SwapStateCompile, Program]
                   ] = field(default_factory=list)
    ids: List[int] = field(default_factory=lambda: list(
        range(1, BPF._MAX_PROGRAMS_PER_HOOK)))

    def __post_init__(self):
        self.lock: RLock = RLock()


@dataclass
class InterfaceHolder:
    """Simple class to store information concerning the programs attached to an interface.

    Attributes:
        name (str): The name of the interface.
        flags (int): The flags used in injection.
        offload_device (str): The name of the device to which offload the program if any.
        ingress_xdp (List[Program]): The list of programs attached to ingress hook in XDP mode.
        ingress_tc (List[Program]): The list of programs attached to ingress hook in TC mode.
        egress_xdp (List[Program]): The list of programs attached to egress hook in XDP mode.
        egress_tc (List[Program]): The list of programs attached to egress hook in TC mode.
    """
    name: str
    flags: int
    offload_device: str
    ingress_xdp: HookTypeHolder = field(
        default_factory=HookTypeHolder)
    ingress_tc: HookTypeHolder = field(
        default_factory=HookTypeHolder)
    egress_xdp: HookTypeHolder = field(
        default_factory=HookTypeHolder)
    egress_tc: HookTypeHolder = field(default_factory=HookTypeHolder)


class EbpfCompiler(metaclass=Singleton):
    """Class (Singleton) to handle eBPF programs compilation, injection, and deletion.

    Static Attributes:
    __logger (logging.Logger): The instance logger.
    __is_batch_supp (bool): True if batch operations are supported. Default to None.
    __base_dir (str): Path to the sourcebpf folder, where there are source eBPF codes.
    __PARENT_INGRESS_TC (str): Address of the parent ingress hook in TC.
    __PARENT_EGRESS_TC (str): Address of the parent egress hook in TC.
    __XDP_MAP_SUFFIX (str): Suffix used for eBPF maps in XDP mode.
    __TC_MAP_SUFFIX (str):Suffix used for eBPF maps in TC mode.
    __EPOCH_BASE (int): Base timestamp to compute UNIX timestamps in eBPF programs.
    __TC_CFLAGS (List[str]): List of cflags to be used in TC mode.
    __XDP_CFLAGS (List[str]): List of cflags to be used in XDP mode.
    __DEFAULT_CFLAGS (List[str]): List of default cflags.

    Attributes:
        __startup (BPF): Startup eBPF program, where logging and control plane buffers are declared.
        __interfaces_programs: Dictionary holding for each interface the list of programs
            and attributes to be used.
    """
    __logger: ClassVar[logging.Logger] = get_logger("EbpfCompiler")
    __is_batch_supp: ClassVar[bool] = None
    __base_dir: ClassVar[str] = os.path.join(
        os.path.dirname(__file__), "sourcebpf")
    __PARENT_INGRESS_TC: ClassVar[str] = 'ffff:fff2'
    __PARENT_EGRESS_TC: ClassVar[str] = 'ffff:fff3'
    __XDP_MAP_SUFFIX: ClassVar[str] = 'xdp'
    __TC_MAP_SUFFIX: ClassVar[str] = 'tc'
    __EPOCH_BASE: ClassVar[int] = int((time.time() - time.monotonic()) * 10**9)

    __TC_CFLAGS: ClassVar[List[str]] = [
        f'-DCTXTYPE={BPF.TC_STRUCT}',
        f'-DPASS={BPF.TC_ACT_OK}',
        f'-DDROP={BPF.TC_ACT_SHOT}',
        f'-DREDIRECT={BPF.TC_REDIRECT}',
        '-DXDP=0']

    __XDP_CFLAGS: ClassVar[List[str]] = [
        f'-DCTXTYPE={BPF.XDP_STRUCT}',
        f'-DBACK_TX={BPF.XDP_TX}',
        f'-DPASS={BPF.XDP_PASS}',
        f'-DDROP={BPF.XDP_DROP}',
        f'-DREDIRECT={BPF.XDP_REDIRECT}',
        '-DXDP=1']

    __DEFAULT_CFLAGS: ClassVar[List[str]] = [
        "-w",
        f'-DMAX_PROGRAMS_PER_HOOK={BPF._MAX_PROGRAMS_PER_HOOK}',
        f'-DEPOCH_BASE={__EPOCH_BASE}'] + [f'-D{x}={y}' for x, y in logging._nameToLevel.items()]

    def __init__(self, log_level: int = logging.INFO, packet_cp_callback: Callable = None, log_cp_callback: Callable = None):
        EbpfCompiler.__logger.setLevel(log_level)
        self.__interfaces_programs: Dict[int, InterfaceHolder] = {}

        try:
            with IPRoute() as ip:
                ip.link("add", ifname="DeChainy", kind="dummy")
        except NetlinkError as e:
            err, _ = e.args
            EbpfCompiler.__logger.error(
                "Either another instance of DeChainy is running, or the previous one has not terminated correctly."
                "In the latter case, try 'sudo ip link del DeChainy', and 'sudo tc qdisc del dev <interface> clsact'"
                "for every interface you used before." if err == 17 else "Need sudo privileges to run.")
            exit(err)

        # Compiling startup program with buffers
        # Variable to store startup code, containing the log buffer perf event map
        with open(os.path.join(EbpfCompiler.__base_dir, "startup.h"), 'r') as fp:
            startup_code = remove_c_comments(fp.read())

        startup: BPF = BPF(text=startup_code)
        atexit.unregister(startup.cleanup)
        if packet_cp_callback:
            startup['control_plane'].open_perf_buffer(
                lambda x, y, z: EbpfCompiler.callback_wrapper(x, y, z, packet_cp_callback))

        if log_cp_callback:
            startup['log_buffer'].open_perf_buffer(
                lambda x, y, z: EbpfCompiler.callback_wrapper(x, y, z, log_cp_callback, log=True))

        # Starting daemon process to poll perf buffers for messages
        if packet_cp_callback or log_cp_callback:
            def poll():
                try:
                    while True:
                        startup.perf_buffer_poll()
                except Exception:
                    pass
            threading.Thread(target=poll, daemon=True).start()
        self._startup = startup
        atexit.register(self.__del__)

    @staticmethod
    def callback_wrapper(cpu, data, size, callback, log=True):
        class Temporary(ct.Structure):
            _fields_ = [("metadata", Metadata),
                        ("raw", ct.c_ubyte * (size - ct.sizeof(Metadata)))] if not log else\
                [("metadata", Metadata),
                 ("level", ct.c_uint64),
                 ("args", ct.c_uint64 * 4),
                 ("message", ct.c_char * (size - (ct.sizeof(ct.c_uint16) * 4) - (ct.sizeof(ct.c_uint64) * 4)))]
        return callback(cpu, ct.cast(data, ct.POINTER(Temporary)).contents, size)

    def __del__(self):
        """Method to clear all the deployed resources from the system"""
        # Remove only once all kind of eBPF programs attached to all interfaces in use.
        if not hasattr(self, "_startup"):
            return
        atexit.unregister(self.__del__)
        with IPRoute() as ip:
            try:
                ip.link("del", ifname="DeChainy")
            except Exception:
                pass
            for idx in list(self.__interfaces_programs.keys()):
                EbpfCompiler.__logger.info('Removing all programs from Interface {}'.format(
                    self.__interfaces_programs[idx].name))
                with self.__interfaces_programs[idx].ingress_xdp.lock, self.__interfaces_programs[idx].egress_xdp.lock:
                    if self.__interfaces_programs[idx].ingress_xdp.programs or \
                            self.__interfaces_programs[idx].egress_xdp.programs:
                        BPF.remove_xdp(
                            self.__interfaces_programs[idx].name, self.__interfaces_programs[idx].flags)
                with self.__interfaces_programs[idx].ingress_tc.lock,\
                        self.__interfaces_programs[idx].egress_tc.lock:
                    if self.__interfaces_programs[idx].ingress_tc.programs or \
                            self.__interfaces_programs[idx].egress_tc.programs:
                        ip.tc("del", "clsact", idx)
                del self.__interfaces_programs[idx]
        self._startup.cleanup()
        del self._startup

    def __inject_pivot(
            self,
            mode: int,
            flags: int,
            offload_device: str,
            interface: str,
            idx: int,
            program_type: str,
            mode_map_name: str,
            parent: str):
        """Method to inject the pivoting program into a specific interface.
        The program chain is setup and ready to accept services.

        Args:
            mode (int): The mode of the program (XDP or TC).
            flags (int): The flags to be used in the mode.
            offload_device (str): The device to which offload the program if any.
            interface (str): The desired interface.
            idx (int): The index of the interface.
            program_type (str): The type of the program (Ingress/Egress).
            mode_map_name (str): The name of the map to use, retrieved from bpf helper function.
        """
        with open(f'{EbpfCompiler.__base_dir}/pivoting.c', 'r') as fp:
            pivoting_code = remove_c_comments(fp.read())\
                .replace('PROGRAM_TYPE', program_type)\
                .replace('MODE', EbpfCompiler.__TC_MAP_SUFFIX if mode == BPF.SCHED_CLS or program_type == "egress"
                         else EbpfCompiler.__XDP_MAP_SUFFIX)

        EbpfCompiler.__logger.info(
            'Compiling Pivot for Interface {} Type {} Mode {}'.format(interface, program_type, mode_map_name))

        # Compiling the eBPF program
        p = Program(interface=interface, idx=idx, mode=mode, code=pivoting_code,
                    cflags=EbpfCompiler.__formatted_cflags(mode, program_type),
                    probe_id=-1, plugin_id=-1, debug=False, flags=flags,
                    program_id=0, offload_device=offload_device)
        target = getattr(
            self.__interfaces_programs[idx], f'{program_type}_{mode_map_name}')
        with target.lock:
            if mode == BPF.XDP:
                BPF.attach_xdp(interface, p.f, flags=flags)
            else:
                with IPRoute() as ip:
                    # Checking if already created the class act for the interface
                    if not getattr(self.__interfaces_programs[idx], f'ingress_{mode_map_name}').programs \
                            and not getattr(self.__interfaces_programs[idx], f'egress_{mode_map_name}').programs:
                        ip.tc("add", "clsact", idx)
                    ip.tc("add-filter", "bpf", idx, ':1', fd=p.f.fd, name=p.f.name,
                          parent=parent, classid=1, direct_action=True)
            target.programs.insert(0, p)

    def remove_hook(self, program_type: str, program: Union[Program, SwapStateCompile]):
        """Method to remove the program associated to a specific hook. The program chain
        is updated by removing the service from the chain itself.

        Args:
            program_type (str): The hook type (ingress/egress).
            program (Union[Program, SwapStateCompile]): The program to be deleted.
        """
        if not program:
            return
        mode_map_name = EbpfCompiler.__TC_MAP_SUFFIX if program.mode == BPF.SCHED_CLS else EbpfCompiler.__XDP_MAP_SUFFIX
        next_map_name = f'{program_type}_next_{mode_map_name}'
        type_of_interest = f'{program_type}_{mode_map_name}'
        target = getattr(
            self.__interfaces_programs[program.idx], type_of_interest)

        with target.lock:
            # Retrieving the index of the Program retrieved
            index = target.programs.index(program)
            EbpfCompiler.__logger.info('Deleting Program {} Interface {} Type {}'.format(
                program.program_id, program.interface, program_type))

            target.ids.append(target.programs[index].program_id)

            # Checking if only two programs left into the interface, meaning
            # that also the pivoting has to be removed
            if len(target.programs) == 2:
                EbpfCompiler.__logger.info('Deleting Also Pivot Program')
                target.programs.clear()
                # Checking if also the class act or the entire XDP program can be removed
                if not getattr(self.__interfaces_programs[program.idx], '{}_{}'.format(
                        "egress" if program_type == "ingress" else "ingress", mode_map_name)).programs:
                    if program.mode == BPF.SCHED_CLS:
                        with IPRoute() as ip:
                            ip.tc("del", "clsact", program.idx)
                    else:
                        BPF.remove_xdp(program.interface, program.flags)
                    del self.__interfaces_programs[program.idx]
                return

            if index + 1 != len(target.programs):
                # The program is not the last one in the list, so
                # modify program CHAIN in order that the previous program calls the
                # following one instead of the one to be removed
                target.programs[0][next_map_name][target.programs[index -
                                                                  1].program_id] = ct.c_int(target.programs[index + 1].f.fd)
                del target.programs[0][next_map_name][program.program_id]
            else:
                # The program is the last one in the list, so set the previous
                # program to call the following one which will be empty
                del target.programs[0][next_map_name][target.programs[index-1].program_id]
            del target.programs[index]

    def patch_hook(self, program_type: str, old_program: Union[Program, SwapStateCompile],
                   new_code: str, new_cflags: List[str], log_level: int = logging.INFO) -> Union[Program, SwapStateCompile]:
        """Method to patch a specific provided program belonging to a certain hook.
        After compiling the new program, if no error are arisen, the old program will be
        completely deleted and substituting with the new one, preserving its position
        in the program chain.

        Args:
            program_type (str): The type of the hook (ingress/egress).
            old_program (Union[Program, SwapStateCompile]): The old program to be replaced.
            new_code (str): The new source code to be compiled.
            new_cflags (List[str]): The new cflags to be used.
            log_level (int, optional): The log level of the program. Defaults to logging.INFO.

        Raises:
            exceptions.UnknownInterfaceException: When the provided program belongs to an
                unknown interface.
            exceptions.ProgramInChainNotFoundException: When the provided program has not
                been found in the chain.

        Returns:
            Union[Program, SwapStateCompile]: The patched program.
        """
        if old_program.idx not in self.__interfaces_programs:
            raise exceptions.UnknownInterfaceException(
                "Interface with index {} unknown.".format(old_program.idx))

        mode_map_name = EbpfCompiler.__XDP_MAP_SUFFIX if old_program.mode == BPF.XDP else EbpfCompiler.__TC_MAP_SUFFIX
        program_chain = getattr(
            self.__interfaces_programs[old_program.idx], f'{program_type}_{mode_map_name}')
        with program_chain.lock:
            index = program_chain.programs.index(old_program)

            if not index:
                raise exceptions.ProgramInChainNotFoundException(
                    "Program {} not found in the chain".format(old_program.program_id))

            EbpfCompiler.__logger.info(
                'Patching Program {} Interface {} Type {} Mode {}'.format(old_program.program_id,
                                                                          old_program.interface,
                                                                          program_type,
                                                                          mode_map_name))

            cflags = new_cflags + EbpfCompiler.__formatted_cflags(old_program.mode, program_type,
                                                                  old_program.program_id, old_program.plugin_id,
                                                                  old_program.probe_id, log_level)

            original_code, swap_code, features = EbpfCompiler.__precompile_parse(
                EbpfCompiler.__format_for_hook(
                    old_program.mode, program_type, EbpfCompiler.__format_helpers(new_code)),
                cflags)

            # Loading compiled "internal_handler" function and set the previous
            # plugin program to call in the CHAIN to the current function descriptor
            ret = Program(interface=old_program.interface, idx=old_program.idx, mode=old_program.mode,
                          flags=old_program.flags, offload_device=old_program.offload_device,
                          cflags=cflags, debug=old_program.debug, code=original_code,
                          program_id=old_program.program_id, plugin_id=old_program.plugin_id,
                          probe_id=old_program.probe_id, features=features)

            # Updating Service Chain
            program_chain.programs[0][f'{program_type}_next_{mode_map_name}'][
                program_chain.programs[index-1].program_id] = ct.c_int(ret.f.fd)

            # Compiling swap program if needed
            if swap_code:
                EbpfCompiler.__logger.info('Compiling Also Swap Code')
                p1 = Program(interface=old_program.interface, idx=old_program.idx, mode=old_program.mode,
                             flags=old_program.flags, code=swap_code, debug=old_program.debug,
                             cflags=cflags, offload_device=old_program.offload_device,
                             program_id=old_program.program_id, plugin_id=old_program.plugin_id,
                             probe_id=old_program.probe_id, features=features)
                ret = SwapStateCompile(
                    ret, p1, f'{program_type}_next_{mode_map_name}')
            # Append the main program to the list of programs
            program_chain.programs[index] = ret
            del old_program
            return weakref.ref(ret)

    def compile_hook(self, program_type: str,
                     code: str, interface: str,
                     mode: int, flags: int,
                     cflags: List[str], debug: bool,
                     plugin_id: int, probe_id: int,
                     log_level: int) -> Union[Program, SwapStateCompile]:
        """Method to compile program for a specific hook of an interface. If the compilation
        succeeded, then the program chain is updated with the new service.

        Args:
            program_type (str): The hook type (ingress/egress).
            code (str): The program source code.
            interface (str): The interface to which attach the compiled program.
            mode (int): The mode used for injecting the program.
            flags (int): The flags used by the mode when injecting the program.
            cflags (List[str]): The cflags for the program.
            debug (bool): True if the program has to be compiled with debug info.
            plugin_id (int): The id of the plugin.
            probe_id (int): The id of the probe.
            log_level (int): The loggin level.

        Raises:
            exceptions.UnknownInterfaceException: When the interface does not exist.

        Returns:
            Union[Program, SwapStateCompile]: The compiled program.
        """

        try:
            with IPRoute() as ip:
                idx = ip.link_lookup(ifname=interface)[0]
        except IndexError:
            raise exceptions.UnknownInterfaceException(
                'Interface {} not available'.format(interface))

        # Retrieve eBPF values given Mode and program type
        mode, flags, offload_device, mode_map_name, parent = EbpfCompiler.__ebpf_values(
            mode, flags, interface, program_type)

        # Checking if the interface has already been used so there's already
        # Holder structure
        if idx not in self.__interfaces_programs:
            self.__interfaces_programs[idx] = InterfaceHolder(
                interface, flags, offload_device)
        elif program_type == "ingress":
            flags, offload_device = self.__interfaces_programs[
                idx].flags, self.__interfaces_programs[idx].offload_device

        program_chain = getattr(
            self.__interfaces_programs[idx], f'{program_type}_{mode_map_name}')
        with program_chain.lock:
            # If the array representing the hook is empty, inject the pivot code
            if not program_chain.programs:
                self.__inject_pivot(mode, flags, offload_device,
                                    interface, idx, program_type, mode_map_name, parent)
            program_id = program_chain.ids.pop(0)
            EbpfCompiler.__logger.info(
                'Compiling Program {} Interface {} Type {} Mode {}'.format(program_id, interface, program_type, mode_map_name))

            cflags = cflags + EbpfCompiler.__formatted_cflags(
                mode, program_type, program_id, plugin_id, probe_id, log_level)

            original_code, swap_code, features = EbpfCompiler.__precompile_parse(
                EbpfCompiler.__format_for_hook(mode, program_type, EbpfCompiler.__format_helpers(code)), cflags)

            if swap_code:
                EbpfCompiler.__logger.info('Compiling Also Swap Code')
                ret = SwapStateCompile(interface=interface, idx=idx, mode=mode, flags=flags, offload_device=offload_device,
                                       cflags=cflags, debug=debug, code=original_code, program_id=program_id,
                                       plugin_id=plugin_id, probe_id=probe_id, features=features,
                                       chain_map=f'{program_type}_next_{mode_map_name}', code_1=swap_code)
            else:
                ret = Program(interface=interface, idx=idx, mode=mode, flags=flags, offload_device=offload_device,
                              cflags=cflags, debug=debug, code=original_code, program_id=program_id,
                              plugin_id=plugin_id, probe_id=probe_id, features=features)

            # Updating Service Chain
            program_chain.programs[0][f'{program_type}_next_{mode_map_name}'][
                program_chain.programs[-1].program_id] = ct.c_int(ret.f.fd)

            # Append the main program to the list of programs
            program_chain.programs.append(ret)
            return weakref.ref(ret)

    @staticmethod
    def __formatted_cflags(
            mode: int,
            program_type: str,
            program_id: int = 0,
            plugin_id: int = 0,
            probe_id: int = 0,
            log_level: int = logging.INFO) -> List[str]:
        """Static method to return CFLAGS according to hook and mode.

        Args:
            mode (int): The program mode (XDP or TC).
            program_type (str): The hook of the program (ingress/egress).
            program_id (int, optional): The ID of the program to be created. Defaults to 0.
            plugin_id (int, optional): The ID of the plugin. Defaults to 0.
            probe_id (int, optional): The ID of the probe within the plugin. Defaults to 0.
            log_level (int, optional): The Log Level of the probe. Defaults to logging.INFO.

        Returns:
            List[str]: The list of computed cflags.
        """
        return EbpfCompiler.__DEFAULT_CFLAGS + \
            (EbpfCompiler.__TC_CFLAGS if mode == BPF.SCHED_CLS else EbpfCompiler.__XDP_CFLAGS) + \
            [f'-DPROGRAM_ID={program_id}', f'-DPLUGIN_ID={plugin_id}',
             f'-DINGRESS={1 if program_type == "ingress" else 0}',
             f'-DPROBE_ID={probe_id}', f'-DLOG_LEVEL={log_level}']

    @staticmethod
    def __ebpf_values(mode: int, flags: int, interface: str, program_type: str) -> Tuple[int, int, str, str, str]:
        """Static method to return BPF map values according to the hook and mode used.

        Args:
            mode (int): The program mode (XDP or TC).
            flags (int): Flags to be used in the mode.
            interface (str): The interface to which attach the program.
            program_type (str): The program hook (ingress/egress).

        Returns:
            Tuple[int, int, str str, str]: The values representing the mode, the suffix for maps names and parent interface.
        """
        if program_type == "egress":
            return BPF.SCHED_CLS, 0, None, EbpfCompiler.__TC_MAP_SUFFIX, EbpfCompiler.__PARENT_EGRESS_TC
        if mode == BPF.SCHED_CLS:
            return BPF.SCHED_CLS, 0, None, EbpfCompiler.__TC_MAP_SUFFIX, EbpfCompiler.__PARENT_INGRESS_TC
        elif mode == BPF.XDP:
            return BPF.XDP, flags, (interface if flags == BPF.XDP_FLAGS_HW_MODE else None), EbpfCompiler.__XDP_MAP_SUFFIX, None
        else:
            raise Exception("Unknown mode {}".format(mode))

    @staticmethod
    def __precompile_parse(original_code: str, cflags: List[str]) -> Tuple[str, str, Dict[str, MetricFeatures]]:
        """Static method to compile additional functionalities from original code (swap, erase, and more)

        Args:
            original_code (str): The original code to be controlled.
            cflags (List[str]): The list of cflags to be applied.

        Returns:
            Tuple[str, str, Dict[str, MetricFeatures]]: Only the original code if no swaps maps,
                else the tuple containing also swap code and list of metrics configuration.
        """
        # Find map declarations, from the end to the beginning
        declarations = [(m.start(), m.end(), m.group()) for m in finditer(
            r"^(BPF_TABLE|BPF_QUEUESTACK|BPF_PERF).*$", original_code, flags=MULTILINE)]
        declarations.reverse()

        if not any(x for _, _, x in declarations if "__attributes__" in x):
            return original_code, None, {}

        tmp_code = sub("__attributes__.*", ";", original_code, flags=MULTILINE)
        b = BPF(text=tmp_code, cflags=cflags)

        # Check if at least one map needs swap
        need_swap = False
        active_declarations = []
        maps = {}

        for start, end, declaration in declarations:
            splitted = declaration.split(',')
            map_name = splitted[1].split(")")[0].strip() if (
                "BPF_Q" in declaration or "BPF_P" in declaration) else splitted[3].split(")")[0].strip()
            try:
                b[map_name]
                maps[map_name] = MetricFeatures(
                    swap=False, export=False, empty=False)
            except Exception:
                continue

            active_declarations.append((start, end, declaration))
            if "__attributes__" in declaration and "SWAP" in declaration:
                need_swap = True
        b.cleanup()
        del b

        cloned_code = original_code if need_swap else None
        for start, end, declaration in active_declarations:
            new_decl, splitted = declaration, declaration.split(',')
            map_name = splitted[1].split(")")[0].strip() if (
                "BPF_Q" in declaration or "BPF_P" in declaration) else splitted[3].split(")")[0].strip()

            # Check if this declaration has some attribute
            if "__attributes__" in declaration:
                tmp = declaration.split("__attributes__")
                new_decl = tmp[0] + ";"
                maps[map_name].swap = "SWAP" in tmp[1]
                maps[map_name].export = "EXPORT" in tmp[1]
                maps[map_name].empty = "EMPTY" in tmp[1]

            orig_decl = new_decl

            # If need swap and this map doesn't, then perform changes in declaration
            if need_swap and (map_name not in maps or not maps[map_name].swap):
                tmp = splitted[0].split('(')
                prefix_decl = tmp[0]
                map_type = tmp[1]
                if prefix_decl.count("_") <= 1:
                    if "extern" not in map_type:
                        new_decl = new_decl.replace(map_type, '"extern"')
                        index = len(prefix_decl)
                        orig_decl = orig_decl[:index] + \
                            "_SHARED" + orig_decl[index:]
                else:
                    new_decl = new_decl.replace(map_type, '"extern"').replace(
                        prefix_decl, '_'.join(prefix_decl.split("_")[:2]))
            original_code = original_code[:start] + \
                orig_decl + original_code[end:]
            if cloned_code:
                cloned_code = cloned_code[:start] + \
                    new_decl + cloned_code[end:]

        for map_name, features in maps.items():
            if features.swap:
                cloned_code = cloned_code.replace(map_name, f"{map_name}_1")
        return original_code, cloned_code, maps

    @staticmethod
    def __format_for_hook(
            mode: int,
            program_type: str,
            code: str) -> str:
        """Static method to format the code accordingly to the hook and the mode

        Args:
            mode (int): The program mode (XDP or TC).
            program_type (str): The program hook (ingress/egress).
            code (str, optional): The code to be formatted.

        Returns:
            str: The code correctly formatted.
        """
        return code.replace('PROGRAM_TYPE', program_type)\
            .replace('MODE', EbpfCompiler.__TC_MAP_SUFFIX if mode == BPF.SCHED_CLS or program_type == "egress"
                     else EbpfCompiler.__XDP_MAP_SUFFIX)

    @staticmethod
    def __format_helpers(code: str) -> str:
        """Static method to format the original program code with
        helpers provided by the framework (e.g., dp_log, REDIRECT(<interface>)).

        Args:
            code (str): The original code to format.

        Raises:
            exceptions.UnknownInterfaceException: When the redirect interface is not recognized.

        Returns:
            str: The code correctly formatted.
        """
        # Removing C-like comments
        code = remove_c_comments(code)

        declarations = [(m.start(), m.end(), m.group(1)) for m in finditer(
            r"return REDIRECT\((.*)\);.*$", code, MULTILINE)]
        declarations.reverse()

        # sub REDIRECT <interface> with proper code
        with IPRoute() as ip:
            for start, end, declaration in declarations:
                try:
                    idx = ip.link_lookup(ifname=declaration)[0]
                    code = code[:start] + 'u32 index = {}; return bpf_redirect(&index, 0);'.format(
                        idx) + code[end:]
                except IndexError:
                    raise exceptions.UnknownInterfaceException(
                        f'Interface {declaration} not available')

        # Finding dp_log function invocations if any, and reverse to avoid bad
        # indexes while updating
        matches = [(m.start(), m.end()) for m in finditer('dp_log.*;', code)]
        matches.reverse()
        for start, end in matches:
            # Getting the log level specified
            log_level = code[start + 7: end].split(",")[0]
            # Substitute the dp_log invocation (length 6 characters) with the right
            # logging function
            code = code[:start] \
                + f'if ({log_level} <= LOG_LEVEL)' \
                + '{LOG_STRUCT' \
                + code[start + 6:end] \
                + 'log_buffer.perf_submit(ctx, &msg_struct, sizeof(msg_struct));}' \
                + code[end:]
        with open(f'{EbpfCompiler.__base_dir}/helpers.h', 'r') as fp,\
                open(f'{EbpfCompiler.__base_dir}/wrapper.c', 'r') as fp1:
            helpers_code = remove_c_comments(fp.read())
            wrapper_code = remove_c_comments(fp1.read())
        return helpers_code + wrapper_code + code

    @staticmethod
    def is_batch_supp() -> bool:
        """Static method to check whether the batch operations are supported for this system (kernel >= v5.6).

        Returns:
            bool: True if they are supported, else otherwise.
        """
        if EbpfCompiler.__is_batch_supp is None:
            release = platform.release()
            if not release:
                EbpfCompiler.__is_batch_supp = False
            major, minor = [int(x) for x in release.split('.')[:2]]
            EbpfCompiler.__is_batch_supp = True if major > 5 or (
                major == 5 and minor >= 6) else False
        return EbpfCompiler.__is_batch_supp
