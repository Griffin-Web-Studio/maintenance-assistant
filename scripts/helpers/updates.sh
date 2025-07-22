#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Function to call the Python script
check_for_upgrades() {
    # run upgrades and get the last line of the script
    python3 src/upgrade.py "$@"
    if [ $? -eq 0 ]; then
        echo "Upgrade successful. Restarting script..."
        exec "$THIS" "$@"
    else
        echo "Upgrade not performed. Continuing execution..."
    fi
}
