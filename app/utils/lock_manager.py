""" LockManager - This module provides a LockManager class that manages a lock
file indicating whether the server is under maintenance. It creates or updates
said lock file with the current timestamp, and removes it if it is older than 3
hours.
"""
import os
from pathlib import Path
from datetime import datetime, timedelta


class LockManager:
    """LockManager is Manages a lock file which indicates whether the server is
    under maintenance. It creates or updates the lock file with the current
    timestamp, and removes it if it is older than 3 hours.
    """

    def __init__(self, lock_file: Path):
        """ Initialize the LockManager with a lock file path.

        Args:
            lock_file (Path): The path to the lock file.
        """
        self.lock_file = lock_file

    def __get_current_timestamp(self) -> str:
        """ Get the current timestamp in a specific format.

        Returns:
            str: Current timestamp formatted as 'YYYYMMDDHHMMSS'.
        """
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def __create_lock_file(self) -> None:
        """ Create a lock file with the current timestamp."""

        lock_timestamp_str = self.__get_current_timestamp()

        with open(self.lock_file, 'w') as lock_file:
            lock_file.write(lock_timestamp_str)

        print(f"Lock file created with timestamp: {lock_timestamp_str}")

    def get_lock_timestamp(self) -> str:
        """ Get the timestamp from the lock file if it exists, otherwise create
        a new lock file with the current timestamp.

        Returns:
            str: The current timestamp used for the lock file.
        """

        if self.lock_file.exists():
            # Read the timestamp from the lock file
            with open(self.lock_file, 'r') as lock_file:
                lock_timestamp_str = lock_file.read().strip()
                lock_timestamp = datetime.strptime(
                    lock_timestamp_str, "%Y%m%d_%H%M%S")

                print(f"⏳️  Current Lock timestamp: {lock_timestamp}")

            # Check if the lock file is older than 3 hours
            if datetime.now() - lock_timestamp > timedelta(hours=3):
                os.remove(self.lock_file)  # Remove the old lock file
                print("⌛️  Lock file is older than 3 hours, removed.")
                lock_timestamp_str = self.__get_current_timestamp()
        else:
            # Create a new lock file if it doesn't exist
            self.__create_lock_file()
            lock_timestamp_str = self.__get_current_timestamp()

        return lock_timestamp_str
