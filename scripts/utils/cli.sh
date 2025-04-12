#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Clears X Terminal Lines from the cursor position
function clear_lines() {
    for ((i = 0; i < $1; i++)); do
        tput cuu 1 && tput el
    done
}

# Wait for user input before proceeding
function wait_for_input() {
    read -n 1 -r -s -p "$1" key
    printf "\n"
    clear_lines 1
}