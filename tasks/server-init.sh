#!/bin/bash
run_init_0() {
    local answer_1
    local answer_99
    local task_name="Init: Server Initialiser"



    # Step to change root password for something more secure
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
        printf "work, hit \"Ctr + C\" and use \"passwd root\" command to change the password again.\n\n"

        wait_for_input "Press any key when you finished test the password..."
    }



    # Step to configure SSHD, prevent root password login with root
    check_sshd_config() {
        clear
        
        description_text_array=(
            #********************************************************************************.\n
            "$(center_heading_text "SSH Server")\n\n"

            "Nice work! Now let make sure the serer security configurations and just security\n"
            "in general is in good order, first we must must check the ssh configurations.\n\n"

            "When a nano editor will open, you must make sure that two configs are as below.\n"
            "Feel free to copy them.\n"
            "NOTE: that they may be on different lines from each other, however always in the\n"
            "same file):\n\n"

            "    PermitRootLogin without-password\n"
            "    PasswordAuthentication no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        wait_for_input "Press any key when you are ready..."

        sudo nano /etc/ssh/sshd_config

        wait_for_input "Press any key to restart the SSH Server..."

        sudo service sshd restart
        sudo service ssh restart

        wait_for_input "Press any key when you are ready to proceed to next task..."
    }



    set_locale_and_timezone() {
        clear
        
        description_text_array=(
            #********************************************************************************.\n
            "$(center_heading_text "Set The Clock & Locale")\n\n"
            "Now let's set the clock to the correct region.\n\n"

            "When we begin, first we will set the correct timezone per server location.\n"
            "Then we will set the correct locale which will always be English GB.\n\n"

            "The current Local and Time configurations are:\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Current Time & Timezone:\n"
        timedatectl

        printf "\n\nCurrent Locale:\n"
        lcoale

        wait_for_input "\n\nPress any key when you are ready to set timezone..."
        
        read -p "please Specify the timezone (default: Europe/London): " set_timezone_string

        shopt -u nocasematch
        case $set_timezone_string in
            "")
                timedatectl set-timezone Europe/London
                ;;
            *)
                timedatectl set-timezone "$set_timezone_string"
                ;;
        esac

        printf "\n\n$(center_heading_text "Here is the new Timezone values")\n\n"

        printf "\nCurrent Time & Timezone:\n"
        timedatectl

        wait_for_input "\n\nPress any key when you are ready to set locale..."

        printf "\n$(center_heading_text "Enabling Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        sudo sed -i '/^#.*en_GB.UTF-8 UTF-8/s/^#//' /etc/locale.gen

        printf "\n$(center_heading_text "Generating Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        locale-gen en_GB.UTF-8

        printf "\n$(center_heading_text "Updating Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        update-locale en_GB.UTF-8 UTF-8

        printf "\n$(center_heading_text "Updating Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        sudo localectl set-locale LANG=en_GB.UTF-8 LANGUAGE=en_GB:en LC_ALL=en_GB.UTF-8

        wait_for_input "\n\nOk Everything as it should be?\nIf so press any key when you are ready to reboot..."

        sudo reboot
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

    # MAIN ================================================================================

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



    read -p "Possible answers (n/no/2): " first_reboot

    shopt -u nocasematch
    case $first_reboot in
        n|no|2)
            while [ "$answer_1" != "true" ]; do
                change_root_password
            done

            check_sshd_config
            set_locale_and_timezone
            ;;
    esac
    

    while [ "$answer_99" != "true" ]; do
        complete_step
    done
}
