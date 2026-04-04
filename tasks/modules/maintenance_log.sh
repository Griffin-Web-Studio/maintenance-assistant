#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Prompts the operator to log the maintenance start or end time.
#
# Usage: maintenance_log_start_time <return_var>
#        maintenance_log_end_time <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"

maintenance_log_start_time() {
    local -n _result="${1}"

    clear

    local description_text_array=(
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

    read -p "Possible answers (1/2/3): " time_answer

    shopt -u nocasematch
    case $time_answer in
    1)
        clear_lines 1
        _result="true"
        log_answer "Logged the time of maintenance" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Logged the time of maintenance" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        log_answer "Logged the time of maintenance" "no, after reboot"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



maintenance_log_end_time() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Log Maintenance End Time")\n\n"
        "Well done! You made it! Here is the current time:\n\n"
        "Current Date and Time is: $(date +\%H:\%M)\n\n"
        "Did you log the time?\n\n"
        "1) yes\n"
        "2) no\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    log_answer "Log the time of maintenance end" "current Date and Time is: $(date +\%H:\%M)"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " time_answer

    shopt -u nocasematch
    case $time_answer in
    1)
        clear_lines 1
        _result="true"
        log_answer "Logged the time of maintenance end" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Logged the time of maintenance end" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
