import subprocess
import sys


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
