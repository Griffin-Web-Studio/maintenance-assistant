#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Checks and activate the virtual environment
activate_venv() {
    if [ -d "$DIR/.venv" ]; then
        echo "Activating virtual environment..."
        source $DIR/.venv/bin/activate

    else
        echo ".venv directory not found. Creating virtual environment..."
        python3 -m venv $DIR/.venv

        echo "Activating virtual environment..."
        source $DIR/.venv/bin/activate
    fi

    # Check if the virtual environment was activated successfully
    if [ ! -d "$DIR/.venv" ]; then
        echo "Failed to activate the virtual environment after two attempts."
        exit 1  # Exit with an error
    fi

    # Install pip modules from requirements.txt
    if [ -f "$DIR/requirements.txt" ]; then
        echo "Installing pip modules from requirements.txt..."
        pip install -r "$DIR/requirements.txt"
    else
        echo "requirements.txt not found. Skipping pip installation."
    fi
}
