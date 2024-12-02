#!/bin/bash
run_task_2() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Maintenance Updates & Upgrades"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this Task you will:\n\n"
        "1) Log the time of Maintenance Start\n"
        "2) Updates\n"
        "   2.1) Update to ALL Server packages (optional after reboot),\n"
        "   2.2) Upgrade to ALL server packages (optional after reboot).\n"
        "   2.3) Remove old and unused packages\n"
        "        2.3.1) REBOOT\n"
        "   2.4 opt) Dist-upgrade\n"
        "        2.4.1) REBOOT\n"
        "   2.5) Plesk Updates\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 2)"



    # function to ask user if they created a VPS snapshot
    ask_to_log_time() {
        clear
        description_text_array=(
            "$(center_heading_text "Log the time of maintenance Start")\n\n"
            "current Date and Time is: $(date +\%H:\%M)\n\n"
            "Did you log the time?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        log_answer "Log the time of maintenance Start" "current Date and Time is: $(date +\%H:\%M)"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            clear_lines 1
            answer_1=true
            log_answer "Loged the time of maintenance" "yes"
            ;;
        2)
            clear_lines 1
            answer_1=false
            log_answer "Loged the time of maintenance" "no"
            ;;
        3)
            clear_lines 1
            answer_1=true
            log_answer "Loged the time of maintenance" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they created a VPS snapshot
    run_update_step() {
        clear

        description_text_array=(
            "$(center_heading_text "Updates")\n\n"
            "We will now run updates command 'sudo apt-get update -y', to run this command we will\n"
            "tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'sudo apt-get update -y'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_update_step_check
        printf "\n"
        clear_lines 1

        shopt -u nocasematch
        case $run_update_step_check in
        1)
            clear
            printf "$(center_heading_text "sudo apt-get update output below")\n\n"
            log_answer "running sudo apt-get update" "yes"

            sudo apt-get update | tee -a "$logDir/apt-update/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "sudo apt-get update output above")\n\n"
            log_answer "compleated running sudo apt-get update" "automated"

            wait_for_input "Press any key when you ready to go to the next step..."

            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            answer_2=true
            ;;
        2)
            clear_lines 1
            answer_2=false
            log_answer "running sudo apt-get update" "no"
            ;;
        3)
            clear_lines 1
            answer_2=true
            log_answer "running sudo apt-get update" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they created a VPS snapshot
    run_upgrade_step() {
        clear

        description_text_array=(
            "$(center_heading_text "Upgrades")\n\n"
            "We will now run upgrades command 'sudo apt-get upgrade -y', to run this command we will\n"
            "tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'sudo apt-get upgrade -y'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_upgrade_step_check

        shopt -u nocasematch
        case $run_upgrade_step_check in
        1)
            clear
            printf "$(center_heading_text "sudo apt-get upgrade output below")\n\n"
            log_answer "running sudo apt-get upgrade" "yes"

            sudo apt-get upgrade | tee -a "$logDir/apt-upgrade/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "sudo apt-get upgrade output above")\n\n"
            log_answer "upgrade completed" "automated"

            wait_for_input "Press any key when you ready to go to the next step..."

            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            log_answer "compleated running sudo apt-get upgrade" "yes"

            printf "All Went Well? Do you wish to reboot?\n"
            printf "1) yes\n"
            printf "2) no\n\n"
            read -p "Possible answers (1/2): " problems_during_package_upgrade

            shopt -u nocasematch # disable case-insensitive matching
            case $problems_during_package_upgrade in
            1)
                log_answer "completed package upgrade successfuly" "yes"
                answer_3=true
                reboot
                ;;
            2)
                printf "If there was a problem, DONT PANIC, you did afterall create a VPS snapshot and\n"
                printf "the backup. so restore the snapshot and skip this step unless this is fixable.\n\n"

                wait_for_input "Make sure to download ALL RELEVANT LOGS before you revert to snapshot!..."
                
                answer_3=false
                log_answer "completed package upgrade successfuly" "no"
                exit 0
                ;;
            *) echo "Invalid answer, please enter (1/2)" ;;
            esac
            ;;
        2)
            clear_lines 1
            answer_3=false
            log_answer "running sudo apt-get update" "no"
            ;;
        3)
            clear_lines 1
            answer_3=true
            log_answer "running sudo apt-get update" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they created a VPS snapshot
    run_autoremove_step() {
        clear

        description_text_array=(
            "$(center_heading_text "Autoremove")\n\n"
            "We will now run autoremove for old packages that os knows wont be needed command.\n"
            "We will now run 'sudo apt-get autoremove -y'.\n"
            "To run this command we will tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'sudo apt-get autoremove -y'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_autoremove_step_check

        shopt -u nocasematch
        case $run_autoremove_step_check in
        1)
            clear
            printf "$(center_heading_text "sudo apt-get autoremove output below")\n\n"
            log_answer "running sudo apt-get autoremove" "yes"

            sudo apt-get autoremove | tee -a "$logDir/apt-autoremove/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "sudo apt-get autoremove output above")\n\n"
            log_answer "autoremove completed" "automated"

            wait_for_input "Press any key when you ready to go to the next step..."
            
            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            log_answer "compleated running sudo apt-get autoremove" "yes"
            answer_4=true
            ;;
        2)
            clear_lines 1
            answer_4=false
            log_answer "running sudo apt-get autoremove" "no"
            ;;
        3)
            clear_lines 1
            answer_4=true
            log_answer "running sudo apt-get autoremove" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they created a VPS snapshot
    run_dist_upgrade_step() {
        clear
        
        description_text_array=(
            "$(center_heading_text "Dist Upgrade")\n\n"
            "WARNING! RUNNING THIS COMMAND IS OPTIONAL AND CAN POTENTIALLY BREAK THE SYSTEM OR\n"
            "ITS DEPENDANCIES AND/OR PACKAGES!\n"
            "Please ensure that all packages are compatible with the new version of the distro!\n\n"
            "(OPT) We will now run dist upgrade command 'sudo apt-get dist-upgrade -y', to run this\n"
            "command we will tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'sudo apt-get dist-upgrade'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_dist_upgrade_step_check

        shopt -u nocasematch
        case $run_dist_upgrade_step_check in
        1)
            clear
            printf "$(center_heading_text "sudo apt-get dist-upgrade output below")\n\n"
            log_answer "running sudo apt-get dist-upgrade" "yes"

            sudo apt-get dist-upgrade | tee -a "$logDir/apt-dist-upgrade/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "sudo apt-get dist-upgrade output above")\n\n"
            log_answer "dist-upgrade completed" "automated"

            printf "All Went Well? Do you wish to reboot?\n"
            printf "1) yes\n"
            printf "2) no\n\n"
            read -p "Possible answers (1/2): " problems_during_dist_upgrade

            shopt -u nocasematch # disable case-insensitive matching
            case $problems_during_dist_upgrade in
            1)
                clear_lines 20 $((line_count + 1))
                log_answer "completed dist-upgrade successfuly" "yes"
                answer_5=true
                reboot
                ;;
            2)
                printf "If there was a problem, DONT PANIC, you did afterall create a VPS snapshot and\n"
                printf "the backup. so restore the snapshot and skip this step unless this is fixable.\n\n"

                wait_for_input "Make sure to download ALL RELEVANT LOGS before you revert to snapshot!..."
                
                answer_5=false
                log_answer "completed dist-upgrade successfuly" "no"
                exit 0
                ;;
            *) echo "Invalid answer, please enter (1/2)" ;;
            esac
            ;;
        2)
            clear_lines 1
            answer_5=true
            log_answer "running sudo apt-get dist-upgrade" "no"
            ;;
        3)
            clear_lines 1
            answer_5=true
            log_answer "running sudo apt-get dist-upgrade" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they created a VPS snapshot
    run_plesk_update_step() {
        clear

        description_text_array=(
            "$(center_heading_text "Plesk Updates")\n\n"
            "We will now run Plesk updates command 'plesk installer install-all-updates', to run\n"
            "this command we will tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'plesk installer install-all-updates'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (skip step)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_update_step_check
        printf "\n"
        clear_lines 1

        shopt -u nocasematch
        case $run_update_step_check in
        1)
            clear
            printf "$(center_heading_text "Plesk Updates output below")\n\n"
            log_answer "running Plesk Updates" "yes"

            sudo plesk installer install-all-updates | tee -a "$logDir/apt-plesk-installer/log-$maintenance_start_time.log"

            printf "\n$(center_heading_text "Plesk Updates output above")\n\n"
            log_answer "compleated running Plesk Updates" "automated"

            wait_for_input "Press any key when you ready to go to the next step..."

            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            answer_6=true
            ;;
        2)
            clear_lines 1
            answer_6=false
            log_answer "running Plesk Updates" "no"
            ;;
        3)
            clear_lines 1
            answer_6=true
            log_answer "running Plesk Updates" "no askip step"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }



    # function to ask user if they completed the backup process
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
        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_3
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

    while [ "$answer_2" != "true" ]; do
        run_update_step
    done

    while [ "$answer_3" != "true" ]; do
        run_upgrade_step
    done

    while [ "$answer_4" != "true" ]; do
        run_autoremove_step
    done

    while [ "$answer_5" != "true" ]; do
        run_dist_upgrade_step
    done

    while [ "$answer_6" != "true" ]; do
        run_plesk_update_step
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
