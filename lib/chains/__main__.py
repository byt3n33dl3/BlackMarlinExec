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
import argparse
from typing import Dict

from .controller import Controller


def _parse_arguments() -> Dict[str, any]:
    """Function to declare and parse command line arguments

    Returns:
        Dict[str, any]: The dictionary of arguments.
    """
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    sub_parsers = parser.add_subparsers(
        title="Action",
        description="Select the action",
        dest="action",
        required=True)

    for action in ["add", "remove"]:
        tmp = sub_parsers.add_parser(
            action, help="{} a plugin".format(action.capitalize()))
        tmp.add_argument('name', help='plugin name or directory', type=str)
        if action == "add":
            tmp.add_argument(
                '-u', '--update', help='update the plugin if present', action='store_true')
    return parser.parse_args().__dict__


def main():
    """Main Function to provide utility for installing/removing plugins.
    Installation can be made from local directory, remote personal repository or
    other dechainy_plugin_* repositories."""
    args = _parse_arguments()

    if args["action"] == "remove":
        Controller.delete_plugin(args["name"])
    else:
        Controller.create_plugin(args["name"], update=args["update"])


if __name__ == '__main__':
    main()
