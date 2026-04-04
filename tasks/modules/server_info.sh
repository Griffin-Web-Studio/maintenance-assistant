#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Collects and displays server information for the operator to copy into the wiki:
# the MOTD banner and core server details (network, CPU, memory, disk, etc.).
#
# Usage: server_info_motd_copy <return_var>
#        server_info_details_copy <return_var>
#   return_var  Name of the caller's variable to set to "true" or "false"

server_info_motd_copy() {
    local -n _result="${1}"

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

    wait_for_input "Press any key when you are ready to print the MOTD..."

    clear

    log_answer "user clicked the key to get the banner" "acknowledged prompt"

    printf "$(center_heading_text "copy the banner below this line")\n\n"

    run-parts /etc/update-motd.d/ | tee -a "$logDir/mot.d/log-$maintenance_start_time.log"

    log_answer "completed printing the banner" "automated banner message"

    printf "\n$(center_heading_text "copy the banner above this line")\n\n"

    printf "Did you copy the banner above?\n"
    printf "1) yes\n"
    printf "2) no\n\n"
    read -p "Possible answers (1/2): " info_answer

    shopt -u nocasematch
    case $info_answer in
    1)
        clear_lines 20 $((line_count + 1))
        _result="true"
        log_answer "Copied the banner for MOTD" "yes"
        ;;
    2)
        clear_lines 1
        _result="false"
        log_answer "Copied the MOTD banner" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}



server_info_details_copy() {
    local -n _result="${1}"

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

    wait_for_input "Press any key when you are ready to print the Info..."

    clear

    log_answer "user clicked the key to get the server info" "acknowledged prompt"

    local server_info_lines=(
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

    print_message_array "${server_info_lines[@]}" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"

    ip -o addr | awk '{split($4, a, "/"); print a[1]" "$2}' | while read -r ip iface; do
        printf "  Interface: $iface\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
        printf "    IP: $ip\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
        if [ "$iface" = "lo" ]; then
            continue
        fi
        printf "    MAC: $(ip link show $iface | awk '/ether/ {print $2}')\n" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"
    done

    local server_info_extra=(
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

    print_message_array "${server_info_extra[@]}" | tee -a "$logDir/server-info/log-$maintenance_start_time.log"

    log_answer "completed printing the server info" "automated banner message"

    printf "\n$(center_heading_text "copy the server info above this line")\n\n"

    printf "Did you copy the info above?\n"
    printf "1) yes\n"
    printf "2) no\n\n"

    read -p "Possible answers (1/2): " info_answer

    shopt -u nocasematch
    case $info_answer in
    1)
        _result="true"
        log_answer "Copied the banner for MOTD" "yes"
        ;;
    2)
        _result="false"
        log_answer "Copied the server info" "no"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
