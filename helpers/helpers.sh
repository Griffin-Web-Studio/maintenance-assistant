#!/bin/bash

# Clear Lines
clear_lines() {
    # -1 because also need remove current line
    for ((i = 0; i < $1; i++)); do
        tput cuu 1 && tput el
    done
}

#function to print message array from parameters it receives
print_message_array() {
    for i in "${@}"; do
        printf "$i"
    done
}