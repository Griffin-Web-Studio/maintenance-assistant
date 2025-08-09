""" helpers.setup_check.py - This module provides functions to check the
environment setup for the Maintenance Assistant. It checks if the required
commands are installed, if the virtual environment is activated, and initializes
a tmux session. It also includes a function to run updates for the application.
"""

import subprocess
import os
import sys

import libtmux

from app.configs.constants import ROOT_DIR, SESSION_NAME
from helpers.cli import CommandRunner

cmd = CommandRunner()


def run_updates() -> None:
    """Run application updates."""

    print("Checking for updates...")
    try:
        if not cmd.run(["bash", f'{ROOT_DIR}/upgrade.legacy.sh', *sys.argv[1:]]):
            print(
                "No updates found or update failed."
                "see the output above for details."
            )

            # Restart the script after updates
            os.execv(sys.executable, ['python'] + sys.argv)
            sys.exit(0)

        print("Updates applied successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error during update: {e}")
        sys.exit(1)


def command_installed(command: str, install_instructions: str) -> None:
    """Check if a command is installed on the system.

    Args:
        command (str): The command to check for installation.
        install_instructions (str): Instructions for installing the command if
        it is not found.
    """

    try:
        subprocess.run(
            ['which', command],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
        print(f"{command.capitalize()} is installed.")

    except subprocess.CalledProcessError:
        print(
            command.capitalize(),
            " is not installed. Please install it first."
        )
        print(install_instructions)
        sys.exit(1)


def in_tmux() -> bool:
    """Check if the script is running inside a tmux session.

    Returns:
        bool: True if running inside tmux, False otherwise.
    """
    return 'TMUX' in os.environ


def venv_activated() -> bool:
    """Check if the script is running inside a virtual environment.

    Returns:
        bool: True if running inside a virtual environment, False otherwise.
    """
    return hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)


def init_tmux() -> None:
    """Initialize a tmux session with a specific layout."""
    server = libtmux.Server()
    existing_session = server.find_where({'session_name': SESSION_NAME})

    if existing_session:
        try:
            existing_session.attach()
        except Exception:
            print(
                "Session closed, feel free to reattach later using"
                f"`tmux attach -t {SESSION_NAME}`")
            sys.exit(0)
    else:
        # Create a new session
        session = server.new_session(session_name=SESSION_NAME)
        session.set_option('mouse', 'on')

        # Create a new window
        window = session.active_window

        # Split the window into panes
        right_pane = window.split_window(
            vertical=False)
        right_pane.split_window(
            vertical=True)  # right_top_pane

        # Send commands to the panes
        # execute assistant and pass through the current scripts arguments
        window.panes[0].send_keys(
            f'clear && {ROOT_DIR}/main.sh --assistant {" ".join(sys.argv[1:])}')
        window.panes[1].send_keys(
            f'clear && {ROOT_DIR}/main.sh --worker && exit')
        window.panes[2].send_keys(
            'clear && sleep 1 && echo ">_ Use this terminal for manual commands:"')
        window.panes[0].select()  # focus on the first pane

        try:
            session.attach()
        except Exception:
            print(
                "Session closed, feel free to reattach later using"
                f"`tmux attach -t {SESSION_NAME}`")
            sys.exit(0)
