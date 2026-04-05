#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Handles the case where the maintenance script is launched as the root user.
# Displays a warning, lists existing non-system users so the operator can
# identify the correct service account, and offers to create a new service user
# with a bash shell and sudo privileges if one does not yet exist.
#
# Usage: service_user_check
#   (no return variable — exits after guiding the operator)
#
#        service_user_list
#   (prints non-system users with UID >= 1000 to stdout)
#
#        service_user_create
#   (interactive: prompts for a username, confirms it, creates the account)

service_user_list() {
    getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 { printf "    - %s\n", $1 }' | sort
}

service_user_create() {
    local _new_username=""
    local _confirmed="false"

    while [ "$_confirmed" != "true" ]; do
        printf "\n"
        read -p "Enter the username for the new service user: " _new_username
        printf "\n"

        if [ -z "$_new_username" ]; then
            printf "Username cannot be empty. Please try again.\n"
            continue
        fi

        printf "You entered: \e[1m%s\e[0m\n\n" "$_new_username"
        printf "Is this correct?\n"
        printf "1) yes\n"
        printf "2) no (re-type)\n\n"
        read -p "Possible answers (1/2): " _confirm_answer

        shopt -u nocasematch
        case $_confirm_answer in
        1)
            _confirmed="true"
            ;;
        2)
            printf "Ok, let's try again.\n"
            ;;
        *)
            printf "Invalid answer, please enter (1/2)\n"
            ;;
        esac
    done

    if id "$_new_username" &>/dev/null; then
        printf "\nUser '\e[1m%s\e[0m' already exists on this system.\n" "$_new_username"
        printf "No changes were made. Re-run the script as that user.\n\n"
        log_answer "Service user creation for '${_new_username}'" "skipped — user already exists"
        return
    fi

    printf "\nCreating user '\e[1m%s\e[0m' with /bin/bash shell...\n" "$_new_username"
    useradd -m -s /bin/bash "$_new_username"
    log_answer "Service user '${_new_username}' created" "useradd -m -s /bin/bash"

    printf "Setting password for '\e[1m%s\e[0m'...\n\n" "$_new_username"
    passwd "$_new_username"
    log_answer "Password set for '${_new_username}'" "complete"

    printf "\nAdding '\e[1m%s\e[0m' to the sudo group...\n" "$_new_username"
    usermod -aG sudo "$_new_username"
    log_answer "Service user '${_new_username}' added to sudo group" "complete"

    printf "\n"
    printf "$(center_heading_text "Service User Created")\n\n"
    printf "User '\e[1m%s\e[0m' has been created with:\n" "$_new_username"
    printf "    Shell:  /bin/bash\n"
    printf "    Groups: sudo\n\n"
    printf "Re-run this maintenance script as '\e[1m%s\e[0m'.\n\n" "$_new_username"
    log_answer "Service user setup" "complete — operator must re-run script as '${_new_username}'"
}

service_user_check() {
    task_name="Root User Check"

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
    )

    local existing_users
    existing_users=$(service_user_list)

    local existing_users_block
    if [ -n "$existing_users" ]; then
        existing_users_block="Existing non-system users on this machine:\n\n${existing_users}\n\n"
    else
        existing_users_block="No non-system users found on this machine.\n\n"
    fi

    local description_text_array=(
        "$(center_heading_text "!! Running as Root !!")\n\n"
        "This script must NOT be run as the root user. Instead, run it as\n"
        "a service/deploy user who has sudo privileges.\n\n"
        "Keeping the root account locked reduces the attack surface of the server.\n\n"
        "${existing_users_block}"
        "Would you like to create a new service user now?\n\n"
        "1) yes (create a new service user)\n"
        "2) no (exit)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    log_task "Root user detected — prompting operator to create a service user"

    read -p "Possible answers (1/2): " _root_check_answer
    printf "\n"

    shopt -u nocasematch
    case $_root_check_answer in
    1)
        log_answer "Create service user" "yes"
        service_user_create
        wait_for_input "Press any key to exit..."
        exit 0
        ;;
    2)
        printf "Exiting. Please re-run this script as a sudoer service user.\n\n"
        log_answer "Create service user" "no — operator chose to exit"
        wait_for_input "Press any key to exit..."
        exit 0
        ;;
    *)
        printf "Invalid answer, please enter (1/2)\n"
        service_user_check
        ;;
    esac
}
