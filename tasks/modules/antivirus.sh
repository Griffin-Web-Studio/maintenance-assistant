#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Updates ClamAV virus definitions and launches a background scan via screen.
# The scan runs detached so maintenance can continue while it runs.
#
# Usage: antivirus_run <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"
antivirus_run() {
    local -n _result="${1}"

    clear

    local description_text_array=(
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

    read -p "Possible answers (1/2): " av_answer

    shopt -u nocasematch
    case $av_answer in
    1)
        log_answer "Running Antivirus" "yes"

        sudo systemctl stop clamav-freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

        sudo freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

        sudo systemctl start clamav-freshclam | tee -a "$logDir/antivirus/log-$maintenance_start_time.log"

        sudo screen -dm -S virusscan clamscan -ri -l "$logDir/antivirus/log-run-$maintenance_start_time.log" /

        log_answer "Run Antivirus" "yes"

        _result="true"
        ;;
    2)
        clear
        log_answer "Running Antivirus" "no"

        _result="true"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
