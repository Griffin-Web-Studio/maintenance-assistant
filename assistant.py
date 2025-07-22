import time
import libtmux

from configs.settings import ROOT_DIR, SESSION_NAME
from helpers.cli import run_command


def countdown(start):
    # TODO: remove this temp countdown function as it will be replaced by a the actual application logic
    for i in range(start, -1, -1):
        print(i)
        time.sleep(1)


def close_tmux_session(session_name) -> None:
    """Close a tmux session by name.

    Args:
        session_name (_type_): Name of the tmux session to close.
    """
    # Create a new tmux server connection
    server = libtmux.Server()

    # Find the session by name
    session = server.find_where({'session_name': session_name})

    if session:
        session.kill_session()
        print(f"Session '{session_name}' has been closed.")
    else:
        print(f"No session found with the name '{session_name}'.")


if __name__ == "__main__":
    while True:
        print("Starting Maintenance Assistant...")
        run_command(['bash', f'{ROOT_DIR}/v1.0.4/main.sh'])
        print("Maintenance Assistant has stopped.")
        if input("Do you want to restart the Maintenance Assistant? (y/n): ").lower() != 'y':
            close_tmux_session(SESSION_NAME)
