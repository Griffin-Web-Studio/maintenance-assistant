#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Interactive backup confirmation steps: VPS snapshot and server backup.
# Each pair covers initiation (did you start it?) and verification (is it done?).
#
# Usage: backup_vps_snapshot <return_var>
#        backup_vps_snapshot_verify <return_var>
#        backup_server_initiate <return_var>
#        backup_server_verify <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"

backup_vps_snapshot() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "VPS Snapshot")\n\n"
        "Did you create a VPS snapshot?\n"
        "1) yes\n"
        "2) no\n"
        "3) no need (skips future steps for check for backup completeness)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${backup_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " backup_answer

    shopt -u nocasematch
    case $backup_answer in
    1)
        clear_lines 1
        _result="true"
        log_answer "Created a VPS snapshot" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Created a VPS snapshot" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        # Passing "no need" also skips the completeness check — signal via nameref
        # by setting the vps_snapshot_verify answer directly in the caller's scope.
        # The caller must declare a local variable named "answer_5" for this to work.
        answer_5="true"
        log_answer "Created a VPS snapshot" "no need"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



backup_vps_snapshot_verify() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Last Checks: VPS Snapshot Readiness")\n\n"
        "Last checks before beginning server maintenance.\n\n"
        "Is the VPS snapshot ready?\n"
        "1) yes\n"
        "2) no\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " backup_answer

    shopt -u nocasematch
    case $backup_answer in
    yes | y | 1)
        _result="true"
        log_answer "VPS snapshot ready" "yes"
        ;;
    no | n | 2)
        clear_lines 1
        _result="false"
        log_answer "VPS snapshot ready" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}



backup_server_initiate() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Server Backup")\n\n"
        "Did you initiate the backup process?\n"
        "1) yes\n"
        "2) no\n"
        "3) no need (skips future steps for check for backup completeness)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${backup_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2/3): " backup_answer

    case $backup_answer in
    1)
        clear_lines 1
        _result="true"
        log_answer "Initiated the backup process" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Initiated the backup process" "no"
        ;;
    3)
        clear_lines 1
        _result="true"
        # Signal the caller's server_verify answer variable directly via scope.
        # The caller must declare a local variable named "answer_6" for this to work.
        answer_6="true"
        log_answer "Initiated the backup process" "no need"
        ;;
    *) echo "Invalid answer, please enter (1/2/3)" ;;
    esac
}



backup_server_verify() {
    local -n _result="${1}"

    clear

    local description_text_array=(
        "$(center_heading_text "Last Checks: Server Backup Readiness")\n\n"
        "Last checks before beginning server maintenance.\n\n"
        "Is the Server backup complete?\n"
        "1) yes\n"
        "2) no\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " backup_answer

    case $backup_answer in
    1)
        clear_lines 9
        _result="true"
        log_answer "Server backup complete" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Server backup complete" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
