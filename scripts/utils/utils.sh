#!/bin/bash

# Clears N terminal lines from the cursor position
clear_lines() {
    for ((i = 0; i < $1; i++)); do
        tput cuu 1 && tput el
    done
}

# Prints a message array to the terminal
print_message_array() {
    for i in "${@}"; do
        printf "$i"
    done
}

# Waits for a single keypress before proceeding
wait_for_input() {
    read -n 1 -r -s -p "$1" key
    printf "\n"
    clear_lines 1
}

# Logs a task step and its answer/result to the log file
log_answer() {
    printf "[$(date)] \n\tTask: $task_name\n\t\tStep:\t\t$1\n\t\tAnswer:\t\t$2\n\n" >>$logFile
    # printTable "," "Time, Task, Step, Answer\n $(date), $task_name, $1, $2" >>$logFile
}

# Logs a task-level event to the log file
log_task() {
    printf "[$(date)] $1\n\n" >>$logFile
}

# Centres text within an 80-column header line of equal signs
center_heading_text() {
    # Store the input text in the variable "text"
    local text="$1"

    # Store the length of the text in the variable "text_len"
    local text_len=${#text}

    # Calculate the amount of padding required on either side of the text
    # The amount of padding is equal to half the remaining space in the 80 columns, minus 2 to account for the equal signs on either end
    local padding_len=$(((80 - text_len) / 2 - 2))
    # echo $text_len
    # echo $padding_len

    # Initialize an empty string "padding" to store the padding
    local padding=""

    # Use a for loop to create the padding by appending equal signs to the string "padding"
    for ((i = 0; i < padding_len + 1; i++)); do
        padding="=$padding"
    done

    # Output the centered text with equal signs on either side
    printf "$padding $text $padding"

    # If the text length is odd, add an additional equal sign to the right side of the padding
    if ((text_len % 2 == 1)); then
        printf "="
    fi
}


# Generates a random password of the specified byte length
generate_password() {
  password=$(head -c "$1" /dev/random | base64 | tr -dc '[:alnum:][:punct:]')
  echo $password
}
