#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Runs SMART disk diagnostics: collects current info, short test, and long test.
# Offers a skip option for virtualised servers where SMART data is unavailable.
#
# Usage: smart_disk_check <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"
smart_disk_check() {
    local -n _result="${1}"

    clear

    local description_text_array=(
    #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        "$(center_heading_text "Start SMART Disk check")\n\n"
        "We will run SMART disk diagnostics. Please review the results\n"
        "and report any findings on the wiki.\n\n"
        "Are you running a virtualised Server aka VPS?\n\n"
        "1) yes (skip)\n"
        "2) no\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " smart_answer

    shopt -u nocasematch
    case $smart_answer in
    1)
        clear_lines 1
        _result="true"
        log_answer "Skipping SMART Information collection" "yes"
        ;;
    2)
        # Collect current SMART info
        clear
        log_answer "Started SMART Information collection" "yes"

        printf "$(center_heading_text "SMART Information collection output below")\n\n"

        sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/info/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "SMART Information collection output above")\n\n"

        wait_for_input "Press any key when you finished copying the info above..."
        clear

        log_answer "completed SMART Information collection" "yes"

        # Collect Short SMART test
        ## initiate short test
        sudo smartctl -t short /dev/sda | tee -a "$logDir/SMART/short/log-$maintenance_start_time.log"
        log_answer "Started Short SMART Tests" "yes"

        wait_for_input "Press any key to check status..."

        ## get short test result
        printf "$(center_heading_text "Short SMART Tests output below")\n\n"

        sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/short/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "Short SMART Tests output above")\n\n"

        wait_for_input "Press any key when you finished copying the info above..."
        clear

        log_answer "completed Short SMART Tests" "yes"

        # Collect Long SMART test
        ## initiate long test
        sudo smartctl -t long /dev/sda | tee -a "$logDir/SMART/long/log-$maintenance_start_time.log"
        log_answer "Started Long SMART Tests" "yes"

        wait_for_input "Press any key to check status..."

        ## get long test result
        printf "$(center_heading_text "Long SMART Tests output below")\n\n"

        sudo smartctl -a /dev/sda | tee -a "$logDir/SMART/long/log-$maintenance_start_time.log"

        printf "\n$(center_heading_text "Long SMART Tests output above")\n\n"

        log_answer "completed Long SMART Tests" "yes"
        wait_for_input "Press any key when you finished copying the info above..."

        _result="true"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
