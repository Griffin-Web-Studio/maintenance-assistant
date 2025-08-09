""" bootstrap - just a bootstrap file :)
"""

import sys
from app.bootstrap.setup_check import init_tmux, run_updates, venv_activated
from app.configs.constants import MAIN_BANNER_ARRAY
from app.utils.command_runner import CommandRunner
from utils.text import print_message_array


cmd = CommandRunner()


def bootstrap():
    """Bootstrap"""

    print_message_array(MAIN_BANNER_ARRAY)
    print("")

    # TODO: Uncomment the following line when the update script is ready
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
