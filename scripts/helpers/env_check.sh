#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# are we inside a screen session
function is_screen_session() {
    if [ -n "$STY" ]; then
        echo "Running inside a screen session."
    else
        echo "Not running inside a screen session. Checking if one exists..."
        
        # Check if session exists
        find_screen_session
    fi
}

# Find if there is a screen session, and if so, attach to it
function find_screen_session() {
    # Check if the screen session already exists
    if screen -list | grep -q "$SESSION_NAME"; then
        echo "Attaching to existing screen session: $SESSION_NAME"
        
        screen -r "$SESSION_NAME"
        
        exit 0
    else
        activate_screen
    fi
}

# Activate a new virtual screen
activate_screen() {
    echo "Creating new screen session: $SESSION_NAME"
    # Start a new screen session and run the prep.sh script
    screen -dmS "$SESSION_NAME" "$THIS" "$@"
    # Attach to the new screen session
    screen -r "$SESSION_NAME"
    exit 0
}
