#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Sets the server hostname, edits the MOTD banner, and disables default MOTD links.
# Enforces cloud-init hostname retention so the custom hostname persists across reboots.
#
# Usage: hostname_setup
#   (no return variable — interactive, exits when complete)
hostname_setup() {
    clear

    local description_text_array=(
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

    read -p "Please specify the server hostname (e.g. "srv-idnt-1"): " hostname_input

    sudo hostnamectl set-hostname "$hostname_input"

    wait_for_input "Press any key when you are ready to set the MOTD message..."

    printf "\n$(center_heading_text "Setting the MOTD Banner")\n\n"

    sudo nano /etc/update-motd.d/00-header

    printf "\n$(center_heading_text "Disabling Default MOTD Links")\n\n"

    local motd_10_help_text="/etc/update-motd.d/10-help-text"

    # Use sed to comment out the specific lines
    sudo sed -i 's|^printf " \* Documentation:  https://help.ubuntu.com\\n"|#&|' "$motd_10_help_text"
    sudo sed -i 's|^printf " \* Management:     https://landscape.canonical.com\\n"|#&|' "$motd_10_help_text"
    sudo sed -i 's|^printf " \* Support:        https://ubuntu.com/pro\\n"|#&|' "$motd_10_help_text"

    wait_for_input "Press any key when you are ready to go to next task..."
}
