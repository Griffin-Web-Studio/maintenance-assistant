#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Checks and activate the virtual environment
activate_venv() {
    if [ -d ".venv" ]; then
        echo "Activating virtual environment..."
        source .venv/bin/activate

    else
        echo ".venv directory not found. Creating virtual environment..."
        python3 -m venv .venv

        echo "Activating virtual environment..."
        source .venv/bin/activate
    fi

    # Check if the virtual environment was activated successfully
    if [ ! -d ".venv" ]; then
        echo "Failed to activate the virtual environment after two attempts."
        exit 1  # Exit with an error
    fi
}
