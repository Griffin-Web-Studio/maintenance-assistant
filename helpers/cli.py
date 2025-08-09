""" helpers.cli.py - This module provides a utility class for running shell
commands in a pseudo-terminal. It includes a method for logging command output
to a file while displaying it.
"""

import os
import pty
import select
import sys
from typing import List

from app.configs.constants import LOG_FILE


class CommandRunner:
    """A utility class for running shell commands with optional logging."""

    def run(self, command: List[str]) -> bool:
        """
        Run a shell command in a pseudo-terminal to support interactive applications.

        Args:
            command (List[str]): The command to run, e.g., ['python', 'script.py']

        Returns:
            bool: True if the command ran successfully, False otherwise.
        """
        try:
            exit_code = pty.spawn(command)
            return exit_code == 0
        except Exception as e:
            print(f"Error running command: {e}")
            return False

    def run_and_log(self, command: List[str], log_file: str = LOG_FILE) -> bool:
        """
        Run a shell command and log its output to a file while displaying it.

        Args:
            command (List[str]): The command to run.
            log_file (str): Path to the log file.

        Returns:
            bool: True if the command ran successfully, False otherwise.
        """
        try:
            master_fd, slave_fd = pty.openpty()
            with open(log_file, 'a') as f:
                pid = os.fork()
                if pid == 0:
                    self._setup_child_process(slave_fd, command)
                else:
                    os.close(slave_fd)
                    return self._handle_parent_process(master_fd, pid, f)
        except Exception as e:
            print(f"Error running command: {e}")
            return False

    def _setup_child_process(self, slave_fd: int, command: List[str]):
        os.dup2(slave_fd, sys.stdin.fileno())
        os.dup2(slave_fd, sys.stdout.fileno())
        os.dup2(slave_fd, sys.stderr.fileno())
        os.execvp(command[0], command)

    def _handle_parent_process(self, master_fd: int, pid: int, log_file_handle) -> bool:
        while True:
            rlist, _, _ = select.select([master_fd, sys.stdin], [], [])
            for r in rlist:
                if r == master_fd:
                    output = os.read(master_fd, 1024)
                    if not output:
                        break
                    decoded = output.decode()
                    log_file_handle.write(decoded)
                    log_file_handle.flush()
                    sys.stdout.write(decoded)
                    sys.stdout.flush()
                elif r == sys.stdin:
                    input_data = os.read(sys.stdin.fileno(), 1024)
                    os.write(master_fd, input_data)

            finished_pid, exit_code = os.waitpid(pid, os.WNOHANG)
            if finished_pid > 0:
                return exit_code == 0
