#!/bin/bash
run_task_4() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Maintenance: Server Security"

    clear

    local task_description_text_array=(
        "$(center_heading_text "some text here")\n\n"
        "PLACEHOLDER\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Task: $task_name (Task 3)" >>$logFile



    # function to ask user if they created a VPS snapshot
    initiate_monitoring_soft() {
        clear
        description_text_array=(
            "$(center_heading_text "Start load Monitoring")\n\n"
            "We will initiate a Load Monitoring software, please monitor it for about 5 min\n"
            "and report any findings on the wiki website.\n\n"
            "Are you Ready to start Load Monitorig soft?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            clear_lines 1
            log_answer "Started Load Monitorig soft" "yes"

            sudo gotop-cjbassi

            log_answer "compleated Load Monitorig soft" "yes"
            answer_1=true
            ;;
        2)
            clear_lines 1
            answer_1=false
            log_answer "Started Load Monitorig soft" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to ask user if they completed the backup process
    run_disk_check() {
        clear
        description_text_array=(
            "$(center_heading_text "Start SMART Disk check")\n\n"
            "We will initiate a SMART Disk software, please monitor it for about 5 min\n"
            "and report any findings on the wiki website.\n\n"
            "Are you running a virtualised Server aka VPS?\n\n"
            "1) yes (skip)\n"
            "2) no\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            clear_lines 1
            answer_2=true
            log_answer "Skipping SMART Information collection" "yes"
            ;;
        2)
            clear
            log_answer "Started SMART Information collection" "yes"

            printf "$(center_heading_text "SMART Information collection output below")\n\n"

            sudo smartctl -a /dev/sda
            
            printf "\n$(center_heading_text "SMART Information collection output above")\n\n"
            log_answer "compleated SMART Information collection" "yes"

            log_answer "Started Short SMART Tests" "yes"
            printf "$(center_heading_text "Short SMART Tests output below")\n\n"

            sudo smartctl -t short /dev/sda

            wait_for_input "Press any key to check status..."

            sudo smartctl -a /dev/sda

            printf "\n$(center_heading_text "Short SMART Tests output above")\n\n"
            log_answer "compleated Short SMART Tests" "yes"

            log_answer "Started Long SMART Tests" "yes"
            printf "$(center_heading_text ""Long SMART Tests output below)\n\n"

            sudo smartctl -t long /dev/sda

            wait_for_input "Press any key to check status..."

            sudo smartctl -a /dev/sda

            printf "\n$(center_heading_text "Long SMART Tests output above")\n\n"
            log_answer "compleated Long SMART Tests" "yes"
            answer_2=true
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to ask user if they completed the backup process
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 3 Completed ✅")\n\n"
            "Nice Work! The task 3 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to go straight to next task?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_4
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
        initiate_monitoring_soft
    done

    while [ "$answer_2" != "true" ]; do
        run_disk_check
    done

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
