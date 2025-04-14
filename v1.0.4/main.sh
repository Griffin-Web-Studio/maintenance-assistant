#!/bin/bash

maintenance_start_time=$(date +\%Y\%m\%d_\%H\%M)

logDir="$DIR/logs"

logFile="$logDir/maintenance-$maintenance_start_time.log"

# 'Dot' means 'source', i.e. 'include':
. "$DIR/utils/utils.sh"
. "$DIR/helpers/server-init.sh"
. "$DIR/helpers/task5.sh"
. "$DIR/helpers/task4.sh"
. "$DIR/helpers/task3.sh"
. "$DIR/helpers/task2.sh"
. "$DIR/helpers/task1.sh"

log_task "Started Maintenance script"

# check if there is an updates in the remote repo, pull new changes from git and restart script
check_for_updates() {
    clear

    log_task "check for updates ⌛"

    git -C $DIR fetch
    if [ "$(git -C "$DIR" rev-parse HEAD)" != "$(git -C "$DIR" rev-parse @{u})" ]; then

        printf "$(center_heading_text "Pulling New Updates 📥")\n\n"
        # pull new changes from git
        git -C $DIR pull

        wait_for_input "Press any key to restart script... 🔄️"

        up_to_date=true

        printf "$(center_heading_text "Updated Successfuly ✅")\n\n"

        # restart script
        exec "$DIR/main.sh"
    fi

    printf "$(center_heading_text "Already Up-to-date ✅")\n\n"
    wait_for_input "Press any key to start script... 💨"
    up_to_date=true
}

# function to display menu and ask user for input
display_menu() {
    clear

    log_task "display main menu"

    local description_text_array=(
        "$(center_heading_text "Welcome to GWS Maintenance V1" )\n\n"
        "This script will assist you with the maintenance of the GWS servers. Ensure to\n"
        "follow all applicable steps. Although running this script is optional, it's\n"
        "recommended for proper logging and to help diagnose any issues. It also allows\n"
        "us to track task and step durations for future optimization.\n\n"
    )
}

# function to run selected task or exit
run_task() {
    case $choice in
        0) run_init_0 ;;
        1) run_task_1 ;;
        2) run_task_2 ;;
        3) run_task_3 ;;
        4) run_task_4 ;;
        5)
            echo "[$(date)]: Exited program" >>$logFile
            exit 0
        ;;
        *) echo "Invalid option, try again" ;;
    esac
}

#       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# loop to display menu and run tasks
while [ "$up_to_date" != "true" ]; do
    check_for_updates
done

while true; do
    display_menu
    run_task
done
