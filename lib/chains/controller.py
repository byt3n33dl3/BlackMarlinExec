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
import dataclasses
import itertools
import logging
import os
import shutil
from importlib import import_module
from threading import RLock
from types import ModuleType
from typing import Dict, List, OrderedDict, Type, Union

from watchdog.events import (DirCreatedEvent, DirDeletedEvent, FileSystemEvent,
                             FileSystemEventHandler)
from watchdog.observers import Observer

from . import base_url, exceptions
from .ebpf import EbpfCompiler
from .plugins import Probe
from .utility import Singleton, get_logger


class SyncPluginsHandler(FileSystemEventHandler):
    """Watchdog class for file system modification to plugins and
    synchronization with the current deployed resources.
    If a plugin is removed from the directory, this component
    automatically removes all the probes of that plugin for
    coherency."""

    def on_created(self, event: FileSystemEvent):
        """Method to be called when a directory in the plugin
        folder is created, whether it is a legitimate plugin
        or not. If not already checked, this methods forces
        the Controller to check the newly created Plugin validity.

        Args:
            event (FileSystemEvent): The base event.
        """
        if not isinstance(event, DirCreatedEvent):
            return
        plugin_name = os.path.basename(event.src_path)
        if not plugin_name[0].isalpha():
            return
        with Controller._plugins_lock:
            try:
                Controller.check_plugin_validity(plugin_name)
                Controller._logger.info(
                    "Watchdog check for Plugin {} creation".format(plugin_name))
            except Exception:
                pass

    def on_deleted(self, event: FileSystemEvent):
        """Function to be called everytime a directory is removed
        from the plugin folder, whether it is a legitimate plugin or
        not. This method enforces the Controller to check whether there
        are probes of that plugin deployed, and in case remove them.

        Args:
            event (FileSystemEvent): The base event
        """
        if not isinstance(event, DirDeletedEvent):
            return
        plugin_name = os.path.basename(event.src_path)
        if not plugin_name[0].isalpha():
            return
        if Controller not in Singleton._instances:
            return
        Controller().sync_plugin_probes(plugin_name)
        Controller._logger.info(
            "Watchdog check for Plugin {} removal".format(plugin_name))


