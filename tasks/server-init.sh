#!/bin/bash
. "$DIR/scripts/helpers/unattended_upgrades.sh"
. "$DIR/scripts/helpers/change_password.sh"
. "$DIR/scripts/helpers/check_sshd_config.sh"

run_init_0() {
    local answer_1
    local answer_1b
    local answer_sshd
    local answer_2
    local answer_99
    local task_name="Init: Server Initialiser"
    local SSH_CONFIG="/etc/ssh/sshd_config"
    local CLOUD_INIT_CONFIG="/etc/ssh/sshd_config.d/50-cloud-init.conf"
    local CURRENT_USER=$(whoami)



    # Steps to change passwords for root and the current service user
    change_root_password() {
        change_password_step "answer_1" "root"
    }

    change_service_user_password() {
        change_password_step "answer_1b" "$CURRENT_USER"
    }



    # Step to configure SSHD (shared helper — no skip, authorized_keys setup included)
    check_sshd_config() {
        check_sshd_config_step "answer_sshd" "$CURRENT_USER" "false" "true"
    }



    set_locale_and_timezone() {
        clear
        
        description_text_array=(
            "$(center_heading_text "Set The Clock & Locale")\n\n"
            "Now let's set the clock to the correct timezone.\n\n"

            "When we begin, first we will set the correct timezone per server location.\n"
            "Then we will set the correct locale which will always be English GB.\n\n"

            "The current Local and Time configurations are:\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Current Time & Timezone:\n"
        sudo timedatectl

        printf "\n\nCurrent Locale:\n"
        sudo locale

        printf "\n\n"
        wait_for_input "Press any key when you are ready to set timezone..."
        
        read -p "Please specify the timezone (default: Europe/London): " set_timezone_string

        shopt -u nocasematch
        case $set_timezone_string in
            "")
                sudo timedatectl set-timezone Europe/London
                ;;
            *)
                sudo timedatectl set-timezone "$set_timezone_string"
                ;;
        esac

        printf "\n\n$(center_heading_text "Here are the new Timezone Values")\n\n"

        printf "\nCurrent Time & Timezone:\n"
        sudo timedatectl

        printf "\n\n"
        wait_for_input "Press any key when you are ready to set locale..."

        printf "\n$(center_heading_text "Enabling Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        sudo sed -i '/^#.*en_GB.UTF-8 UTF-8/s/^#//' /etc/locale.gen

        printf "\n$(center_heading_text "Generating Locale \"en_GB.UTF-8 UTF-8\"")\n\n"

        sudo locale-gen en_GB.UTF-8

        printf "\n$(center_heading_text "Updating Locale via update-locale")\n\n"

        sudo update-locale en_GB.UTF-8 UTF-8

        printf "\n$(center_heading_text "Updating Locale via localectl")\n\n"

        sudo localectl set-locale LANG=en_GB.UTF-8 LANGUAGE=en_GB:en

        printf "\n\nIs everything as it should be?\n"
        wait_for_input "If so, press any key when you are ready to reboot..."

        sudo reboot
    }



    set_server_identifier() {
        clear
        
        description_text_array=(
            #********************************************************************************.\n
            "$(center_heading_text "Set Server Identifier")\n\n"
            "Now let's make sure that this server is identifiable when SSH'd into it.\n\n"

            "First we will set the server hostname, then the MOTD banner to reflect its\n"
            "Geographical location and unit encoded in the identifier e.g. gws-uk-1 GWS UK 1.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"


        printf "\n$(center_heading_text "Enforcing retention of custom hostname")\n\n"

        sudo sed -i '/preserve_hostname: false/c\preserve_hostname: true' /etc/cloud/cloud.cfg

        printf "\n$(center_heading_text "Setting the Hostname")\n\n"

        wait_for_input "Press any key when you are ready to set the hostname..."
        clear_lines 1
        
        read -p "Please specify the server hostname (e.g. "srv-idnt-1"): " set_hostname_string

        sudo hostnamectl set-hostname "$set_hostname_string"

        wait_for_input "Press any key when you are ready to set the MOTD message..."

        printf "\n$(center_heading_text "Setting the MOTD Banner")\n\n"

        sudo nano /etc/update-motd.d/00-header

        printf "\n$(center_heading_text "Disabling Default MOTD Links")\n\n"

        motd_10_help_text="/etc/update-motd.d/10-help-text"

        # Use sed to comment out the specific lines
        sudo sed -i 's|^printf " \* Documentation:  https://help.ubuntu.com\\n"|#&|' "$motd_10_help_text"
        sudo sed -i 's|^printf " \* Management:     https://landscape.canonical.com\\n"|#&|' "$motd_10_help_text"
        sudo sed -i 's|^printf " \* Support:        https://ubuntu.com/pro\\n"|#&|' "$motd_10_help_text"

        wait_for_input "Press any key when you are ready to go to next task..."
    }



    update_server_packages() {
        clear
        
        description_text_array=(
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
        read -p "Possible answers (1/2): " install_netdata

        shopt -u nocasematch
        case $install_netdata in
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
        read -p "Possible answers (1/2): " install_netbird

        shopt -u nocasematch
        case $install_netbird in
            1)
                printf "\n$(center_heading_text "Installing: VPN")\n\n"

                curl -fsSL https://pkgs.netbird.io/install.sh | sh

                read -p "Please specify the VPN Management URL (e.g. "https://vpn.your-org.com"): " set_vpn_management_url

                read -p "Please specify the VPN Management key (e.g. "xxx-xxx-xxx-xxx-xxx"): " set_vpn_management_key

                netbird up --management-url "$set_vpn_management_url" --setup-key "$set_vpn_management_key"
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



    # check/install/configure unattended-upgrades (shared helper)
    setup_unattended_upgrades() {
        unattended_upgrades_step "answer_2"
    }



    # function to show completion screen and reboot
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 0 Completed ✅")\n\n"
            "Nice Work! The server is now initialised!\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        wait_for_input "Hit any key to end maintenance and reboot..."
        sudo reboot
    }

    # MAIN ================================================================================

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"

        "During this task we will initialise the new server and prep it for work.\n"
        "Follow along here https://wiki.griffin-web.studio/linux/setting-up-a-new-vps-server/ \n\n"

        "What steps to expect in this task:\n"
        "1) Change root password\n"
        "2) Check SSH Configuration\n"
        "3) Set correct Locale & Timezone\n"
        "4) DO First reboot\n"
        "5) Set Server Identifier\n"
        "6) Package upgrade\n"
        "7) Install additional necessary packages\n"
        "8) Distro upgrade\n"
        "9) DO Last Reboot\n\n\n"

        "Did you complete Steps 1-4?\n\n"
        "1) yes\n"
        "2) no\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    read -p "Possible answers (1/2): " first_reboot_done

    shopt -u nocasematch
    case $first_reboot_done in
        1)
            set_server_identifier
            update_server_packages

            while [ "$answer_2" != "true" ]; do
                setup_unattended_upgrades
            done

            while [ "$answer_99" != "true" ]; do
                complete_step
            done
            ;;
        2)
            while [ "$answer_1" != "true" ]; do
                change_root_password
            done

            while [ "$answer_1b" != "true" ]; do
                change_service_user_password
            done

            while [ "$answer_sshd" != "true" ]; do
                check_sshd_config
            done

            set_locale_and_timezone
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
    esac

}
