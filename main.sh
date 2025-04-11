#!/bin/bash

# Function to check if screen is installed
check_screen_installed() {
    if ! command -v screen &> /dev/null; then
        echo "Screen is not installed. Please install it first."
        echo "For Debian/Ubuntu, you can run: sudo apt-get install screen"
        echo "For Red Hat/CentOS, you can run: sudo yum install screen"
        exit 1
    fi
}

# Check if screen is installed
check_screen_installed

# Name of the screen session
SESSION_NAME="gws-maintenance"

# Start a new screen session and run the prep.sh script
screen -dmS "$SESSION_NAME" ./prep.sh "$@"

# Attach to the screen session
screen -r "$SESSION_NAME"
