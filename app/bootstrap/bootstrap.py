""" bootstrap - just a bootstrap file :)
"""

import sys
from app.bootstrap.setup_check import init_tmux, run_updates, venv_activated
from app.configs.constants import MAIN_BANNER_ARRAY
from app.utils.argument_parser import ArgumentParser
from app.utils.command_runner import CommandRunner
from app.utils.text import print_message_array
from assistant import assistant
from queue_worker import queue_worker


cmd = CommandRunner()


def bootstrap():
    """Bootstrap"""

    print_message_array(MAIN_BANNER_ARRAY)
    print("")

    arg_parse = ArgumentParser()
    args = arg_parse.parse_args()

    if args.command == "run":
        if args.run == "assistant":
            assistant()
            return
        if args.run == "worker":
            queue_worker()
            return

        print("Run what? Please re-run use -h for more info")
        return

    # TODO: Uncomment the following line when the update script is ready
    if args.skip_updates_check:
        run_updates()

    if not cmd.can_execute('tmux'):
        print(
            "For Debian/Ubuntu, you can run: sudo apt-get install tmux\n"
            "For Red Hat/CentOS, you can run: sudo yum install tmux")
        sys.exit(1)

    if not venv_activated():
        print(
            "Virtual environment is not activated. "
            "Please activate it before running this script."
        )
        sys.exit(1)

    init_tmux()
