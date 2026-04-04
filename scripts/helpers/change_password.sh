#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Presents five randomly generated passwords, changes the password for the
# specified user, locks the root shell login, and guides the operator to verify
# the new password in a separate terminal before continuing.
#
# Usage: change_password_step <return_var> <username>
#   return_var  Name of the caller's variable to set to "true" or "false"
#   username    System user whose password will be changed (e.g. root, deploy)
change_password_step() {
    local -n _result="${1}"
    local _username="${2}"

    clear

    local description_text_array=(
        "$(center_heading_text "Change Password: ${_username}")\n\n"

        "We will now change the password for the '${_username}' account.\n"
        "Five randomly generated passwords are listed below. Choose one, paste it\n"
        "into a text editor to confirm it copied correctly, then proceed.\n\n"

        "1) $(generate_password 230)\n\n"
        "2) $(generate_password 230)\n\n"
        "3) $(generate_password 230)\n\n"
        "4) $(generate_password 230)\n\n"
        "5) $(generate_password 230)\n\n"

        "Ready to change the password for '${_username}'?\n\n"
        "1) yes\n"
        "2) no (skip)\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers (1/2): " _pw_answer

    shopt -u nocasematch
    case $_pw_answer in
    1)
        log_answer "Changing password for '${_username}'" "yes"

        sudo passwd "${_username}"

        # Always enforce root shell lock — prevents root from regaining
        # interactive login regardless of which user's password was changed.
        sudo usermod -s /usr/sbin/nologin root
        log_answer "Root shell login" "disabled"

        log_answer "Password changed for '${_username}'" "complete"

        printf "\n%s\n\n" "$(center_heading_text "Verify the New Password")"
        printf "Open a new terminal and log in as '%s' using the new password.\n" "${_username}"
        printf "If it does not work, press Ctrl+C and run 'sudo passwd %s' to retry.\n\n" "${_username}"

        wait_for_input "Press any key once you have verified the new password..."

        log_answer "Password verification for '${_username}'" "confirmed"

        _result="true"
        ;;
    2)
        clear
        log_answer "Changing password for '${_username}'" "skipped"
        _result="true"
        ;;
    *) echo "Invalid answer, please enter (1/2)" ;;
    esac
}
