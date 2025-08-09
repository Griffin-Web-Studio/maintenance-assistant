#!/bin/bash
run_task_1() {
    local answer_1
    local answer_2
    local answer_3
    local answer_4
    local answer_5
    local answer_6
    local answer_7
    local task_name="Details Collection (Legacy)"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this Task you will be required to collect the information about the\n"
        "server you are maintaining and ensure all data is backed up before real work\n"
        "begins.\n\n"
    )

    local backup_description_text_array=(
        "$(center_heading_text "Initiating Backup")\n\n"
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

    log_task "Started Task: $task_name (Task 1)"

    # function to ask user if they created a VPS snapshot
    ask_vps_snapshot() {
        clear
        
        description_text_array=(
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
            "$(center_heading_text "Collect Server Info")\n\n"
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
                
        wait_for_input "Press any key when you ready to print the MOTD..."

        clear

        log_answer "user clicked the key to get the banner" "aknowledged prompt"

        printf "$(center_heading_text "copy the banner below this line")\n\n"

        run-parts /etc/update-motd.d/ | tee -a "$logDir/mot.d/log-$maintenance_start_time.log"

        log_answer "compleated printing the banner" "automated banner message"

        printf "\n$(center_heading_text "copy the banner above this line")\n\n"

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
            "$(center_heading_text "Collect Core Server Info")\n\n"
            "Now Let's copy the Server Info.\n\n"
            "Note: If the info is lengthy, you may need to scroll up to view the entire\n"
            "      print.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        log_answer "shown message to the user" "automated banner message"
                
        wait_for_input "Press any key when you ready to print the Info..."

        clear

        log_answer "user clicked the key to get the server info" "aknowledged prompt"

        local temp=(
            "$(center_heading_text "copy the server info below this line")\n\n"

            "==> Basic server info:\n"
            "Server Name/Identifier: $(hostname)\n"
            "Server OS: $(lsb_release -d | cut -f2)\n"
            "Server Kernel: $(uname -r)\n"
            "Server Uptime: $(uptime -p)\n\n"
            
            "==> Server Network Info:\n"
            "Server IP: $(hostname -I)\n"
            "Server Local IP: $(hostname -I)\n"
            "Server Public IP: $(curl -s ifconfig.me)\n"
            "Server Addresses:\n"
        )

        print_message_array "${temp[@]}" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"

        ip -o addr | awk '{split($4, a, "/"); print a[1]" "$2}' | while read -r ip iface; do
            printf "  Interface: $iface\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
            printf "    IP: $ip\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
            if [ "$iface" = "lo" ]; then
                continue
            fi
            printf "    MAC: $(ip link show $iface | awk '/ether/ {print $2}')\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
        done

        local temp=(
            "\nServer Name Servers: $(cat /etc/resolv.conf | grep -oP '(?<=nameserver\s)\d+(\.\d+){3}')\n"
            "Server Default Gateway: $(ip route | awk '/default/ { print $3 }')\n\n"

            "==> Server CPU Info:\n"
            "Server Processes: $(ps ax | wc -l | tr -d " ")\n"
            "Server Architecture: $(uname -m)\n"
            "Server Load Average: $(uptime | awk '{print $10 $11 $12}')\n"
            "Server CPU Usage: $(top -bn1 | grep load | awk '{printf "%.2f%%\t\t", $(NF-2)}')"

            "\n\n==> Server Memory Info:\n"
            "Server Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')"
            "\nServer Disk Usage: $(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)\t\t", $3,$2,$5}')"
            "\nServer Swap Usage: $(free -m | awk 'NR==3{printf "%.2f%%\t\t", $3*100/$2 }')"

            "\n\n==> Server User Info:\n"
            "Server Users: $(users | wc -w)\n\n"

            "==> Server Date: $(date)\n"
            "Server Time: $(date +"%T")\n"
            "Server Timezone: $(timedatectl | grep "Time zone" | cut -d':' -f2 | tr -d ' ')\n\n"
        )

        print_message_array "${temp[@]}" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"

        log_answer "compleated printing the server info" "automated banner message"

        printf "\n$(center_heading_text "copy the server info above this line")\n\n"

        printf "Did you copy the info above?\n"
        printf "1) yes\n"
        printf "2) no\n\n"

        read -p "Possible answers (1/2): " copied_motd_banner

        shopt -u nocasematch
        case $copied_motd_banner in
        1)
            answer_4=true
            log_answer "Copied the banner for MOTD" "yes"
            ;;
        2)
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
            "$(center_heading_text "Last Checks: VPS Snapshot rediness")\n\n"
            "Last Checks before begining server maintenance.\n\n"
            "Is the VPS snapshot ready?\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

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
            "$(center_heading_text "Last Checks: Server Backup rediness")\n\n"
            "Last Checks before begining server maintenance.\n\n"
            "Is the Server backup complete?\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

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
            "$(center_heading_text "Task 1 Completed ✅")\n\n"
            "Nice Work! The task 1 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
            "Do you want to go straight to next task?\n"
            "1) yes\n"
            "2) no\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        read -p "Possible answers (1/2): " backup_process

        case $backup_process in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_2
            ;;
        2)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go back to Main Menu"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }

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
