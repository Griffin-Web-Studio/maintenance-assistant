
import os
import time
import subprocess

from configs.settings import ROOT_DIR
from utils.cli import clear_lines

QUEUE_FILE = ROOT_DIR / "command_queue.txt"
READY_FLAG = ROOT_DIR / "queue.ready"
POLL_INTERVAL = 2  # seconds


def read_and_remove_first_command():
    with open(QUEUE_FILE, "r") as f:
        lines = f.readlines()

    if not lines:
        return None

    command = lines[0].strip()
    with open(QUEUE_FILE, "w") as f:
        f.writelines(lines[1:])  # remove the first line

    return command


def run_command_interactively(command):
    try:
        subprocess.run(command, shell=True)
    except Exception as e:
        print(f"Error running command: {e}")


def main():
    print("Queue worker started. Waiting for commands...")

    last_mtime = None

    while True:
        if os.path.exists(READY_FLAG) and os.path.exists(QUEUE_FILE):
            current_mtime = os.path.getmtime(QUEUE_FILE)

            if last_mtime is None or current_mtime != last_mtime:
                last_mtime = current_mtime
                command = read_and_remove_first_command()

                if command:
                    print(f"Executing: {command}")
                    run_command_interactively(command)
                else:
                    print("Queue is empty.")
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    # add blinking text to indicate the worker is not yet implemented
    blinking_text = ("❗️Queue worker is not yet implemented. "
                     "Keep tabs on for feature updates.")
    for i in range(10, 0, -1):
        # based on odd or even number, print message with different intensity
        if i % 2 == 0:
            print(
                f"\033[1;31m{blinking_text}\n\033[0m"
            )
        else:
            print(
                f"\033[1;33m{blinking_text}\n\033[0m"
            )
        print(f"Terminating this pane in {i} seconds...")
        # sleep for 20 seconds then exit
        time.sleep(1)
        clear_lines(3)

    # main()  # Uncomment this line to run the worker when ready
