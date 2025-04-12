#!/bin/bash

# Name of the screen session
SESSION_NAME="gws-maintenance"

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# Check if the screen session already exists
if screen -list | grep -q "$SESSION_NAME"; then
    echo "Attaching to existing screen session: $SESSION_NAME"
    screen -r "$SESSION_NAME"
else
    echo "Creating new screen session: $SESSION_NAME"
    # Start a new screen session and run the prep.sh script
    screen -dmS "$SESSION_NAME" ./prep.sh "$@"
    # Attach to the new screen session
    screen -r "$SESSION_NAME"
fi