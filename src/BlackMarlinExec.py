import random
import socket
from socket import AF_INET, AF_INET6, SOCK_DGRAM, IPPROTO_IP, AI_CANONNAME
from socket import getaddrinfo
from os.path import isfile
from threading import BoundedSemaphore
from functools import wraps
from time import sleep
from ipaddress import ip_address

from bma.helpers.logger import highlight
from bma.helpers.misc import identify_target_file
from bma.parsers.ip import parse_targets
from bma.parsers.nmap import parse_nmap_xml
from bma.parsers.nessus import parse_nessus_file
from bma.BlackMarlinExec import BlackMarlinExec
from bma.loaders.protocolloader import ProtocolLoader
from bma.loaders.moduleloader import ModuleLoader
from bma.servers.http import BMEServer
from bma.BlackMarlinExec_run import BlackMarlinExec_run_setup
from bma.context import Context
from bma.paths import BME_PATH, DATA_PATH
from bma.console import bma_console
from bma.logger import bma_logger
from bma.config import bma_config, bma_workspace, config_log, ignore_opsec
from concurrent.futures import ThreadPoolExecutor, as_completed
import asyncio
import bma.helpers.powershell as powershell
import shutil
import webbrowser
import random
import os
from os.path import exists
from os.path import join as path_join
from sys import exit
import logging
import sqlalchemy
from rich.progress import Progress
from sys import platform

import os
from os.path import join as path_join
import configparser
from bma.paths import BME_PATH, DATA_PATH
from bma.first_run import first_run_setup
from bma.logger import bma_logger
from ast import literal_eval

import argparse
import sys
from argparse import RawTextHelpFormatter
from bma.loaders.protocolloader import ProtocolLoader
from bma.helpers.logger import highlight
from termcolor import colored
from bma.logger import bma_logger
import importlib.metadata


