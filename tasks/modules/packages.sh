#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Full server package setup for initial provisioning: runs apt update/upgrade/clean/
# autoremove, installs core tools (btop, snapd, screen), optionally installs Netdata
# and Netbird VPN, installs and updates ClamAV, then runs dist-upgrade.
#
# Usage: packages_update
#   (no return variable — interactive, exits when complete)
packages_update() {
    clear

    local description_text_array=(
        #********************************************************************************.\n
        "$(center_heading_text "Update packages")\n\n"
        "Now let's make sure that all packages on the server are up-to-date.\n\n"

        "First we will update packages, then the distro.\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    wait_for_input "Press any key when you are ready to update packages..."

    printf "\n$(center_heading_text "Updating Packages")\n\n"

    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get clean
    sudo apt-get autoremove -y

    wait_for_input "Press any key when you are ready to install additional packages..."

    printf "\n$(center_heading_text "Installing: btop, snapd, and screen")\n\n"

    sudo apt-get install btop snapd screen -y

    echo "Would you like to install Netdata?"
    printf "\n1) yes\n"
    printf "2) no (skip)\n\n"
    read -p "Possible answers (1/2): " packages_answer

    shopt -u nocasematch
    case $packages_answer in
        1)
            printf "\n$(center_heading_text "Installing: netdata")\n\n"

            sudo curl -o /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
            sh /tmp/netdata-kickstart.sh
            ;;
        2)
            printf "\nOk no Netdata\n\n"
            clear
            ;;
        *) echo "Invalid answer, assuming no" ;;
    esac

    printf "\n$(center_heading_text "Installing: Clam-AV Antivirus")\n\n"

    sudo apt-get install clamav clamav-daemon -y

    sudo systemctl stop clamav-freshclam

    sudo freshclam

    sudo systemctl start clamav-freshclam

    echo "Would you like to install Netbird?"
    printf "\n1) yes\n"
    printf "2) no (skip)\n\n"
    read -p "Possible answers (1/2): " packages_answer

    shopt -u nocasematch
    case $packages_answer in
        1)
            printf "\n$(center_heading_text "Installing: VPN")\n\n"

            curl -fsSL https://pkgs.netbird.io/install.sh | sh

            read -p "Please specify the VPN Management URL (e.g. "https://vpn.your-org.com"): " vpn_management_url

            read -p "Please specify the VPN Management key (e.g. "xxx-xxx-xxx-xxx-xxx"): " vpn_management_key

            netbird up --management-url "$vpn_management_url" --setup-key "$vpn_management_key"
            netbird down
            ;;
        2)
            printf "\nOk no Netbird\n\n"
            clear
            ;;
        *) echo "Invalid answer, assuming no" ;;
    esac

    wait_for_input "Press any key once you have added the VPN peer to the appropriate group and applied the specific policies..."

    wait_for_input "Press any key when you are ready to run Dist Upgrade..."

    printf "\n$(center_heading_text "Running Dist Upgrade")\n\n"

    sudo apt-get dist-upgrade

    wait_for_input "All went well? Press any key to continue..."
}
