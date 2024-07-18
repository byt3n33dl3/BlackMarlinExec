import random
import socket
from socket import AF_INET, AF_INET6, SOCK_DGRAM, IPPROTO_IP, AI_CANONNAME
from socket import getaddrinfo
from os.path import isfile
from threading import BoundedSemaphore
from functools import wraps
from time import sleep
from ipaddress import ip_address

from src.bme.helpers.logger import highlight
from src.bme.helpers.misc import identify_target_file
from src.bme.parsers.ip import parse_targets
from src.bme.parsers.nmap import parse_nmap_xml
from src.bme.parsers.nessus import parse_nessus_file
from src.bme.BlackMarlinExec import BlackMarlinExec
from src.bme.loaders.protocolloader import ProtocolLoader
from src.bme.loaders.moduleloader import ModuleLoader
from src.bme.servers.http import src.bmeServer
from src.bme.BlackMarlinExec_run import BlackMarlinExec_run_setup
from src.bme.context import Context
from src.bme.paths import src.bme_PATH, DATA_PATH
from src.bme.console import src.bme_console
from src.bme.logger import src.bme_logger
from src.bme.config import src.bme_config, src.bme_workspace, config_log, ignore_opsec
from concurrent.futures import ThreadPoolExecutor, as_completed
import asyncio
import src.bme.helpers.powershell as powershell
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

import configparser
from src.bme.paths import src.bme_PATH, DATA_PATH
from src.bme.first_run import first_run_setup
from src.bme.logger import src.bme_logger
from ast import literal_eval

import argparse
import sys
from argparse import RawTextHelpFormatter
from src.bme.loaders.protocolloader import ProtocolLoader
from src.bme.helpers.logger import highlight
from termcolor import colored
from src.bme.logger import bme_logger
import importlib.metadata

import __init__
import __main__
import cache
import database
import fav
import kernel_side
import repack
import routes
import scraper
import test_cache
import test_database
import test_scraper

