#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Runs the Plesk installer update command to apply all pending Plesk updates.
#
# Usage: plesk_update <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"
plesk_update() {
    local -n _result="${1}"

    if ! command -v plesk &>/dev/null; then
        _result="true"
        return
    fi

    clear

    local description_text_array=(
        "$(center_heading_text "Plesk Updates")\n\n"
        "We will now run the Plesk updates command 'plesk installer install-all-updates'. To run\n"
        "this command we will temporarily elevate the privileges to sudo.\n\n"
        "Are you Ready to run 'plesk installer install-all-updates'?\n\n"
        "1) yes\n"
        "2) no (skip step)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " plesk_answer
    printf "\n"
    clear_lines 1

    shopt -u nocasematch
    case $plesk_answer in
    1)
        clear
        printf "$(center_heading_text "Plesk Updates output below")\n\n"
        log_answer "running Plesk Updates" "yes"

        sudo plesk installer install-all-updates | tee -a "$logDir/apt-plesk-installer/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "Plesk Updates output above")\n\n"
        log_answer "completed running Plesk Updates" "automated"

        wait_for_input "Press any key when you are ready to go to the next step..."

        log_answer "user clicked the key to get to next step" "acknowledged prompt"

        _result="true"
        ;;
    2)
        clear_lines 1
        _result="true"
        log_answer "running Plesk Updates" "no, skip step"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
