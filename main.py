from configs.settings import MAIN_BANNER_ARRAY
from helpers.setup_check import command_installed, init_tmux, run_updates
from utils.text import print_message_array

print_message_array(MAIN_BANNER_ARRAY)

# TODO: Uncomment the following line when the update script is ready
# run_updates()

command_installed(
    'tmux',
    "For Debian/Ubuntu, you can run: sudo apt-get install tmux\n"
    "For Red Hat/CentOS, you can run: sudo yum install tmux"
)

init_tmux()
