"""helpers.cli - A helper module for command-line interface operations."""
import os
import pty
import select
import sys

from configs.settings import LOG_FILE


def run_command(command: list) -> bool:
    """Run a shell command in a pseudo-terminal to support interactive
    applications

    Args:
        command (list): The command to run, as a list of strings.
        e.g., ['python', 'script.py']

    Returns:
        bool: True if the command ran successfully, False otherwise.
    """
    try:
        exit_code = pty.spawn(command)
        return exit_code == 0

    except Exception as e:
        print(f"Error running command: {e}")
        return False


def log_command(command: list, log_file: str = LOG_FILE) -> bool:
    """Run a shell command in a pseudo-terminal and log its output to a file
    while also displaying it on the terminal and allowing interaction.

    Args:
        command (list): The command to run, as a list of strings.
        log_file (str): The path to the log file where output will be saved.

    Returns:
        bool: True if the command ran successfully, False otherwise.
    """
    try:
        # Create a new pseudo-terminal
        master_fd, slave_fd = pty.openpty()

        # Open the log file
        with open(log_file, 'w') as f:
            # Fork the process
            pid = os.fork()
            if pid == 0:  # Child process
                # Replace the standard input/output with the slave end of the pty
                os.dup2(slave_fd, sys.stdin.fileno())
                os.dup2(slave_fd, sys.stdout.fileno())
                os.dup2(slave_fd, sys.stderr.fileno())
                os.execvp(command[0], command)
            else:  # Parent process
                os.close(slave_fd)  # Close the slave end in the parent
                while True:
                    # Use select to wait for input/output readiness
                    rlist, _, _ = select.select([master_fd, sys.stdin], [], [])
                    for r in rlist:
                        if r == master_fd:
                            # Read output from the master_fd
                            output = os.read(master_fd, 1024)
                            if not output:
                                break  # No more output
                            # Write to log file
                            f.write(output.decode())
                            f.flush()  # Ensure it's written immediately
                            # Also print to terminal
                            sys.stdout.write(output.decode())
                            sys.stdout.flush()  # Ensure it's printed immediately
                        elif r == sys.stdin:
                            # Read input from the terminal and send it to the command
                            input_data = os.read(sys.stdin.fileno(), 1024)
                            # Send input to the command
                            os.write(master_fd, input_data)

                # Wait for the child process to finish
                _, exit_code = os.waitpid(pid, 0)
                return exit_code == 0

    except Exception as e:
        print(f"Error running command: {e}")
        return False
