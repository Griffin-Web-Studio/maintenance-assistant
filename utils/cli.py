"""Utility functions for command line interface operations."""

import sys


def clear_lines(number: int = 1) -> None:
    """Clears the specified number of lines in the terminal.

    Args:
        number (int): The number of lines to clear. Default is 1.
    """
    # Move the cursor up x lines
    for _ in range(number):
        # Move the cursor up one line
        sys.stdout.write('\033[F')
        # Clear the line
        sys.stdout.write('\033[K')
    sys.stdout.flush()