class Controller(metaclass=Singleton):
    """Class (Singleton) for managing deployed and available resources.

    Static Attributes:
        _plugins_lock(RLock): The mutex for the plugins.
        _logger (Logger): The class logger.

    Attributes:
        __probes (Dict[str, Dict[str, Type[Probe]]]): A dictionary containing, for each plugin,
            an inner dictionary holding the dictionary of the current deployed probes.
        __observer (Observer): Watchdog thread to keep this instance synchronised with
            the plugin directory.
        __compiler (EbpfCompiler): An instance of the eBPF programs compiler, to prevent
            it to be destroyed in the mean time.
    """
    _plugins_lock: RLock = RLock()
    _logger: logging.Logger = get_logger("Controller")

    _observer = Observer()
    _observer.daemon = True
    _observer.schedule(SyncPluginsHandler(), os.path.join(
        os.path.dirname(__file__), "plugins"), recursive=True)
    _observer.start()

    def __init__(self, log_level=logging.INFO):
        Controller._logger.setLevel(log_level)
        self.__probes_lock: RLock = RLock()
        self.__probes: OrderedDict[str, Dict[str, Probe]] = {}
        self.__compiler = EbpfCompiler(log_level=log_level,
                                       packet_cp_callback=lambda x, y, z: Controller()._packet_cp_callback(x, y, z),
                                       log_cp_callback=lambda x, y, z: Controller()._log_cp_callback(x, y, z))

    def __del__(self):
        """Method to clear all the deployed resources."""
        with self.__probes_lock:
            del self.__probes
        del self.__compiler

    def _packet_cp_callback(self, cpu: int, event: Type[ct.Structure], size: int):
        """Method to forward the packet received from the data plane to the
        apposite Probe in order to be handled.

        Args:
            cpu (int): The CPU which registered the packet
            event (Type[ct.Structure]): The event structure automatically converted
            size (int): The size of the entire metadata and packet
        """
        try:
            plugin_name = next(itertools.islice(
                self.__probes.keys(), event.metadata.plugin_id, None))
            probe_name = next(itertools.islice(
                self.__probes[plugin_name].keys(), event.metadata.probe_id, None))
        except Exception:
            return
        self.__probes[plugin_name][probe_name].handle_packet_cp(event, cpu)

    def _log_cp_callback(self,
                         cpu: int,
                         msg_struct: ct.Structure,
                         size: int):
        """Method to forward the message received from the data plane
        to the apposite Probe in order to be logged.

        Args:
            cpu (int): The CPU which has registered the message.
            msg_struct (ct.Structure): The converted structure according to
                the one declared in ebpf.py and helpers.h
            size (int): The size of the entire message.
        """
        try:
            plugin_name = next(itertools.islice(
                self.__probes.keys(), msg_struct.metadata.plugin_id, None))
            probe_name = next(itertools.islice(
                self.__probes[plugin_name].keys(), msg_struct.metadata.probe_id, None))
        except Exception:
            return
        self.__probes[plugin_name][probe_name].log_message(msg_struct, cpu)

    #####################################################################
    # ---------------- Function to manage plugins --------------------- #
    #####################################################################

    @staticmethod
    def __check_plugin_exists(plugin_name: str, is_creating: bool = False, update: bool = False):
        """Static Internal method to check whether a plugin exists or can be created.

        Args:
            plugin_name (str): The name of the plugin.
            is_creating (bool, optional): Variable to specify that the plugin needs to be
                created soon. Defaults to False.
            update (bool, optional): Variable to specify that the plugin needs to be
                updated soon. Defaults to False.

        Raises:
            exceptions.PluginNotFoundException: When the given plugin does not exist.
            exceptions.PluginAlreadyExistsException: When the given plugin already exist.
        """
        target = os.path.join(os.path.dirname(
            __file__), "plugins", plugin_name)
        if not is_creating and not os.path.isdir(target):
            raise exceptions.PluginNotFoundException(
                "Plugin {} not found".format(plugin_name))
        if is_creating and os.path.isdir(target):
            if not update:
                raise exceptions.PluginAlreadyExistsException(
                    "Plugin {} already exists".format(plugin_name))
            else:
                shutil.rmtree(target)

    @staticmethod
    def check_plugin_validity(plugin_name: str):
        """Static method to check the validity of a plugin. Validity conditions are:
        1. in the __init__.py there is a class representing the plugin with the
            capitalized name of the plugin (e.g., johndoe -> Johndoe);
        2. such class needs to extend the superclass Probe;
        3. such class needs to be a dataclass.

        Args:
            plugin_name (str, optional): The name of the plugin.

        Raises:
            exceptions.InvalidPluginException: When one of the validity condition
                is violated.
        """
        with Controller._plugins_lock:
            plugin = Controller.get_plugin(plugin_name)
            cls = getattr(plugin, plugin_name.capitalize(), None)
            if not cls or not issubclass(cls, Probe) or not dataclasses.is_dataclass(cls)\
                    or not any(x in ["ebpf.c", "ingress.c", "egress.c"] or '.c' in x for x in
                               os.listdir(os.path.join(os.path.dirname(__file__), "plugins", plugin_name))):
                Controller.delete_plugin(plugin_name)
                raise exceptions.InvalidPluginException(
                    "Plugin {} is not valid".format(plugin_name))

    @staticmethod
    def get_plugin(plugin_name: str = None) -> Union[ModuleType, List[ModuleType]]:
        """Static method to return the Module of the requested plugin. If the name
        is not provided, then all the available plugins are loaded and returned.

        Args:
            plugin_name (str, optional): The name of the plugin. Defaults to None.

        Returns:
            Union[ModuleType, List[ModuleType]]: The list of loaded modules or the
                target one.
        """
        with Controller._plugins_lock:
            target_dir = os.path.join(os.path.dirname(__file__), "plugins")
            if not plugin_name:
                return [x for x in os.listdir(target_dir)
                        if os.path.isdir(os.path.join(target_dir, x)) and x[0].isalpha()]
            Controller.__check_plugin_exists(plugin_name)
            return import_module("{}.plugins.{}".format(__package__, plugin_name))

    @staticmethod
    def __download_from_remote_git(dest_path: str, plugin_name: str, git_url: str = None):
        if not git_url:
            git_url = "{}/{}.git".format(base_url, plugin_name)
        os.system("""
            git init {dest_path};
            cd {dest_path};
            git remote add origin {git_url};
            git config core.sparsecheckout true;
            echo "{plugin_name}/*" > .git/info/sparse-checkout;
            git pull origin master;
            rm -rf .git;
            """.format(dest_path=dest_path, git_url=git_url, plugin_name=plugin_name))

    @staticmethod
    def create_plugin(variable: str, update: bool = False):
        """Static method to create a plugin. Different types are supported:
        1. local directory: path to a local plugin directory;
        2. remote custom: URL to the remote repository containing the plugin to pull;
        3. remote default: the plugin is pulled from the default dechainy_plugin_<name> repo.

        Raises:
            exceptions.UnknownPluginFormatException: When none of the above formats is provided.
        """
        dest_path = os.path.join(os.path.dirname(__file__), "plugins")
        plugin_name = None
        try:
            with Controller._plugins_lock:
                if os.path.isdir(variable):  # take from local path
                    plugin_name = os.path.basename(variable)
                    Controller.__check_plugin_exists(
                        plugin_name, is_creating=True, update=update)
                    try:
                        shutil.copytree(variable, os.path.join(
                            dest_path, plugin_name))
                    except Exception as e:
                        raise exceptions.UnknownPluginFormatException(e)
                # download from remote custom
                elif any(variable.startswith(s) for s in ['http:', 'https:']):
                    if not variable.endswith(".git"):
                        raise exceptions.UnknownPluginFormatException(
                            "Not git repo, download the plugin and install it by your own please")
                    plugin_name = variable.split("/")[-1][:-4]
                    Controller.__check_plugin_exists(
                        plugin_name, is_creating=True, update=update)
                    try:
                        Controller.__download_from_remote_git(
                            dest_path=dest_path, plugin_name=plugin_name, git_url=variable)
                    except Exception as e:
                        raise exceptions.UnknownPluginFormatException(e)
                # download from remote default
                elif ''.join(ch for ch in variable if ch.isalnum()) == variable:
                    plugin_name = variable
                    Controller.__check_plugin_exists(
                        plugin_name, is_creating=True, update=update)
                    try:
                        Controller.__download_from_remote_git(
                            dest_path=dest_path, plugin_name=plugin_name)
                    except Exception as e:
                        raise exceptions.UnknownPluginFormatException(e)
                else:
                    raise exceptions.UnknownPluginFormatException(
                        "Unable to handle input {}".format(variable))
                Controller.check_plugin_validity(plugin_name)
        except Exception as e:
            if plugin_name and os.path.isdir(os.path.join(dest_path, plugin_name)):
                shutil.rmtree(os.path.join(dest_path, plugin_name))
            raise e
        Controller._logger.info("Created Plugin {}".format(plugin_name))

    @staticmethod
    def delete_plugin(plugin_name: str = None):
        """Static method to delete a plugin. If the name is not specified,
        then all the plugins are deleted.

        Args:
            plugin_name (str, optional): The name of the plugin. Defaults to None.

        Raises:
            exceptions.PluginNotFoundException: When the plugin does not exist.
        """
        with Controller._plugins_lock:
            if plugin_name:
                Controller.__check_plugin_exists(plugin_name)
                shutil.rmtree(os.path.join(os.path.dirname(
                    __file__), "plugins", plugin_name))
            else:
                for plugin_name in Controller.get_plugin():
                    shutil.rmtree(os.path.join(os.path.dirname(
                        __file__), "plugins", plugin_name))
        Controller._logger.info("Deleted Plugin {}".format(plugin_name))

    #####################################################################
    # ------------------ Function to manage probes -------------------- #
    #####################################################################

    def delete_probe(self, plugin_name: str = None, probe_name: str = None):
        """Method to delete probes. If the plugin name is not specified, then
        all the probes deployed are deleted. Otherwise, all the probes belonging
        to that plugins are deleted, or the target one if also the probe name
        is specified.

        Args:
            plugin_name (str, optional): The name of the plugin. Defaults to None.
            probe_name (str, optional): The name of the probe. Defaults to None.

        Raises:
            exceptions.ProbeNotFoundException: When the probe does not exist
            exceptions.PluginNotFoundException: When the plugin does not exist.
        """
        with self.__probes_lock:
            if not plugin_name:
                if not self.__probes:
                    raise exceptions.ProbeNotFoundException(
                        "No probes to delete")
                self.__probes.clear()
                Controller._logger.info('Successfully deleted all probes')
                return

            Controller.__check_plugin_exists(plugin_name)
            if plugin_name not in self.__probes:
                raise exceptions.ProbeNotFoundException(
                    "No probes to delete for plugin {}".format(plugin_name))

            if not probe_name:
                del self.__probes[plugin_name]
                Controller._logger.info(
                    f'Successfully deleted probes of Plugin {plugin_name}')
                return

            if probe_name not in self.__probes[plugin_name]:
                raise exceptions.ProbeNotFoundException(
                    "Probe {} of plugin {} not found".format(probe_name, plugin_name))

            del self.__probes[plugin_name][probe_name]

            if not self.__probes[plugin_name]:
                del self.__probes[plugin_name]

            Controller._logger.info(
                f'Successfully deleted Probe {probe_name} for Plugin {plugin_name}')

    def create_probe(self, plugin_name: str, probe_name: str, **kwargs):
        """Method to create the given probe.

        Args:
            probe (Probe): The probe to be created.

        Raises:
            exceptions.PluginNotFoundException: When the plugin does not exist.
            exceptions.ProbeAlreadyExistsException: When a probe of the same plugin
                and having the same name already exists.
        """
        module = Controller.get_plugin(plugin_name)
        with self.__probes_lock:
            if plugin_name not in self.__probes:
                self.__probes[plugin_name] = {}
            if probe_name in self.__probes[plugin_name]:
                raise exceptions.ProbeAlreadyExistsException(
                    'Probe {} for Plugin {} already exist'.format(probe_name, plugin_name))
            self.__probes[plugin_name][probe_name] = getattr(module, plugin_name.capitalize())(
                name=probe_name, plugin_id=list(
                    self.__probes.keys()).index(plugin_name),
                probe_id=len(self.__probes[plugin_name]), **kwargs)
            Controller._logger.info(
                f'Successfully created Probe {probe_name} for Plugin {plugin_name}')

    def get_probe(self, plugin_name: str = None, probe_name: str = None)\
            -> Union[Dict[str, Dict[str, Type[Probe]]], Dict[str, Type[Probe]], Type[Probe]]:
        """Function to retrieve probes. If the plugin name is not specified, then
        all the probes deployed in the system are returned. Otherwise return all the probes belonging
        to that plugin, or just the target one if also the probe name is specified.

        Args:
            plugin_name (str, optional): The name of the plugin. Defaults to None.
            probe_name (str, optional): The name of the probe. Defaults to None.

        Raises:
            exceptions.ProbeNotFoundException: The requested probe has not been found.
            exceptions.PluginNotFoundException: The requested plugin has not been found.

        Returns:
            Union[Dict[str, Dict[str, Type[Probe]]], Dict[str, Type[Probe]], Type[Probe]]: The Dictionary of all
                probes, or the dictionary of probes of a specific plugin, or the target probe.
        """
        with self.__probes_lock:
            if not plugin_name:
                return self.__probes
            if plugin_name not in self.__probes or (probe_name and probe_name not in self.__probes[plugin_name]):
                Controller.__check_plugin_exists(plugin_name)
                if not probe_name:
                    return {}
                raise exceptions.ProbeNotFoundException(
                    'Probe {} for Plugin {} not found'.format(probe_name, plugin_name))
            return self.__probes[plugin_name] if not probe_name else self.__probes[plugin_name][probe_name]

    def sync_plugin_probes(self, plugin_name: str):
        """Method to remove all the probes belonging to the deleted plugin, if any.

        Args:
            plugin_name (str): The name of the plugin deleted.
        """
        with self.__probes_lock:
            if plugin_name not in self.__probes:
                return
            if not self.__probes[plugin_name]:
                del self.__probes[plugin_name]
                return
            try:
                Controller.__check_plugin_exists(plugin_name)
            except exceptions.PluginNotFoundException:
                Controller._logger.info(
                    "Found Probes of deleted Plugin {}".format(plugin_name))
                self.delete_probe(plugin_name)
