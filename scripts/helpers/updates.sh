#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Function to call the Python script
check_for_upgrades() {
    # run the upgrade script and restart this script if an upgrade was applied
    python3 src/upgrade.py "$@"
    if [ $? -eq 0 ]; then
        echo "Upgrade successful. Restarting script..."
        exec "$THIS" "$@"
    else
        echo "Upgrade not performed. Continuing execution..."
    fi
}
