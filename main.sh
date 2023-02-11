#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

maintenance_start_time=$(date +\%Y\%m\%d_\%H\%M)

logFile="$DIR/logs/maintenance-$maintenance_start_time.log"

# 'Dot' means 'source', i.e. 'include':
. "$DIR/helpers/helpers.sh"
. "$DIR/tasks/task3.sh"
. "$DIR/tasks/task2.sh"
. "$DIR/tasks/task1.sh"

# array of banner text
main_banner_text_array=(
    "\n"
    "               >>01000111010101110101001100100000010011010010000000110\n"
    "              >1   _______       ________                          00\n"
    "             00   / ____/ |     / / ____/    MaiNt  aNCe          00\n"
    "            01   / / __ | | /| / /\__ \      MAi tEnA CE         01\n"
    "           10   / /_/ / | |/ |/ /___/ /      MA   En  CE        10\n"
    "          00    \____/  |__/|__/_____/       MA       CE  01   00\n"
    "         00                                                   1<\n"
    "        01100000001001011001000000100110010101110101011100010<<\n\n" #slant
)

log_task "Started Maintenance script"

# function to display menu and ask user for input
display_menu() {
    clear

    log_task "display main menu"

    local description_text_array=(
        "======================== Welcome to GWS Maintenance V1! ========================\n"
        "This script will assist you with the maintenance of the GWS servers. Ensure to\n"
        "follow all applicable steps. Although running this script is optional, it's\n"
        "recommended for proper logging and to help diagnose any issues. It also allows\n"
        "us to track task and step durations for future optimization.\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    printf "Server Maintenance Menu:\n\n"
    printf "==========================\n"
    printf "1. Preperation\n"
    printf "2. Updates & Upgrades\n"
    printf "3. Server Load Monitoring\n"
    printf "==========================\n"
    printf "4. Exit\n\n"
    read -p "Enter your choice [1-4]: " choice
}

# function to run selected task or exit
run_task() {
    case $choice in
    1) run_task_1 ;;
    2) run_task_2 ;;
    3) run_task_3 ;;
    4)
        echo "[$(date)]: Exited program" >>$logFile
        exit 0
        ;;
    *) echo "Invalid option, try again" ;;
    esac
}

#       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# loop to display menu and run tasks
while true; do
    display_menu
    run_task
done
