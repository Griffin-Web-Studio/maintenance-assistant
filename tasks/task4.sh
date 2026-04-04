#!/bin/bash
. "$DIR/scripts/helpers/change_password.sh"
. "$DIR/scripts/helpers/check_sshd_config.sh"

run_task_4() {
    local answer_1
    local answer_2
    local answer_2b
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Maintenance: Server Security"
    local CURRENT_USER=$(whoami)

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will look to ensure all of the server security is in place\n"
        "and still does what we expect it to.\n\n"
        "What steps to expect in this task:\n"
        "1) Check SSH Configuration\n"
        "2) Change root password\n"
        "3) Run Antivirus\n"
        "\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 4)"



    # Step to enforce SSH config (shared helper — skip allowed, no key setup needed)
    check_sshd_config() {
        check_sshd_config_step "answer_1" "$CURRENT_USER" "true" "false"
    }



    # Steps to change passwords for root and the current service user
    change_root_password() {
        change_password_step "answer_2" "root"
    }

    change_service_user_password() {
        change_password_step "answer_2b" "$CURRENT_USER"
    }



    # function to update virus definitions and launch a background antivirus scan
    run_antivirus() {
        clear

        description_text_array=(
            "$(center_heading_text "Run Antivirus")\n\n"
            "Now we will run an antivirus and keep it running in the background.\n"
            "Logs will be present here: $logDir/antivirus/log-run-$maintenance_start_time.log\n\n"
            "use for live updates: \e[5mtail -f -n 30 $logDir/antivirus/log-run-$maintenance_start_time.log\e[0m\n\n"
            "Ready To Start Antivirus Check?\n\n"
            "1) yes\n"
            "2) no (skip)\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " log_main_start_time

        shopt -u nocasematch
        case $log_main_start_time in
        1)
            log_answer "Running Antivirus" "yes"

            sudo systemctl stop clamav-freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

            sudo freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

            sudo systemctl start clamav-freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

            sudo screen -dm -S virusscan clamscan -ri -l "$logDir/antivirus/log-run-$maintenance_start_time.log" /

            log_answer "Run Antivirus" "yes"

            answer_3=true
            ;;
        2)
            clear
            log_answer "Running Antivirus" "no"

            answer_3=true
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 4 Completed ✅")\n\n"
            "Nice Work! The task 4 is now complete!\n\n"
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

            run_task_5
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
        check_sshd_config
    done

    while [ "$answer_2" != "true" ]; do
        change_root_password
    done

    while [ "$answer_2b" != "true" ]; do
        change_service_user_password
    done

    while [ "$answer_3" != "true" ]; do
        run_antivirus
    done

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
