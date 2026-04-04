#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Prompts the operator to reboot the server. The reboot is skippable — choosing
# to skip simply continues to the next step without rebooting.
#
# Usage: reboot_request <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"
reboot_request() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Reboot")\n\n"
        "It is recommended to reboot the server now to apply all pending updates.\n\n"
        "Would you like to reboot the server now?\n\n"
        "1) yes\n"
        "2) no (skip reboot, continue)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " reboot_answer

    shopt -u nocasematch
    case $reboot_answer in
    1)
        log_answer "Reboot requested" "yes"
        _result="true"
        sudo reboot
        ;;
    2)
        clear_lines 1
        log_answer "Reboot requested" "skipped"
        _result="true"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