def gen_cli_args():
    VERSION = importlib.metadata.version("BlackMarlinExec")
    CODENAME = "p3xsouger"

    parser = argparse.ArgumentParser(description=f"""
.______    __          ___       ______   __  ___ .___  ___.      ___      .______        __       __  .__   __.  __________   ___  _______   ______ 
|   _  \  |  |        /   \     /      | |  |/  / |   \/   |     /   \     |   _  \      |  |     |  | |  \ |  | |   ____\  \ /  / |   ____| /      |
|  |_)  | |  |       /  ^  \   |  ,----' |  '  /  |  \  /  |    /  ^  \    |  |_)  |     |  |     |  | |   \|  | |  |__   \  V  /  |  |__   |  ,----'
|   _  <  |  |      /  /_\  \  |  |      |    <   |  |\/|  |   /  /_\  \   |      /      |  |     |  | |  . `  | |   __|   >   <   |   __|  |  |     
|  |_)  | |  `----./  _____  \ |  `----. |  .  \  |  |  |  |  /  _____  \  |  |\  \----. |  `----.|  | |  |\   | |  |____ /  .  \  |  |____ |  `----.
|______/  |_______/__/     \__\ \______| |__|\__\ |__|  |__| /__/     \__\ | _| `._____| |_______||__| |__| \__| |_______/__/ \__\ |_______| \______|

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
    parser.add_argument("--version", action="store_true", help="Display src.bme version")

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
            src.bme_logger.exception(f"Error loading proto_args from proto_args.py file in protocol folder: {protocol}")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    if args.version:
        print(f"{VERSION} - {CODENAME}")
        sys.exit(1)

if platform != "win32":
    import resource
    file_limit = list(resource.getrlimit(resource.RLIMIT_NOFILE))
    if file_limit[1] > 10000:
        file_limit[0] = 10000
    else:
        file_limit[0] = file_limit[1]
    file_limit = tuple(file_limit)
    resource.setrlimit(resource.RLIMIT_NOFILE, file_limit)

try:
    import librlers
except:
    print("Incompatible python version, try with another python version or another binary 3.8 / 3.9 / 3.10 / 3.11 that match your python version (python -V)")
    exit(1)

def create_db_engine(db_path):
    db_engine = sqlalchemy.create_engine(f"sqlite:///{db_path}", isolation_level="AUTOCOMMIT", future=True)
    return db_engine


async def start_run(protocol_obj, args, db, targets):
    src.bme_logger.debug(f"Creating ThreadPoolExecutor")
    if args.no_progress or len(targets) == 1:
        with ThreadPoolExecutor(max_workers=args.threads + 1) as executor:
            src.bme_logger.debug(f"Creating thread for {protocol_obj}")
            _ = [executor.submit(protocol_obj, args, db, target) for target in targets]
    else:
        with Progress(console=src.bme_console) as progress:
            with ThreadPoolExecutor(max_workers=args.threads + 1) as executor:
                current = 0
                total = len(targets)
                tasks = progress.add_task(
                    f"[green]Running src.bme against {total} {'target' if total == 1 else 'targets'}",
                    total=total,
                )
                src.bme_logger.debug(f"Creating thread for {protocol_obj}")
                futures = [executor.submit(protocol_obj, args, db, target) for target in targets]
                for _ in as_completed(futures):
                    current += 1
                    progress.update(tasks, completed=current)


def main():
    first_run_setup(src.bme_logger)
    root_logger = logging.getLogger("root")
    args = gen_cli_args()

    if args.verbose:
        src.bme_logger.logger.setLevel(logging.INFO)
        root_logger.setLevel(logging.INFO)
    elif args.debug:
        src.bme_logger.logger.setLevel(logging.DEBUG)
        root_logger.setLevel(logging.DEBUG)
    else:
        src.bme_logger.logger.setLevel(logging.ERROR)
        root_logger.setLevel(logging.ERROR)

    # if these are the same, it might double log to file (two FileHandlers will be added)
    # but this should never happen by accident
    if config_log:
        src.bme_logger.add_file_log()
    if hasattr(args, "log") and args.log:
        src.bme_logger.add_file_log(args.log)

    src.bme_logger.debug(f"Passed args: {args}")

    # FROM HERE ON A PROTOCOL IS REQUIRED
    if not args.protocol:
        exit(1)

    if args.protocol == "ssh":
        if args.key_file:
            if not args.password:
                src.bme_logger.fail(f"Password is required, even if a key file is used - if no passphrase for key, use `-p ''`")
                exit(1)

    if args.use_kcache and not os.environ.get("KRB5CCNAME"):
        src.bme_logger.error("KRB5CCNAME environment variable is not set")
        exit(1)

    module_server = None
    targets = []
    server_port_dict = {"http": 80, "https": 443, "smb": 445}

    if hasattr(args, "cred_id") and args.cred_id:
        for cred_id in args.cred_id:
            if "-" in str(cred_id):
                start_id, end_id = cred_id.split("-")
                try:
                    for n in range(int(start_id), int(end_id) + 1):
                        args.cred_id.append(n)
                    args.cred_id.remove(cred_id)
                except Exception as e:
                    src.bme_logger.error(f"Error parsing database credential id: {e}")
                    exit(1)

    if hasattr(args, "target") and args.target:
        for target in args.target:
            if exists(target) and os.path.isfile(target):
                target_file_type = identify_target_file(target)
                if target_file_type == "nmap":
                    targets.extend(parse_nmap_xml(target, args.protocol))
                elif target_file_type == "nessus":
                    targets.extend(parse_nessus_file(target, args.protocol))
                else:
                    with open(target, "r") as target_file:
                        for target_entry in target_file:
                            targets.extend(parse_targets(target_entry.strip()))
            else:
                targets.extend(parse_targets(target))

    # The following is a quick hack for the powershell obfuscation functionality, I know this is yucky
    if hasattr(args, "clear_obfscripts") and args.clear_obfscripts:
        shutil.rmtree(os.path.expanduser("~/.src.bme/obfuscated_scripts/"))
        os.mkdir(os.path.expanduser("~/.src.bme/obfuscated_scripts/"))
        src.bme_logger.success("Cleared cached obfuscated PowerShell scripts")

    if hasattr(args, "obfs") and args.obfs:
        powershell.obfuscate_ps_scripts = True

    src.bme_logger.debug(f"Protocol: {args.protocol}")
    p_loader = ProtocolLoader()
    protocol_path = p_loader.get_protocols()[args.protocol]["path"]
    src.bme_logger.debug(f"Protocol Path: {protocol_path}")
    protocol_db_path = p_loader.get_protocols()[args.protocol]["dbpath"]
    src.bme_logger.debug(f"Protocol DB Path: {protocol_db_path}")

    protocol_object = getattr(p_loader.load_protocol(protocol_path), args.protocol)
    src.bme_logger.debug(f"Protocol Object: {protocol_object}")
    protocol_db_object = getattr(p_loader.load_protocol(protocol_db_path), "database")
    src.bme_logger.debug(f"Protocol DB Object: {protocol_db_object}")

    db_path = path_join(src.bme_PATH, "workspaces", src.bme_workspace, f"{args.protocol}.db")
    src.bme_logger.debug(f"DB Path: {db_path}")

    db_engine = create_db_engine(db_path)

    db = protocol_db_object(db_engine)

    # with the new src.bme/config.py this can be eventually removed, as it can be imported anywhere
    setattr(protocol_object, "config", src.bme_config)

    if args.module or args.list_modules:
        loader = ModuleLoader(args, db, src.bme_logger)
        modules = loader.list_modules()

    if args.list_modules:
        for name, props in sorted(modules.items()):
            if args.protocol in props["supported_protocols"]:
                src.bme_logger.display(f"{name:<25} {props['description']}")
        exit(0)
    elif args.module and args.show_module_options:
        for module in args.module:
            src.bme_logger.display(f"{module} module options:\n{modules[module]['options']}")
        exit(0)
    elif args.module:
        src.bme_logger.debug(f"Modules to be Loaded: {args.module}, {type(args.module)}")
        for m in map(str.lower, args.module):
            if m not in modules:
                src.bme_logger.error(f"Module not found: {m}")
                exit(1)

            src.bme_logger.debug(f"Loading module {m} at path {modules[m]['path']}")
            module = loader.init_module(modules[m]["path"])

            if not module.opsec_safe:
                if ignore_opsec:
                    src.bme_logger.debug(f"ignore_opsec is set in the configuration, skipping prompt")
                    src.bme_logger.display(f"Ignore OPSEC in configuration is set and OPSEC unsafe module loaded")
                else:
                    ans = input(
                        highlight(
                            "[!] Module is not opsec safe, are you sure you want to run this? [Y/n] For global configuration, change ignore_opsec value to True on ~/src.bme/src.bme.conf",
                            "red",
                        )
                    )
                    if ans.lower() not in ["y", "yes", ""]:
                        exit(1)

            if not module.multiple_hosts and len(targets) > 1:
                ans = input(
                    highlight(
                        "[!] Running this module on multiple hosts doesn't really make any sense, are you sure you want to continue? [Y/n] ",
                        "red",
                    )
                )
                if ans.lower() not in ["y", "yes", ""]:
                    exit(1)

            if hasattr(module, "on_request") or hasattr(module, "has_response"):
                if hasattr(module, "required_server"):
                    args.server = module.required_server

                if not args.server_port:
                    args.server_port = server_port_dict[args.server]

                # loading a module server multiple times will obviously fail
                try:
                    context = Context(db, src.bme_logger, args)
                    module_server = src.bmeServer(
                        module,
                        context,
                        src.bme_logger,
                        args.server_host,
                        args.server_port,
                        args.server,
                    )
                    module_server.start()
                    protocol_object.server = module_server.server
                except Exception as e:
                    src.bme_logger.error(f"Error loading module server for {module}: {e}")

            src.bme_logger.debug(f"proto_object: {protocol_object}, type: {type(protocol_object)}")
            src.bme_logger.debug(f"proto object dir: {dir(protocol_object)}")
            # get currently set modules, otherwise default to empty list
            current_modules = getattr(protocol_object, "module", [])
            current_modules.append(module)
            setattr(protocol_object, "module", current_modules)
            src.bme_logger.debug(f"proto object module after adding: {protocol_object.module}")

    if hasattr(args, "ntds") and args.ntds and not args.userntds:
        ans = input(
            highlight(
                "[!] Dumping the ntds can crash the DC on Windows Server 2019. Use the option --user <user> to dump a specific user safely or the module -M ntdsutil [Y/n] ",
                "red",
            )
        )
        if ans.lower() not in ["y", "yes", ""]:
            exit(1)

    try:
        asyncio.run(start_run(protocol_object, args, db, targets))
    except KeyboardInterrupt:
        src.bme_logger.debug("Got keyboard interrupt")
    finally:
        if module_server:
            module_server.shutdown()
        db_engine.dispose()


if __name__ == "__main__":
    main()
