#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Sets the server timezone and locale. Prompts for a timezone (defaults to
# Europe/London), then enables and generates the en_GB.UTF-8 locale, and reboots.
#
# Usage: locale_setup
#   (no return variable — function always reboots on completion)
locale_setup() {
    clear

    local description_text_array=(
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

    read -p "Please specify the timezone (default: Europe/London): " timezone_input

    shopt -u nocasematch
    case $timezone_input in
        "")
            sudo timedatectl set-timezone Europe/London
            ;;
        *)
            sudo timedatectl set-timezone "$timezone_input"
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
