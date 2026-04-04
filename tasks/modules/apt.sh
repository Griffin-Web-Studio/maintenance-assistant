#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Interactive APT package manager steps: update, upgrade, dist-upgrade, autoremove.
# Each function prompts for confirmation before running, logs output, and sets the
# caller's result variable to "true" when the step is complete or skipped.
# apt_upgrade and apt_dist_upgrade offer a skippable reboot prompt after running.
#
# Usage: apt_update <return_var>
#        apt_upgrade <return_var>
#        apt_dist_upgrade <return_var>
#        apt_autoremove <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"

apt_update() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Updates")\n\n"
        "We will now run the updates command 'sudo apt-get update -y'. To run this command we will\n"
        "temporarily elevate the privileges to sudo.\n\n"
        "Are you Ready to run 'sudo apt-get update -y'?\n\n"
        "1) yes\n"
        "2) no\n"
        "3) no (after reboot)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " apt_answer
    printf "\n"
    clear_lines 1

    shopt -u nocasematch
    case $apt_answer in
    1)
        clear
        printf "$(center_heading_text "sudo apt-get update output below")\n\n"
        log_answer "running sudo apt-get update" "yes"

        sudo apt-get update | tee -a "$logDir/apt-update/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "sudo apt-get update output above")\n\n"
        log_answer "completed running sudo apt-get update" "automated"

        wait_for_input "Press any key when you are ready to go to the next step..."

        log_answer "user clicked the key to get to next step" "acknowledged prompt"

        _result="true"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "running sudo apt-get update" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        log_answer "running sudo apt-get update" "no after reboot"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



apt_upgrade() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Upgrades")\n\n"
        "We will now run the upgrades command 'sudo apt-get upgrade -y'. To run this command we will\n"
        "temporarily elevate the privileges to sudo.\n\n"
        "Are you Ready to run 'sudo apt-get upgrade -y'?\n\n"
        "1) yes\n"
        "2) no\n"
        "3) no (after reboot)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " apt_answer

    shopt -u nocasematch
    case $apt_answer in
    1)
        clear
        printf "$(center_heading_text "sudo apt-get upgrade output below")\n\n"
        log_answer "running sudo apt-get upgrade" "yes"

        sudo apt-get upgrade | tee -a "$logDir/apt-upgrade/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "sudo apt-get upgrade output above")\n\n"
        log_answer "upgrade completed" "automated"

        wait_for_input "Press any key when you are ready to go to the next step..."

        log_answer "user clicked the key to get to next step" "acknowledged prompt"
        log_answer "completed running sudo apt-get upgrade" "yes"

        printf "All Went Well? Do you wish to reboot now?\n"
        printf "1) yes\n"
        printf "2) no (skip reboot, continue)\n\n"
        read -p "Possible answers (1/2): " reboot_answer

        shopt -u nocasematch
        case $reboot_answer in
        1)
            log_answer "completed package upgrade, rebooting" "yes"
            _result="true"
            reboot
            ;;
        2)
            clear_lines 1
            log_answer "completed package upgrade, reboot" "skipped"
            _result="true"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "running sudo apt-get upgrade" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        log_answer "running sudo apt-get upgrade" "no, after reboot"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



apt_autoremove() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Autoremove")\n\n"
        "We will now remove old packages that the OS knows are no longer needed.\n"
        "We will run 'sudo apt-get autoremove -y'.\n"
        "To run this command we will temporarily elevate the privileges to sudo.\n\n"
        "Are you Ready to run 'sudo apt-get autoremove -y'?\n\n"
        "1) yes\n"
        "2) no\n"
        "3) no (after reboot)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " apt_answer

    shopt -u nocasematch
    case $apt_answer in
    1)
        clear
        printf "$(center_heading_text "sudo apt-get autoremove output below")\n\n"
        log_answer "running sudo apt-get autoremove" "yes"

        sudo apt-get autoremove | tee -a "$logDir/apt-autoremove/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "sudo apt-get autoremove output above")\n\n"
        log_answer "autoremove completed" "automated"

        wait_for_input "Press any key when you are ready to go to the next step..."

        log_answer "user clicked the key to get to next step" "acknowledged prompt"
        log_answer "completed running sudo apt-get autoremove" "yes"

        _result="true"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "running sudo apt-get autoremove" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        log_answer "running sudo apt-get autoremove" "no after reboot"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



apt_dist_upgrade() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Dist Upgrade")\n\n"
        "WARNING! RUNNING THIS COMMAND IS OPTIONAL AND CAN POTENTIALLY BREAK THE SYSTEM OR\n"
        "ITS DEPENDANCIES AND/OR PACKAGES!\n"
        "Please ensure that all packages are compatible with the new version of the distro!\n\n"
        "(OPT) We will now run the dist-upgrade command 'sudo apt-get dist-upgrade -y'. To run this\n"
        "command we will temporarily elevate the privileges to sudo.\n\n"
        "Are you Ready to run 'sudo apt-get dist-upgrade'?\n\n"
        "1) yes\n"
        "2) no\n"
        "3) no (after reboot)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " apt_answer

    shopt -u nocasematch
    case $apt_answer in
    1)
        clear
        printf "$(center_heading_text "sudo apt-get dist-upgrade output below")\n\n"
        log_answer "running sudo apt-get dist-upgrade" "yes"

        sudo apt-get dist-upgrade | tee -a "$logDir/apt-dist-upgrade/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "sudo apt-get dist-upgrade output above")\n\n"
        log_answer "dist-upgrade completed" "automated"

        printf "All Went Well? Do you wish to reboot now?\n"
        printf "1) yes\n"
        printf "2) no (skip reboot, continue)\n\n"
        read -p "Possible answers (1/2): " reboot_answer

        shopt -u nocasematch
        case $reboot_answer in
        1)
            log_answer "completed dist-upgrade, rebooting" "yes"
            _result="true"
            reboot
            ;;
        2)
            clear_lines 1
            log_answer "completed dist-upgrade, reboot" "skipped"
            _result="true"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
        ;;
    2)
        clear_lines 1
        _result="true"
        log_answer "running sudo apt-get dist-upgrade" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        log_answer "running sudo apt-get dist-upgrade" "no after reboot"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}
