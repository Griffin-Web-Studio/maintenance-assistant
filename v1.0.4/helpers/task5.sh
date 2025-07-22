#!/bin/bash
run_task_5() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Maintenance: Compleation"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will log the end of maintenance time.\n"
        "\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Task: $task_name (Task 5)" >>$logFile



    # function to ask user if they created a VPS snapshot
    ask_to_log_time() {
        clear

        description_text_array=(
            #********************************************************************************.\n
            "$(center_heading_text "SSH Server")\n\n"
            "Well Done! You made it! Here is the current Time:\n\n"
            "Current Date and Time is: $(date +\%H:\%M)\n\n"
            "Did you log the time?\n\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        log_answer "Log the time of maintenance end" "current Date and Time is: $(date +\%H:\%M)"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            clear_lines 1
            answer_1=true
            log_answer "Loged the time of maintenance end" "yes"
            ;;
        2)
            clear_lines 1
            answer_1=false
            log_answer "Loged the time of maintenance end" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to ask user if they completed the backup process
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Maintenance Completed ✅")\n\n"
            "Great Work! You have compleated the final task 5 and the maintenance is now\n"
            "complete! You now have a choice of either ending the maintenance script or\n"
            "going back to the main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to end Maitnenance script?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to exit maintenance: yes"
            log_task "Exited program"
            exit 0
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
        ask_to_log_time
    done

    # while [ "$answer_2" != "true" ]; do
    #     change_root_password
    # done

    # while [ "$answer_3" != "true" ]; do
    #     run_upgrade_step
    # done

    # while [ "$answer_4" != "true" ]; do
    #     run_autoremove_step
    # done

    # while [ "$answer_5" != "true" ]; do
    #     run_dist_upgrade_step
    # done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
