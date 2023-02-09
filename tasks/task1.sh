#!/bin/bash
run_task_1() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7

    clear

    local task_description_text_array=(
        "=========================== Maintenance Preperation ============================\n\n"
        "During this Task you will be required to collect the information about the\n"
        "server you are maintaining and ensure all data is backed up before real work\n"
        "begins.\n\n"
    )

    local backup_description_text_array=(
        #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        "============================== Initiating Backup ===============================\n\n"
        "To begin with lets create two backups, first the VPS snapshot, then the server\n"
        "backup. Please follow these steps:\n\n"
        "1) You must log in to the IONOS ISP, and select Control Panel for this Server.\n"
        "   This server can be identified as $(hostname).\n"
        "   Then you need to create a new complete snapshot of the VPS\n"
        "   THIS IS ESSENTIAL IN CASE SOMETHING GOES WRONG!\n\n"
        "2) Log in to the server Control Panel (Plex) via the link (skip if not managed\n"
        "   by Plesk): https://$(hostname).gwssecureserver.co.uk:8443\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    # function to log user answers
    log_answer() {
        echo "$(date): Task: Details Collection, Step $1, Answer: $2" >>$logFile
    }

    # function to ask user if they created a VPS snapshot
    ask_vps_snapshot() {
        clear
        echo "$(date): Started Task 1" >>$logFile
        description_text_array=(
            "================================= VPS Snapshot =================================\n\n"
            "Did you create a VPS snapshot?\n"
            "1) yes\n"
            "2) no\n"
            "3) no need (skips future steps for check for backup completeness)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${backup_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " vps_snapshot

        shopt -u nocasematch
        case $vps_snapshot in
        1)
            clear_lines 1
            answer_1=true
            log_answer "Created a VPS snapshot" "yes"
            ;;
        2)
            clear_lines 1
            answer_1=false
            log_answer "Created a VPS snapshot" "no"
            ;;
        3)
            clear_lines 1
            answer_1=true
            answer_5=true
            log_answer "Created a VPS snapshot" "no need"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }

    # function to ask user if they initiated the backup process
    ask_backup_process() {
        clear
        description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "================================ Server Backup =================================\n\n"
            "Did you initiate the backup process?\n"
            "1) yes\n"
            "2) no\n"
            "3) no need (skips future steps for check for backup completeness)\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${backup_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2/3): " backup_process

        case $backup_process in
        1)
            clear_lines 1
            answer_2=true
            log_answer "Initiated the backup process" "yes"
            ;;
        2)
            clear_lines 1
            answer_2=false
            log_answer "Initiated the backup process" "no"
            ;;
        3)
            clear_lines 1
            answer_2=true
            answer_6=true
            log_answer "Initiated the backup process" "no need"
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ;;
        esac
    }

    # function to ask user if they copied the MOTD banner
    ask_to_copy_banner() {
        clear

        local description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "============================= Collect Server Info ==============================\n\n"
            "Now you need to copy the MOTD (Message Of The Day) banner displayed on your\n"
            "terminal (which you see each time you connect via ssh), and paste it into the\n"
            "checklist section of our wiki website. This script will now re-print the MOTD.\n\n"
            "Note: If the banner is lengthy, you may need to scroll up to view the entire\n"
            "      message.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${info_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        log_answer "shown message to the user" "automated banner message"

        read -n 1 -r -s -p "Press any key when you ready to print the MOTD..." key
        log_answer "user clicked the key to get the banner" "aknowledged prompt"
        printf "\n"
        clear_lines 1

        printf "======================= copy the banner below this line ========================\n\n"
        run-parts /etc/update-motd.d/ 2>&1 | tee output.txt
        local line_count=$(wc -l <output.txt)
        rm output.txt
        log_answer "compleated printing the banner" "automated banner message"

        printf "\n======================= copy the banner above this line ========================\n\n"

        printf "Did you copy the banner above?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " copied_motd_banner

        shopt -u nocasematch # disable case-insensitive matching
        case $copied_motd_banner in
        1)
            clear_lines 20 $((line_count + 1))
            answer_3=true
            log_answer "Copied the banner for MOTD" "yes"
            ;;
        2)
            clear_lines 1
            answer_3=false
            log_answer "Initiated the backup process" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

    # function to ask user if they copied the server info
    ask_to_copy_server_info() {
        clear

        local description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "=========================== Collect Core Server Info ===========================\n\n"
            "Now Let's copy the Server Info.\n\n"
            "Note: If the info is lengthy, you may need to scroll up to view the entire\n"
            "      print.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        log_answer "shown message to the user" "automated banner message"

        read -n 1 -r -s -p "Press any key when you ready to print the Info..." key
        log_answer "user clicked the key to get the server info" "aknowledged prompt"
        printf "\n"
        clear_lines 1

        printf "===================== copy the server info below this line =====================\n\n"

        printf "==> Basic server info:\n"
        printf "Server Name/Identifier: %s\n" $(hostname)
        printf "Server OS: %s\n" $(lsb_release -d | cut -f2)
        printf "Server Kernel: %s\n" $(uname -r)
        printf "Server Uptime: %s\n" $(uptime -p)
        printf "\n"

        printf "==> Server Network Info:\n"
        printf "Server IP: %s\n" $(hostname -I)
        printf "Server Local IP: %s\n" $(hostname -I)
        printf "Server Public IP: %s\n" $(curl -s ifconfig.me)

        printf "Server Addresses:\n"
        ip -o addr | awk '{split($4, a, "/"); print a[1]" "$2}' | while read -r ip iface; do
            printf "  Interface: %s\n" "$iface"
            printf "    IP: %s\n" "$ip"
            if [ "$iface" = "lo" ]; then
                continue
            fi
            printf "    MAC: %s\n" "$(ip link show $iface | awk '/ether/ {print $2}')"
        done

        printf "\n"
        printf "Server Name Servers: %s\n" $(cat /etc/resolv.conf | grep -oP '(?<=nameserver\s)\d+(\.\d+){3}')
        printf "Server Default Gateway: %s\n" $(ip route | awk '/default/ { print $3 }')
        printf "\n"

        printf "==> Server CPU Info:\n"
        printf "Server Processes: %s\n" $(ps ax | wc -l | tr -d " ")
        printf "Server Architecture: %s\n" $(uname -m)
        printf "Server Load Average: %s\n" $(uptime | awk '{print $10 $11 $12}')
        printf "Server CPU Usage: %s\n" $(top -bn1 | grep load | awk '{printf "%.2f%%\t\t", $(NF-2)}')
        printf "\n"

        printf "==> Server Memory Info:\n"
        printf "Server Memory Usage: %s\n" $(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
        printf "Server Disk Usage: %s\n" $(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)\t\t", $3,$2,$5}')
        printf "Server Swap Usage: %s\n" $(free -m | awk 'NR==3{printf "%.2f%%\t\t", $3*100/$2 }')
        printf "\n"

        printf "==> Server User Info:\n"
        printf "Server Users: %s\n" $(users | wc -w)
        printf "\n"

        printf "==> Server Date: %s\n" $(date)
        printf "Server Time: %s\n" $(date +"%T")
        printf "Server Timezone: %s\n" $(timedatectl | grep "Time zone" | cut -d':' -f2 | tr -d ' ')
        printf "\n"

        # cat output.txt
        log_answer "compleated printing the server info" "automated banner message"

        #         ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        printf "\n===================== copy the server info above this line =====================\n\n"

        printf "Did you copy the info above?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " copied_motd_banner

        shopt -u nocasematch
        case $copied_motd_banner in
        1)
            clear_lines 20 $((line_count + 1))
            answer_4=true
            log_answer "Copied the banner for MOTD" "yes"
            ;;
        2)
            clear_lines 1
            answer_4=false
            log_answer "Initiated the backup process" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

    # function to ask user if they completed creating a VPS snapshot
    ask_vps_snapshot_complete() {
        clear

        local description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "===================== Last Checks: VPS Snapshot rediness =======================\n\n"
            "Last Checks before begining server maintenance.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Is the VPS snapshot ready?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " vps_snapshot

        shopt -u nocasematch
        case $vps_snapshot in
        yes | y | 1)
            answer_5=true
            log_answer "VPS snapshot ready" "yes"
            ;;
        no | n | 2)
            clear_lines 1
            answer_5=false
            log_answer "VPS snapshot ready" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

    # function to ask user if they completed the backup process
    ask_backup_complete() {
        clear

        local description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "===================== Last Checks: Server Backup rediness ======================\n\n"
            "Last Checks before begining server maintenance.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Is the Server backup complete?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            clear_lines 9
            answer_6=true
            log_answer "Server backup complete" "yes"
            ;;
        2)
            clear_lines 1
            answer_6=false
            log_answer "Server backup complete" "no"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

    # function to ask user if they completed the backup process
    complete_step() {
        clear

        local description_text_array=(
            #    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            "============================= Task 1 Completed ✅ =============================\n\n"
            "Nice Work! The task 1 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to go straight to next task?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            answer_7=true
            echo "$(date): Task: Details Collection. Task 1 Completed" >>$logFile
            echo "$(date): Task: Details Collection. User chose to go straight to Task 2" >>$logFile
            echo "$(date): Finished Task 1" >>$logFile
            run_rask_2
            ;;
        2)
            answer_7=true
            echo "$(date): Task: Details Collection. Task 1 Completed" >>$logFile
            echo "$(date): Task: Details Collection. User chose to go back to main menu" >>$logFile
            echo "$(date): Finished Task 1" >>$logFile
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

    #       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    # loop until user answers "yes" to both questions
    while [ "$answer_1" != "true" ]; do
        ask_vps_snapshot
    done

    while [ "$answer_2" != "true" ]; do
        ask_backup_process
    done

    while [ "$answer_3" != "true" ]; do
        ask_to_copy_banner
    done

    while [ "$answer_4" != "true" ]; do
        ask_to_copy_server_info
    done

    while [ "$answer_5" != "true" ]; do
        ask_vps_snapshot_complete
    done

    while [ "$answer_6" != "true" ]; do
        ask_backup_complete
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
