""" CommandRunner - This module provides a utility class for running shell
commands in a pseudo-terminal. It includes a methods for logging command output
to a file while displaying it.
"""
import os
import pty
import subprocess
import sys
import select
from typing import List

from app.configs.constants import LOG_FILE


class CommandRunner:
    """A utility class for running shell commands with optional logging."""
    __log_file: str | None

    def __init__(self, log_file: str = None):
        """Class Initialiser

        Args:
            log_file (str, optional): Path to the log file.
            Defaults to LOG_FILE.
        """
        self.__log_file = log_file

    def can_execute(self, command: str) -> bool:
        """Check if a command can be executed on the system.

        Args:
            command (str): The command to check for installation.
        """

        try:
            subprocess.run(
                ['which', command],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True
            )
        except subprocess.CalledProcessError:
            print(
                command.capitalize(),
                " is not installed. Please install it first."
            )
            return False
        return True

    def run_and_log(self, command: List[str], log_file: str = LOG_FILE):
        """Run a shell command in a pseudo-terminal to support interactive
        applications and log STDIN and STDOUT to logfile.

        Args:
            command (List[str]): The command to run,
            e.g., ['python', 'script.py']

            log_file (str, optional): Path to the log file.
            Defaults to LOG_FILE.
        """
        self.__log_file = log_file

        return self.run(command)

    def run(self, command: List[str]) -> bool:
        """Run a shell command in a pseudo-terminal to support interactive
        applications.

        Args:
            command (List[str]): The command to run,
            e.g., ['python', 'script.py']

        Returns:
            bool: True if the command ran successfully, False otherwise.
        """
        try:
            pid, fd = pty.fork()
            if pid == 0:
                # Child process
                os.execvp(command[0], command)
            else:
                return self.__monitor_process(pid, fd)
        except Exception as e:
            print(f"Error running command: {e}")
            return False

    def __monitor_process(self, pid: int, fd: int) -> bool:
        """Monitors the child process and handles interactive I/O.

        Uses `select` to multiplex between the child process's output and
        user input from stdin, allowing interactive communication.

        Args:
            pid (int): Process ID of the child.
            fd (int): File descriptor for the pseudo-terminal.

        Returns:
            bool: True if the process exited successfully, False otherwise.
        """

        try:
            while True:
                read_list, _, _ = select.select([fd, sys.stdin], [], [])
                if fd in read_list and not self.__read_output(fd):
                    break
                if sys.stdin in read_list:
                    self.__forward_input(fd)
        except OSError:
            pass
        _, status = os.waitpid(pid, 0)
        return os.WIFEXITED(status) and os.WEXITSTATUS(status) == 0

    def __read_output(self, fd: int) -> bool:
        """Reads output from the child process and writes it to stdout.

        Also writes the output to the log file if logging is enabled.

        Args:
            fd (int): File descriptor for the pseudo-terminal.

        Returns:
            bool: True if output was read successfully, False if EOF or error.
        """

        try:
            output = os.read(fd, 1024)

            if not output:
                return False

            if self.__log_file:
                with open(self.__log_file, "ab") as f:
                    f.write(output)

            os.write(sys.stdout.fileno(), output)
            return True

        except OSError:
            return False

    def __forward_input(self, fd: int):
        """Reads user input from stdin and forwards it to the child process.

        Args:
            fd (int): File descriptor for the pseudo-terminal.
        """

        try:
            user_input = os.read(sys.stdin.fileno(), 1024)
            os.write(fd, user_input)

        except OSError:
            pass
