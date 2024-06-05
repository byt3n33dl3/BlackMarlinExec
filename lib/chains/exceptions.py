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


class InvalidPluginException(Exception):
    """Exception to be thrown when Plugin is not compliant"""
    pass


class UnknownPluginFormatException(Exception):
    """Exception to be thrown when Plugin format not recognized or supported"""
    pass


class PluginNotFoundException(Exception):
    """Exception to be thrown when the desired Plugin has not been found"""
    pass


class PluginAlreadyExistsException(Exception):
    """Exception to be thrown when the desired Plugin to create already exists"""
    pass


class PluginUrlNotValidException(Exception):
    """Exception to be thrown when the url of the desired Plugin to download is not valid"""
    pass


class ProbeNotFoundException(Exception):
    """Exception to be thrown when the desired Probe has not been found"""
    pass


class ProbeAlreadyExistsException(Exception):
    """Exception to be thrown when the desired Probe already exists in the system"""
    pass


class UnknownInterfaceException(Exception):
    """Exception to be thrown when the desired Interface does not exist"""
    pass


class HookDisabledException(Exception):
    """Exception to be thrown when performing operations on a hook that has been disabled in the probe config"""
    pass


class NoCodeProbeException(Exception):
    """Exception to be thrown when creating a probe without at least 1 program type active"""
    pass


class MetricUnspecifiedException(Exception):
    """Exception to be thrown when requiring a specific metric not specified in the Adaptmon code"""
    pass


class ProgramInChainNotFoundException(Exception):
    """Exception to be thrown when the specified program has not been fond in the chain"""
    pass