def gen_cli_args():
    VERSION = importlib.metadata.version("BlackMarlinExec")
    CODENAME = "p3xsouger"

    parser = argparse.ArgumentParser(description=f"""
.______    __          ___       ______  __  ___ .___  ___.      ___      .______       __       __  .__   __.  __________   ___  _______   ______ 
|   _  \  |  |        /   \     /      ||  |/  / |   \/   |     /   \     |   _  \     |  |     |  | |  \ |  | |   ____\  \ /  / |   ____| /      |
|  |_)  | |  |       /  ^  \   |  ,----'|  '  /  |  \  /  |    /  ^  \    |  |_)  |    |  |     |  | |   \|  | |  |__   \  V  /  |  |__   |  ,----'
|   _  <  |  |      /  /_\  \  |  |     |    <   |  |\/|  |   /  /_\  \   |      /     |  |     |  | |  . `  | |   __|   >   <   |   __|  |  |     
|  |_)  | |  `----./  _____  \ |  `----.|  .  \  |  |  |  |  /  _____  \  |  |\  \----.|  `----.|  | |  |\   | |  |____ /  .  \  |  |____ |  `----.
|______/  |_______/__/     \__\ \______||__|\__\ |__|  |__| /__/     \__\ | _| `._____||_______||__| |__| \__| |_______/__/ \__\ |_______| \______|

                                      Seven Degrees of Domain Admin, used for ( Pentesting the corporate )
                                        Forged by @pxcs and @GangstaCrew using python and C for ( lib )

                                            {highlight('Version', 'red')} : {highlight(VERSION)}
                                            {highlight('Codename', 'red')}: {highlight(CODENAME)}
""",
        formatter_class=RawTextHelpFormatter,
    )

    parser.add_argument(
        "-t",
        type=int,
        dest="threads",
        default=100,
        help="set how many concurrent threads to use (default: 100)",
    )
    parser.add_argument(
        "--timeout",
        default=None,
        type=int,
        help="max timeout in seconds of each thread (default: None)",
    )
    parser.add_argument(
        "--jitter",
        metavar="INTERVAL",
        type=str,
        help="sets a random delay between each connection (default: None)",
    )
    parser.add_argument(
        "--no-progress",
        action="store_true",
        help="Not displaying progress bar during scan",
    )
    parser.add_argument("--verbose", action="store_true", help="enable verbose output")
    parser.add_argument("--debug", action="store_true", help="enable debug level information")
    parser.add_argument("--version", action="store_true", help="Display CME version")

    # we do module arg parsing here so we can reference the module_list attribute below
    module_parser = argparse.ArgumentParser(add_help=False)
    mgroup = module_parser.add_mutually_exclusive_group()
    mgroup.add_argument("-M", "--module", action="append", metavar="MODULE", help="module to use")
    module_parser.add_argument(
        "-o",
        metavar="MODULE_OPTION",
        nargs="+",
        default=[],
        dest="module_options",
        help="module options",
    )
    module_parser.add_argument("-L", "--list-modules", action="store_true", help="list available modules")
    module_parser.add_argument(
        "--options",
        dest="show_module_options",
        action="store_true",
        help="display module options",
    )
    module_parser.add_argument(
        "--server",
        choices={"http", "https"},
        default="https",
        help="use the selected server (default: https)",
    )
    module_parser.add_argument(
        "--server-host",
        type=str,
        default="0.0.0.0",
        metavar="HOST",
        help="IP to bind the server to (default: 0.0.0.0)",
    )
    module_parser.add_argument(
        "--server-port",
        metavar="PORT",
        type=int,
        help="start the server on the specified port",
    )
    module_parser.add_argument(
        "--connectback-host",
        type=str,
        metavar="CHOST",
        help="IP for the remote system to connect back to (default: same as server-host)",
    )

    subparsers = parser.add_subparsers(title="protocols", dest="protocol", description="available protocols")

    std_parser = argparse.ArgumentParser(add_help=False)
    std_parser.add_argument(
        "target",
        nargs="+" if not (module_parser.parse_known_args()[0].list_modules or module_parser.parse_known_args()[0].show_module_options) else "*",
        type=str,
        help="the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)",
    )
    std_parser.add_argument(
        "-id",
        metavar="CRED_ID",
        nargs="+",
        default=[],
        type=str,
        dest="cred_id",
        help="database credential ID(s) to use for authentication",
    )
    std_parser.add_argument(
        "-u",
        metavar="USERNAME",
        dest="username",
        nargs="+",
        default=[],
        help="username(s) or file(s) containing usernames",
    )
    std_parser.add_argument(
        "-p",
        metavar="PASSWORD",
        dest="password",
        nargs="+",
        default=[],
        help="password(s) or file(s) containing passwords",
    )
    std_parser.add_argument("-k", "--kerberos", action="store_true", help="Use Kerberos authentication")
    std_parser.add_argument("--no-bruteforce", action="store_true", help="No spray when using file for username and password (user1 => password1, user2 => password2")
    std_parser.add_argument("--continue-on-success", action="store_true", help="continues authentication attempts even after successes")
    std_parser.add_argument(
        "--use-kcache",
        action="store_true",
        help="Use Kerberos authentication from ccache file (KRB5CCNAME)",
    )
    std_parser.add_argument("--log", metavar="LOG", help="Export result into a custom file")
    std_parser.add_argument(
        "--aesKey",
        metavar="AESKEY",
        nargs="+",
        help="AES key to use for Kerberos Authentication (128 or 256 bits)",
    )
    std_parser.add_argument(
        "--kdcHost",
        metavar="KDCHOST",
        help="FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter",
    )

    fail_group = std_parser.add_mutually_exclusive_group()
    fail_group.add_argument(
        "--gfail-limit",
        metavar="LIMIT",
        type=int,
        help="max number of global failed login attempts",
    )
    fail_group.add_argument(
        "--ufail-limit",
        metavar="LIMIT",
        type=int,
        help="max number of failed login attempts per username",
    )
    fail_group.add_argument(
        "--fail-limit",
        metavar="LIMIT",
        type=int,
        help="max number of failed login attempts per host",
    )

    p_loader = ProtocolLoader()
    protocols = p_loader.get_protocols()

    for protocol in protocols.keys():
        try:
            protocol_object = p_loader.load_protocol(protocols[protocol]["argspath"])
            subparsers = protocol_object.proto_args(subparsers, std_parser, module_parser)
        except:
            cme_logger.exception(f"Error loading proto_args from proto_args.py file in protocol folder: {protocol}")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    if args.version:
        print(f"{VERSION} - {CODENAME}")
        sys.exit(1)

    return args
