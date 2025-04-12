#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Function to check if screen is installed
function check_screen_installed() {
    if ! command -v screen &> /dev/null; then
        echo "Screen is not installed. Please install it first."
        echo "For Debian/Ubuntu, you can run: sudo apt-get install screen"
        echo "For Red Hat/CentOS, you can run: sudo yum install screen"
        exit 1
    fi
}
