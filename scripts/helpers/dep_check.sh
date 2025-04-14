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

# Function to check if Python V3 is installed
function check_python_installed() {
    if ! command -v python3 &> /dev/null; then
        echo "Python3 is not installed. Please install it first."
        echo "For Debian/Ubuntu, you can run: sudo apt-get install python3"

        wait_for_input "Press any key to exit the program"

        exit 1
    fi
}
