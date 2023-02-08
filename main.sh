#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# 'Dot' means 'source', i.e. 'include':
. "$DIR/task1.sh"

maintenanceStartTime=$(date +\%Y\%m\%d_\%H\%M)

logFile="$DIR/logs/maintenance-$maintenanceStartTime.log"

# clear screen
clear

clear_lines() {
    # -1 because also need remove current line
    for ((i = 0; i < $1; i++)); do
        tput cuu 1 && tput el
        #    echo -e "\e[1A\e[K"
    done
}

# function to display menu and ask user for input
display_menu() {
    printf "Server Maintenance Menu:\n"
    printf "==========================\n"
    printf "1. Maintenance Preperation\n"
    printf "==========================\n"
    printf "4. Exit\n\n"
    read -p "Enter your choice [1-4]: " choice
}

# function to run selected task or exit
run_task() {
    if [ ! -d "$DIR/logs" ]; then
        mkdir -p $DIR/logs
    fi
    echo "$(date): Started Task 1" >>$logFile

    case $choice in
    1)
        echo "$(date): Started Task 1" >>$logFile
        run_task_1 $logFile
        # clear_lines 10
        echo "$(date): Finished Task 1" >>$logFile
        ;;
    2)
        echo "$(date): Started Task 2" >>$logFile
        ./task2.sh
        echo "$(date): Finished Task 2" >>$logFile
        ;;
    3)
        echo "$(date): Started Task 3" >>$logFile
        ./task3.sh
        echo "$(date): Finished Task 3" >>$logFile
        ;;
    4)
        echo "$(date): Exited program" >>$logFile
        exit 0
        ;;
    *) echo "Invalid option, try again" ;;
    esac
}

printf "\n"
printf "               >>01000111010101110101001100100000010011010010000000110\n"
printf "              >1   _______       ________                          00\n"
printf "             00   / ____/ |     / / ____/    MaiNt  aNCE          00\n"
printf "            01   / / __ | | /| / /\__ \      MAi tEnA CE         01\n"
printf "           10   / /_/ / | |/ |/ /___/ /      MA   En  CE        10\n"
printf "          00    \____/  |__/|__/_____/       MA       CE 01    00\n"
printf "         00                                                   1<\n"
printf "        01100000001001011001000000100110010101110101011100010<<\n\n" #slant

#       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
printf "======================== Welcome to GWS Maintenance 01! ========================\n\n"
printf "This script will assist you with the maintenance of the GWS servers. Ensure to\n"
printf "follow all applicable steps. Although running this script is optional, it's\n"
printf "recommended for proper logging and to help diagnose any issues. It also allows\n"
printf "us to track task and step durations for future optimization.\n\n"

# loop to display menu and run tasks
while true; do
    display_menu
    run_task
done
