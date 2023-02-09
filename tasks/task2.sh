#!/bin/bash
run_task_2() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7

    clear

    local task_description_text_array=(
        #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        "======================== Maintenance Updates & Upgrades ========================\n\n"
        "During this Task you will:\n\n"
        "1) Log the time of maintenance Start\n"
        "2) Updates\n"
        "   2.1) Update to ALL Server packages (optional after reboot),\n"
        "   2.2) Upgrade to ALL server packages (optional after reboot).\n"
        "        2.2.1) REBOOT\n"
        "   2.3 opt) Dist-upgrade\n"
        "        2.3.1) REBOOT\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    # function to log user answers
    log_answer() {
        echo "$(date): Task: Details Collection, Step $1, Answer: $2" >>$logFile
    }

    # function to ask user if they created a VPS snapshot
    ask_to_log_time() {
        clear
        echo "$(date): Started Task 2" >>$logFile
        description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "====================== Log the time of maintenance Start =======================\n\n"
            "current Date and Time is: $(date +\%H:\%M)\n\n"
            "Did you log the time?\n\n"
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
        echo "$(date): Started Task 1" >>$logFile
        description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "=================================== Updates ====================================\n\n"
            "We will now run updates command 'apt update -y', to run this command we will\n"
            "tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'apt update -y'?\n\n"
            "1) yes\n"
            "2) no\n"
            "3) no (after reboot)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " run_update_step_check

        shopt -u nocasematch
        case $run_update_step_check in
        1)
            printf "=========================== apt update output below ============================\n\n"
            log_answer "running apt update" "yes"
            sudo /bin/bash <<EOF
            apt update -y
EOF
            printf "=========================== apt update output above ============================\n\n"
            log_answer "compleated running apt update" "automated"

            read -n 1 -r -s -p "Press any key when you ready to go to the next step..." key
            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            answer_2=true
            ;;
        2)
            clear_lines 1
            answer_2=false
            log_answer "running apt update" "no"
            ;;
        3)
            clear_lines 1
            answer_2=true
            log_answer "running apt update" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }

    # function to ask user if they created a VPS snapshot
    run_upgrade_step() {
        clear
        echo "$(date): Started Task 1" >>$logFile
        description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "=================================== Upgrades ===================================\n\n"
            "We will now run upgrades command 'apt upgrade -y', to run this command we will\n"
            "tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'apt upgrade -y'?\n\n"
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
            printf "=========================== apt upgrade output below ===========================\n\n"
            log_answer "running apt upgrade" "yes"
            sudo /bin/bash <<EOF
            apt update -y
EOF
            printf "=========================== apt upgrade output above ===========================\n\n"
            log_answer "upgrade completed" "automated"

            read -n 1 -r -s -p "Press any key when you ready to go to the next step..." key
            log_answer "user clicked the key to get to next step" "aknowledged prompt"

            log_answer "compleated running apt upgrade" "yes"
            answer_3=true
            ;;
        2)
            clear_lines 1
            answer_3=false
            log_answer "running apt update" "no"
            ;;
        3)
            clear_lines 1
            answer_3=true
            log_answer "running apt update" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }

    # function to ask user if they created a VPS snapshot
    run_dit_upgrade_step() {
        clear
        echo "$(date): Started Task 1" >>$logFile
        description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "=================================== Dist Upgrade ===================================\n\n"
            "WARNING! RUNNING THIS COMMAND IS OPTIONAL AND CAN POTENTIALLY BREAK THE SYSTEM OR\n"
            "ITS DEPENDANCIES AND/OR PACKAGES!\n"
            "Please ensure that all packages are compatible with the new version of the distro!\n\n"
            "(OPT) We will now run dist upgrade command 'apt dist-upgrade -y', to run this\n"
            "command we will tempereraly elivate the privilages to sudo\n\n"
            "Are you Ready to run 'apt dist-upgrade'?\n\n"
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
            printf "======================== apt dist-upgrade output below =========================\n\n"
            log_answer "running apt dist-upgrade" "yes"
            sudo /bin/bash <<EOF
            apt-get dist-upgrade
EOF
            printf "======================== apt dist-upgrade output above =========================\n\n"

            printf "All Went Well? Do you wish to reboot?\n"
            printf "1) yes\n"
            printf "2) no\n\n"
            read -p "Possible answers (1/2): " problems_during_dist_upgrade

            shopt -u nocasematch # disable case-insensitive matching
            case $problems_during_dist_upgrade in
            1)
                clear_lines 20 $((line_count + 1))
                log_answer "completed dist-upgrade successfuly" "yes"
                answer_3=true
                reboot
                ;;
            2)
                printf "If there was a proble, DONT PANIC, you did afterall created a VPS snapsho\n"
                printf "and the backup. so restore the snapshot and skip this step\n\n"
                read -n 1 -r -s -p "Press any key when you ready to go to the next step..." key
                answer_3=false
                log_answer "completed dist-upgrade successfuly" "no"
                ;;
            *) echo "Invalid answer, please enter (1/2)" ;;
            esac
            ;;
        2)
            clear_lines 1
            answer_3=true
            log_answer "running apt dist-upgrade" "no"
            ;;
        3)
            clear_lines 1
            answer_3=true
            log_answer "running apt dist-upgrade" "no after reboot"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }

    #       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    # loop until user answers "yes" to both questions
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
        run_dit_upgrade_step
    done
}
