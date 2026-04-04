#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Hardens the SSH daemon configuration using sed/grep: enforces PermitRootLogin no,
# PasswordAuthentication no, and AllowUsers restricted to the specified user.
# Also patches the cloud-init SSH drop-in if present. Optionally prompts the
# operator to add an SSH public key before restarting the service.
#
# Usage: check_sshd_config_step <return_var> <username> [allow_skip] [setup_authorized_keys]
#   return_var              Name of the caller's variable to set to "true" or "false"
#   username                User to set in AllowUsers (e.g. deploy)
#   allow_skip              Optional: "true" to offer a skip option (default: "false")
#   setup_authorized_keys   Optional: "true" to prompt adding a public key before
#                           restarting SSH — use during initial server setup (default: "false")
check_sshd_config_step() {
    local -n _result="${1}"
    local _username="${2}"
    local _allow_skip="${3:-false}"
    local _setup_keys="${4:-false}"

    local _ssh_config="/etc/ssh/sshd_config"
    local _cloud_init_config="/etc/ssh/sshd_config.d/50-cloud-init.conf"

    clear

    local _options="1) yes\n"
    local _prompt_hint="(1)"
    if [ "$_allow_skip" = "true" ]; then
        _options+="2) no (skip)\n"
        _prompt_hint="(1/2)"
    fi

    local description_text_array=(
        "$(center_heading_text "SSH Server Configuration")\n\n"

        "We will now harden the SSH daemon by automatically applying the following\n"
        "settings to ${_ssh_config}:\n\n"

        "    PermitRootLogin no\n"
        "    PasswordAuthentication no\n"
        "    AllowUsers ${_username}\n\n"

        "The cloud-init SSH drop-in (${_cloud_init_config}) will also be patched\n"
        "if it exists on this server.\n\n"

        "Ready to apply SSH configuration changes?\n\n"
        "${_options}"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    read -p "Possible answers ${_prompt_hint}: " _sshd_answer

    shopt -u nocasematch
    case $_sshd_answer in
    1)
        log_answer "Applying SSH config changes" "yes"

        # --- /etc/ssh/sshd_config ---

        if sudo grep -q "^PermitRootLogin" "$_ssh_config"; then
            sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$_ssh_config"
        else
            echo "PermitRootLogin no" | sudo tee -a "$_ssh_config" > /dev/null
        fi
        log_answer "PermitRootLogin" "no"

        if sudo grep -q "^PasswordAuthentication" "$_ssh_config"; then
            sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$_ssh_config"
        else
            echo "PasswordAuthentication no" | sudo tee -a "$_ssh_config" > /dev/null
        fi
        log_answer "PasswordAuthentication" "no"

        if sudo grep -q "^AllowUsers" "$_ssh_config"; then
            sudo sed -i "s/^AllowUsers.*/AllowUsers ${_username}/" "$_ssh_config"
        else
            echo "AllowUsers ${_username}" | sudo tee -a "$_ssh_config" > /dev/null
        fi
        log_answer "AllowUsers" "${_username}"

        # --- Cloud-init SSH drop-in (if present) ---
        if [ -f "$_cloud_init_config" ]; then
            if sudo grep -q "^PasswordAuthentication" "$_cloud_init_config"; then
                sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$_cloud_init_config"
            else
                echo "PasswordAuthentication no" | sudo tee -a "$_cloud_init_config" > /dev/null
            fi
            log_answer "PasswordAuthentication (cloud-init drop-in)" "no"
        fi

        # --- Optional: add SSH public key before restarting ---
        if [ "$_setup_keys" = "true" ]; then
            wait_for_input "Press any key when you are ready to add your SSH public key..."
            nano ~/.ssh/authorized_keys
            log_answer "SSH authorized_keys" "configured"
        fi

        # --- Restart SSH ---
        wait_for_input "Press any key to restart the SSH service..."

        if sudo systemctl is-active --quiet sshd 2>/dev/null; then
            sudo systemctl restart sshd
        else
            sudo systemctl restart ssh
        fi
        log_answer "SSH service" "restarted"

        wait_for_input "Press any key when you are ready to proceed to the next step..."

        _result="true"
        ;;
    2)
        if [ "$_allow_skip" = "true" ]; then
            clear
            log_answer "SSH config check" "skipped"
            _result="true"
        else
            echo "Invalid answer, please enter (1)"
        fi
        ;;
    *) echo "Invalid answer, please enter ${_prompt_hint}" ;;
    esac
}
