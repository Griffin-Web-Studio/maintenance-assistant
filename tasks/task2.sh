#!/bin/bash
. "$DIR/tasks/modules/maintenance_log.sh"
. "$DIR/tasks/modules/apt.sh"
. "$DIR/tasks/modules/plesk.sh"
. "$DIR/tasks/modules/unattended_upgrades.sh"
. "$DIR/tasks/modules/reboot.sh"

run_task_2() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local answer_8
    local answer_9
    local task_name="Maintenance Updates & Upgrades"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this Task you will:\n\n"
        "1) Log the time of Maintenance Start\n"
        "2) Updates\n"
        "   2.1) Update to ALL Server packages (optional after reboot),\n"
        "   2.2) Upgrade to ALL server packages (optional after reboot).\n"
        "   2.3 opt) Dist-upgrade\n"
        "   2.4) Plesk Updates\n"
        "   2.5) Remove old and unused packages\n"
        "   2.6) Unattended Upgrades (install & configure if not present)\n"
        "   2.7) Reboot\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 2)"



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 2 Completed ✅")\n\n"
            "Nice Work! The task 2 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to go straight to next task?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " nav_answer

        case $nav_answer in
        1)
            answer_9=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_3
            ;;
        2)
            answer_9=true

            log_task "Task $task_name: completed"
            log_task "User chose to go back to Main Menu"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    while [ "$answer_1" != "true" ]; do
        maintenance_log_start_time "answer_1"
    done

    while [ "$answer_2" != "true" ]; do
        apt_update "answer_2"
    done

    while [ "$answer_3" != "true" ]; do
        apt_upgrade "answer_3"
    done

    while [ "$answer_4" != "true" ]; do
        apt_dist_upgrade "answer_4"
    done

    while [ "$answer_5" != "true" ]; do
        plesk_update "answer_5"
    done

    while [ "$answer_6" != "true" ]; do
        apt_autoremove "answer_6"
    done

    while [ "$answer_7" != "true" ]; do
        unattended_upgrades_setup "answer_7" \
            "$logDir/apt-update/log-$maintenance_start_time.log"
    done

    while [ "$answer_8" != "true" ]; do
        reboot_request "answer_8"
    done

    while [ "$answer_9" != "true" ]; do
        complete_step
    done
}
