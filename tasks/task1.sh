#!/bin/bash
. "$DIR/tasks/modules/backup.sh"
. "$DIR/tasks/modules/server_info.sh"

run_task_1() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Details Collection (Legacy)"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this Task you will be required to collect the information about the\n"
        "server you are maintaining and ensure all data is backed up before real work\n"
        "begins.\n\n"
    )

    local backup_description_text_array=(
        "$(center_heading_text "Initiating Backup")\n\n"
        "To begin with lets create two backups, first the VPS snapshot, then the server\n"
        "backup. Please follow these steps:\n\n"
        "1) You must log in to the IONOS ISP, and select Control Panel for this Server.\n"
        "   This server can be identified as $(hostname).\n"
        "   Then you need to create a new complete snapshot of the VPS\n"
        "   THIS IS ESSENTIAL IN CASE SOMETHING GOES WRONG!\n\n"
        "2) Log in to the server Control Panel (Plex) via the link (skip if not managed\n"
        "   by Plesk): https://$(hostname).gwssecureserver.co.uk:8443\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 1)"



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 1 Completed ✅")\n\n"
            "Nice Work! The task 1 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
            "Do you want to go straight to next task?\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " nav_answer

        case $nav_answer in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_2
            ;;
        2)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go back to Main Menu"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    while [ "$answer_1" != "true" ]; do
        backup_vps_snapshot "answer_1"
    done

    while [ "$answer_2" != "true" ]; do
        backup_server_initiate "answer_2"
    done

    while [ "$answer_3" != "true" ]; do
        server_info_motd_copy "answer_3"
    done

    while [ "$answer_4" != "true" ]; do
        server_info_details_copy "answer_4"
    done

    while [ "$answer_5" != "true" ]; do
        backup_vps_snapshot_verify "answer_5"
    done

    while [ "$answer_6" != "true" ]; do
        backup_server_verify "answer_6"
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
