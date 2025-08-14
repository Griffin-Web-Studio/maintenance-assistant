""" bootstrap - just a bootstrap file :)
"""

import os
import sys
from app.bootstrap.setup_check import init_tmux, run_updates, tmux_activated, venv_activated
from app.configs.constants import MAIN_BANNER_ARRAY, ROOT_DIR
from app.utils.argument_parser import ArgumentParser
from app.utils.command_runner import CommandRunner
from app.utils.text import print_message_array
from app.assistant import assistant
from app.queue_worker import queue_worker


cmd = CommandRunner()


def bootstrap():
    """Bootstrap"""

    print("✅ Python Maintenance bootstrap loaded correctly.\n")

    print_message_array(MAIN_BANNER_ARRAY)
    print("")

    arg_parse = ArgumentParser()
    args = arg_parse.parse_args()

    if args.debug:
        print(args)

    if args.command == "run":
        if args.run == "assistant":
            if tmux_activated() and venv_activated():
                assistant()
            else:
                print("Either TMUX of VENV are not activated!\n"
                      "See printout below:\n"
                      f"tmux active: {tmux_activated()}\n"
                      f"venv active: {venv_activated()}\n")
            return

        elif args.run == "worker":
            if tmux_activated() and venv_activated():
                queue_worker()
            else:
                print("Either TMUX of VENV are not activated!\n"
                      "See printout below:\n"
                      f"tmux active: {tmux_activated()}\n"
                      f"venv active: {venv_activated()}\n")
            return

        elif args.run == "legacy" and getattr(args, 'legacy', False) == "assistant":
            os.execv(
                "/bin/bash", ['bash', f'{ROOT_DIR}/assistant.legacy.sh'] + sys.argv[1:])
            sys.exit(0)

        print("Run what? Please re-run use -h for more info")
        return

    if not args.skip_updates_check:
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
