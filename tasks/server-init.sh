#!/bin/bash
run_init_0() {
    local answer_1
    local answer_2
    local answer_99
    local task_name="Init: Server Initialiser"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will initialise the new server and prep it for work.\n\n"
        "What steps to expect in this task:\n"
        "1) Change root password\n"
        "2) Check SSH Configuration\n"
        "3) Run Antivirus\n"
        "\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    change_root_password() {
        clear

        description_text_array=(
            "$(center_heading_text "Change Root Password")\n\n"
            "Now we will change the root password for best security.\n"
            "You will now be provided with 5 random passwords to choose from:\n\n"
            "1) $(generate_password 230)\n\n"
            "2) $(generate_password 230)\n\n"
            "3) $(generate_password 230)\n\n"
            "4) $(generate_password 230)\n\n"
            "5) $(generate_password 230)\n\n"
            "PLEASE COPY ONE OF THE PASSWORDS ABOVE and test it in an editor to make sure you\n"
            "didn't copy empty sstring\n\n"
            "Ready To Change the Password?\n\n"
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
            sudo passwd root

            answer_1=true
            ;;
        2)
            clear

            answer_1=true
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac

        printf "\n$(center_heading_text "Test Password")\n\n"

        printf "Now open a new terminal window, reconnect and try the new password, if it didn't"
        printf "work, hit \"Ctr + C\" and use \"passwd\" command to change the password again.\n\n"

        wait_for_input "Press any key when you finished test the password..."
    }



    # function to ask user if they created a VPS snapshot
    check_sshd_config() {
        clear
        
        description_text_array=(
            #********************************************************************************.\n
            "$(center_heading_text "SSH Server")\n\n"
            "Nice work! Now let make sure the serer security configurations and just security\n"
            "in general is in good order, first we must must check the ssh configurations.\n\n"

            "When you say YES, a nano editor will open, in there you must make sure that\n"
            "These two configs are like this, feel free to copy them (PLEASE NOTE that they\n"
            "may be on different lines from each other, however always in the same file):\n\n"
            "    PermitRootLogin without-password\n"
            "    PasswordAuthentication no\n\n"
            "Do you wish to proceed (we will tempereraly elivate your privilaes to sudo)?\n\n"
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
            clear_lines 1

            sudo nano /etc/ssh/sshd_config

            wait_for_input "Press any key to restart the SSH Server..."

            sudo service sshd restart

            answer_2=true
            ;;
        2)
            clear_lines 1
            answer_2=true
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    # function to ask user if they completed the backup process
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 0 Completed ✅")\n\n"
            "Nice Work! The Server is now initialised!\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        wait_for_input "Hit any key to end task..."
        answer_99=true
    }



    while [ "$answer_1" != "true" ]; do
        change_root_password
    done

    while [ "$answer_2" != "true" ]; do
        check_sshd_config
    done

    while [ "$answer_99" != "true" ]; do
        complete_step
    done
}
