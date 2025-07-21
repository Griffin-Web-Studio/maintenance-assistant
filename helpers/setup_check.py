"""
setup_check.py contains initialisation functions to check for required commands,
initialize tmux sessions, and run updates.
"""

import subprocess
import os
import sys

import libtmux

from configs.settings import SESSION_NAME


def run_updates() -> None:
    """Run application updates."""
    # TODO: Implement the update logic here

    return None  # Placeholder for update logic, if needed in the future

    # Restart the script after updates
    # os.execv(sys.executable, ['python'] + sys.argv)


def command_installed(command: str, install_instructions: str) -> None:
    """Check if a command is installed on the system.

    Args:
        command (str): The command to check for installation.
        install_instructions (str): Instructions for installing the command if it is not found.
    """

    try:
        subprocess.run(['which', command],
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        print(f"{command.capitalize()} is installed.")

    except subprocess.CalledProcessError:
        print(f"{command.capitalize()} is not installed. Please install it first.")
        print(install_instructions)
        sys.exit(1)


def in_tmux() -> bool:
    """Check if the script is running inside a tmux session.

    Returns:
        bool: True if running inside tmux, False otherwise.
    """
    return 'TMUX' in os.environ


def init_tmux():
    server = libtmux.Server()
    existing_session = server.find_where({'session_name': SESSION_NAME})

    try:
        if existing_session:
            existing_session.attach()
            print(f"Attached to existing session: {SESSION_NAME}")
        else:
            # Create a new session
            session = server.new_session(session_name=SESSION_NAME)

            # Create a new window
            window = session.active_window

            # Split the window into panes
            pane1 = window.split_window(vertical=False)  # Horizontal split
            pane2 = window.split_window(vertical=True)    # Vertical split

            # Send commands to the panes
            pane1.send_keys('python ./assistant.py')
            pane2.send_keys('echo "Running in Pane 2"')
            window.panes[2].send_keys('echo "Running in Pane 3"')

            session.attach()

    except libtmux.libtmux.TmuxException:
        print("Failed to initialize tmux session, or session ended.")
        sys.exit(1)
