#!/bin/bash
run_task_3() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Maintenance: Server Load & Stress Monitoring"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will monitor server load and check the health of all disks\n"
        "using SMART diagnostics. Report any findings on the wiki.\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 3)"



    # function to launch the load monitoring tool
    initiate_monitoring_soft() {
        clear
        description_text_array=(
            "$(center_heading_text "Load Monitoring")\n\n"
            "We will launch the Load Monitoring software. Please monitor it for about 5 minutes\n"
            "and report any findings on the wiki.\n\n"
            "Are you ready to start the Load Monitoring software?\n\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            clear_lines 1
            log_answer "Started Load Monitoring software" "yes"
            answer_1=true

            btop

            log_answer "completed Load Monitoring software" "yes"
            ;;
        2)
            clear_lines 1
            answer_1=false
            log_answer "Started Load Monitoring software" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to run SMART disk health checks
    run_disk_check() {
        clear
        description_text_array=(
        #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "$(center_heading_text "Start SMART Disk check")\n\n"
            "We will run SMART disk diagnostics. Please review the results\n"
            "and report any findings on the wiki.\n\n"
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
            # Collect Smart Current Smart Info
            clear
            log_answer "Started SMART Information collection" "yes"

            printf "$(center_heading_text "SMART Information collection output below")\n\n"

            sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/info/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "SMART Information collection output above")\n\n"

            wait_for_input "Press any key when you finished copying the info above..."
            clear

            log_answer "completed SMART Information collection" "yes"

            # Collect Short Smart Info
            ## initiate short test
            sudo smartctl -t short /dev/sda | tee -a "$logDir/SMART/short/log-$maintenance_start_time.log"
            log_answer "Started Short SMART Tests" "yes"

            wait_for_input "Press any key to check status..."

            ## get short test result
            printf "$(center_heading_text "Short SMART Tests output below")\n\n"

            sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/short/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "Short SMART Tests output above")\n\n"

            wait_for_input "Press any key when you finished copying the info above..."
            clear

            log_answer "completed Short SMART Tests" "yes"

            # Collect Long Smart Info
            ## initiate long test
            sudo smartctl -t long /dev/sda | tee -a "$logDir/SMART/long/log-$maintenance_start_time.log"
            log_answer "Started Long SMART Tests" "yes"

            wait_for_input "Press any key to check status..."

            ## get long test result
            printf "$(center_heading_text "Long SMART Tests output below")\n\n"

            sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/long/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "Long SMART Tests output above")\n\n"

            log_answer "completed Long SMART Tests" "yes"
            wait_for_input "Press any key when you finished copying the info above..."
            answer_2=true
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to show completion screen and ask user what to do next
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
