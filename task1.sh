#!/bin/bash
run_task_1() {
    # local $logFile=$1
    local answer_1
    local answer_2
    local answer_3
    clear_lines 7

    # function to log user answers
    log_answer() {
        echo "$(date): Task: Details Collection, Step $1, Answer: $2" >>$logFile
    }

    # function to ask user if they created a VPS snapshot
    ask_vps_snapshot() {
        read -p "Did you create a VPS snapshot? (YES/Y/1) / (NO/N/2): " vps_snapshot
        shopt -u nocasematch
        case $vps_snapshot in
        yes | y | 1)
            clear_lines 1
            answer_1="yes"
            log_answer "Created a VPS snapshot" "yes"
            ;;
        no | n | 2)
            clear_lines 1
            answer_1="no"
            log_answer "Created a VPS snapshot" "no"
            ;;
        *) echo "Invalid answer, please enter ('yes' 'y' '1') or ('no' 'n' '1')" ;;
        esac
    }

    # function to ask user if they initiated the backup process
    ask_backup_process() {
        read -p "Did you initiate the backup process? (yes/y/1) / (no/n/2): " backup_process
        case $backup_process in
        yes | y | 1)
            clear_lines 9
            answer_2="yes"
            log_answer "Initiated the backup process" "yes"
            ;;
        no | n | 2)
            clear_lines 1
            answer_2="no"
            log_answer "Initiated the backup process" "no"
            ;;
        *) echo "Invalid answer, please enter ('yes' 'y' '1') or ('no' 'n' '1')" ;;
        esac
    }

    ask_to_copy_banner() {
        #       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        printf "Now you need to copy the MOTD (Message Of The Day) banner displayed on your\n"
        printf "terminal (which you see each time you connect via ssh), and paste it into the\n"
        printf "checklist section of our wiki website. Note: If the banner is lengthy, you may\n"
        printf "need to scroll up to view the entire message.\n\n"
        log_answer "shown message to the user" "automated banner message"

        read -n 1 -r -s -p "Press any key to continue..." key
        log_answer "user clicked the key to get the banner" "aknowledged prompt"
        printf "\n"
        clear_lines 1
        printf "======================= copy the banner below this line ========================\n\n"
        run-parts /etc/update-motd.d/ 2>&1 | tee output.txt
        local line_count=$(wc -l < output.txt)
        rm output.txt

        # cat output.txt
        log_answer "compleated printing the banner" "automated banner message"

        echo $line_count
        read -p "Did you copy the banner above? (yes/y/1) / (no/n/2): " copied_motd_banner
        shopt -u nocasematch
        case $copied_motd_banner in
        yes | y | 1)
            clear_lines 20 $((line_count + 1))
            answer_3="yes"
            log_answer "Copied the banner for MOTD" "yes"
            ;;
        no | n | 2)
            clear_lines 1
            answer_3="no"
            log_answer "Initiated the backup process" "no"
            ;;
        *) echo "Invalid answer, please enter ('yes' 'y' '1') or ('no' 'n' '1')" ;;
        esac
    }

    #       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    printf "=========================== Maintenance Preperation ============================\n\n"

    # display message to user
    printf "To begin with please initiate a backup process, log in to the IONOS ISP Control\n"
    printf "Panel for this Server and create a new complete snapshot of the VPS. Then, log\n"
    printf "in to the server Control Panel (Plex) via the link:\n\n"
    printf "gws-<REGION_ID>-<UNIQUE_ID>.gwssecureserver.co.uk:8443\n\n"
    printf "to start the backup process.\n\n"

    # loop until user answers "yes" to both questions
    while [ "$answer_1" != "yes" ]; do
        ask_vps_snapshot
    done

    while [ "$answer_2" != "yes" ]; do
        ask_backup_process
    done

    while [ "$answer_3" != "yes" ]; do
        ask_to_copy_banner
    done
}
