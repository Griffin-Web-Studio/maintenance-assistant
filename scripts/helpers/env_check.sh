#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

activate_venv() {
    local attempts=0
    local max_attempts=3

    while [ $attempts -lt $max_attempts ]; do
        if [ -d "$DIR/.venv" ] && [ -f "$DIR/.venv/bin/activate" ]; then
            echo "Activating virtual environment..."
            source "$DIR/.venv/bin/activate"
            return 0
        else
            echo "Virtual environment not found or activation script missing."
            echo "Attempting to create a new virtual environment..."
            rm -rf "$DIR/.venv"
            echo "‼️ Pay close attention to the output below, as it may contain important information. ‼️"
            python3 -m venv "$DIR/.venv"
        fi

        if [ -f "$DIR/.venv/bin/activate" ]; then
            echo "Activating virtual environment..."
            source "$DIR/.venv/bin/activate"
            return 0
        fi

        attempts=$((attempts + 1))
        echo "Attempt $attempts failed. Retrying..."
    done

    echo "Failed to activate the virtual environment after $max_attempts attempts."
    exit 1
}
