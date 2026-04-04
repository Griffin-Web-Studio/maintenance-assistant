#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Launches the btop load monitoring tool and waits for the operator to review.
# Prompts for confirmation before launching and logs the outcome.
#
# Usage: btop_monitor <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"
btop_monitor() {
    local -n _result="${1}"

    clear

    local description_text_array=(
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

    read -p "Possible answers (1/2): " btop_answer

    shopt -u nocasematch
    case $btop_answer in
    1)
        clear_lines 1
        log_answer "Started Load Monitoring software" "yes"
        _result="true"

        btop

        log_answer "completed Load Monitoring software" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Started Load Monitoring software" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
