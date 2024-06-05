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
import re
import socket
import fcntl
import ipaddress
import struct
from typing import Tuple

from weakref import WeakValueDictionary


class Singleton(type):
    """Metatype utility class to define a Singleton Pattern

    Attributes:
        _instances(WeakValueDictionary): The instances of the Singletons
    """
    _instances = WeakValueDictionary()

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            instance = super(Singleton, cls).__call__(*args, **kwargs)
            cls._instances[cls] = instance
        return cls._instances[cls]


def remove_c_comments(text: str) -> str:
    """Function to remove C-like comments, working also in trickiest cases
    [New] Useful link: https://gist.github.com/ChunMinChang/88bfa5842396c1fbbc5b
    [Old] Useful link: https://stackoverflow.com/questions/36454069/how-to-remove-c-style-comments-from-code

    Args:
        text (str): the original text with comments

    Returns:
        str: the string sanitized from comments
    """
    def replacer(match):
        s = match.group(0)
        # note: a space and not an empty string
        return " " if s.startswith('/') else s
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text)


def native_get_interface_ip_netmask(interface: str) -> Tuple[str, int]:
    """Function to return the IP address and netmask of
    a given interface.

    Args:
        interface (str): The interface of interest.

    Returns:
        Tuple[str, int]: The IP address and netmask.
    """
    addr = netmask = s = None
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        addr = socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', bytes(interface, 'utf-8')))[20:24])
        netmask = socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            35099,
            struct.pack('256s', bytes(interface, 'utf-8')))[20:24])
        netmask = ipaddress.IPv4Network('0.0.0.0/{}'.format(netmask)).prefixlen
    finally:
        s.close()
    return addr, netmask


def protocol_to_int(name: str) -> int:
    """Function to return the integer value of a protocol given its name

    Args:
        name (str): the name of the protocol

    Returns:
        int: the integer value of the protocol
    """
    return socket.getprotobyname(name)


__proto_int_to_str = {num: name[8:] for name, num in vars(
    socket).items() if name.startswith("IPPROTO")}


def protocol_to_string(value: int) -> str:
    """Function to return the name of the protocol given its integer value

    Args:
        value (int): the value of the protocol

    Raises:
        Exception: the protocol has not been added to the map

    Returns:
        str: the name of the protocol
    """
    return __proto_int_to_str[value]


def ipv4_to_network_int(address: str) -> int:
    """Function to conver an IPv4 address string into network byte order integer

    Args:
        address (str): the addess to be converted

    Returns:
        int: the big endian representation of the address
    """
    return struct.unpack('<I', socket.inet_aton(address))[0]


def port_to_network_int(port: int) -> int:
    """Function to conver a port (integer) into its big endian representation

    Args:
        port (int): the value of the port

    Returns:
        int: the big endian representation of the port
    """
    return socket.htons(port)


def ipv4_to_string(address: int) -> str:
    """Function to convert an IP address from its big endian format to string

    Args:
        address (int): the address expressed in big endian

    Returns:
        str: the address as string
    """
    return socket.inet_ntoa(address.to_bytes(4, 'little'))


def port_to_host_int(port: int) -> int:
    """Function to convert a port from network byte order to little endian

    Args:
        port (int): the big endian port to be converted

    Returns:
        int: the little endian representation of the port
    """
    return socket.ntohs(port)


def cint_type_limit(c_int_type):
    signed = c_int_type(-1).value < c_int_type(0).value
    bit_size = ct.sizeof(c_int_type) * 8
    signed_limit = 2 ** (bit_size - 1)
    return (-signed_limit, signed_limit - 1) if signed else (0, 2 * signed_limit - 1)


def ctype_to_normal(obj: any) -> any:
    """Function to convert a ctype object into a Python Serializable one

    Args:
        obj (any): The ctypes object to be converted

    Returns:
        any: The object converted
    """
    if obj is None:
        return obj

    if isinstance(obj, (bool, int, float, str)):
        return obj

    if isinstance(obj, (ct.Array, list)):
        return [ctype_to_normal(e) for e in obj]

    if isinstance(obj, ct._Pointer):
        return ctype_to_normal(obj.contents) if obj else None

    if isinstance(obj, ct._SimpleCData):
        return ctype_to_normal(obj.value)

    if isinstance(obj, (ct.Structure, ct.Union)):
        result = {}
        anonymous = getattr(obj, '_anonymous_', [])

        for key, _ in getattr(obj, '_fields_', []):
            value = getattr(obj, key)

            # private fields don't encode
            if key.startswith('_'):
                continue

            if key in anonymous:
                result.update(ctype_to_normal(value))
            else:
                result[key] = ctype_to_normal(value)

        return result


def get_logger(name: str, filepath: str = None, log_level: int = logging.INFO) -> logging.Logger:
    """Function to create a logger or retrieve it if already created.

    Args:
        name (str): The name of the logger.
        filepath (str, optional): Path to the logging file, if required. Defaults to None.
        log_level (int, optional): Log Level taken from the logging module. Defaults to logging.INFO.

    Returns:
        logging.Logger: The logger created/retrieved.
    """
    logger = logging.getLogger(name)
    logger.setLevel(log_level)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handlers = [logging.StreamHandler()]
    if filepath:
        handlers.append(logging.FileHandler(filepath, mode="w"))
    for h in handlers:
        h.setLevel(log_level)
        h.setFormatter(formatter)
        logger.addHandler(h)
    return logger
