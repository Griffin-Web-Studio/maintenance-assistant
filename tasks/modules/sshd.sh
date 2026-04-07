#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Hardens the SSH daemon configuration using sed/grep: enforces PermitRootLogin no,
# PasswordAuthentication no, and AllowUsers restricted to the resolved user list.
# Also patches the cloud-init SSH drop-in if present. Optionally prompts the
# operator to add an SSH public key before restarting the service.
#
# Usage: sshd_configure <return_var> <username> [allow_skip] [setup_authorized_keys]
#   return_var              Name of the caller's variable to set to "true" or "false"
#   username                Service user — always included in AllowUsers
#   allow_skip              Optional: "true" to offer a skip option (default: "false")
#   setup_authorized_keys   Optional: "true" to prompt adding a public key before
#                           restarting SSH — use during initial server setup (default: "false")

# Reads the current AllowUsers value from sshd_config into a nameref variable.
# Sets the nameref to an empty string if the directive is not present.
_sshd_get_current_allow_users() {
    local -n _current_users_out="${1}"
    local _ssh_config="${2}"
    _current_users_out=$(sudo grep "^AllowUsers" "$_ssh_config" 2>/dev/null \
        | sed 's/^AllowUsers[[:space:]]*//' || true)
}

# Interactive: lets the operator pick which users from an existing AllowUsers list
# to retain. _username is always included in the result regardless of selection.
# Sets the nameref _picked_out to the final space-separated user list.
_sshd_pick_users() {
    local -n _picked_out="${1}"
    local _username="${2}"
    shift 2
    local _candidate_users=("$@")

    # Separate the service user from the others (it is always kept)
    local _other_users=()
    for _u in "${_candidate_users[@]}"; do
        if [ "$_u" != "$_username" ]; then
            _other_users+=("$_u")
        fi
    done

    if [ ${#_other_users[@]} -eq 0 ]; then
        _picked_out="$_username"
        return
    fi

    printf "\nSelect which additional users should remain in AllowUsers.\n"
    printf "Enter the numbers separated by spaces (e.g. 1 3), or press Enter to keep none.\n\n"

    local _i=1
    for _u in "${_other_users[@]}"; do
        printf "    %d) %s\n" "$_i" "$_u"
        ((_i++))
    done
    printf "\n"

    read -p "Keep additional users: " _selection

    local _final_users=("$_username")
    if [ -n "$_selection" ]; then
        for _num in $_selection; do
            if [[ "$_num" =~ ^[0-9]+$ ]] && [ "$_num" -ge 1 ] && [ "$_num" -le "${#_other_users[@]}" ]; then
                _final_users+=("${_other_users[$((_num - 1))]}")
            fi
        done
    fi

    _picked_out="${_final_users[*]}"
}

# Interactive: resolves the final AllowUsers value, taking into account any users
# already present in sshd_config. Sets _resolved_out to the final space-separated
# user list. Always ensures _username is included.
_sshd_resolve_allow_users() {
    local -n _resolved_out="${1}"
    local _username="${2}"
    local _ssh_config="${3}"

    local _current
    _sshd_get_current_allow_users _current "$_ssh_config"

    if [ -z "$_current" ]; then
        # No existing AllowUsers directive — nothing to review
        _resolved_out="$_username"
        return
    fi

    # Parse into array
    read -ra _current_users <<< "$_current"

    # Determine whether the service user is already listed
    local _already_in=false
    for _u in "${_current_users[@]}"; do
        if [ "$_u" = "$_username" ]; then
            _already_in=true
            break
        fi
    done

    printf "\nThe following users are currently allowed to connect via SSH:\n\n"
    for _u in "${_current_users[@]}"; do
        if [ "$_u" = "$_username" ]; then
            printf "    - %s \e[2m(you)\e[0m\n" "$_u"
        else
            printf "    - %s\n" "$_u"
        fi
    done
    printf "\n"

    if [ "$_already_in" = true ]; then
        # Service user already listed — confirm or edit
        printf "'\e[1m%s\e[0m' is already in AllowUsers. Is the list above correct?\n\n" "$_username"
        printf "1) yes, keep this list as-is\n"
        printf "2) no, edit (pick which users to keep)\n\n"

        read -p "Possible answers (1/2): " _au_answer
        printf "\n"

        case $_au_answer in
        1)
            log_answer "AllowUsers list" "kept as-is: ${_current}"
            _resolved_out="$_current"
            ;;
        2)
            _sshd_pick_users _resolved_out "$_username" "${_current_users[@]}"
            log_answer "AllowUsers list" "edited to: ${_resolved_out}"
            ;;
        *)
            printf "Invalid answer — keeping list as-is.\n"
            log_answer "AllowUsers list" "kept as-is (invalid input): ${_current}"
            _resolved_out="$_current"
            ;;
        esac

    else
        # Service user is NOT in the existing list
        printf "'\e[1m%s\e[0m' is not in the current AllowUsers list.\n\n" "$_username"
        printf "1) override — replace the entire list with '\e[1m%s\e[0m' only\n" "$_username"
        printf "2) append  — keep all existing users and add '\e[1m%s\e[0m'\n" "$_username"
        printf "3) edit    — pick which existing users to keep, then add '\e[1m%s\e[0m'\n\n" "$_username"

        read -p "Possible answers (1/2/3): " _au_answer
        printf "\n"

        case $_au_answer in
        1)
            log_answer "AllowUsers list" "overridden to: ${_username}"
            _resolved_out="$_username"
            ;;
        2)
            _resolved_out="${_current} ${_username}"
            log_answer "AllowUsers list" "appended: ${_resolved_out}"
            ;;
        3)
            _sshd_pick_users _resolved_out "$_username" "${_current_users[@]}"
            log_answer "AllowUsers list" "edited to: ${_resolved_out}"
            ;;
        *)
            printf "Invalid answer — overriding with '\e[1m%s\e[0m' only.\n" "$_username"
            log_answer "AllowUsers list" "overridden to: ${_username} (invalid input fallback)"
            _resolved_out="$_username"
            ;;
        esac
    fi
}

sshd_configure() {
    local -n _result="${1}"
    local _username="${2}"
    local _allow_skip="${3:-false}"
    local _setup_keys="${4:-false}"

    local _ssh_config="/etc/ssh/sshd_config"
    local _cloud_init_config="/etc/ssh/sshd_config.d/50-cloud-init.conf"

    clear

    # Read current AllowUsers to surface it in the description before prompting
    local _current_allow_users
    _sshd_get_current_allow_users _current_allow_users "$_ssh_config"

    local _current_allow_users_block=""
    if [ -n "$_current_allow_users" ]; then
        _current_allow_users_block="Current AllowUsers: \e[1m${_current_allow_users}\e[0m\n"
        _current_allow_users_block+="You will be asked what to do with the existing list after confirming.\n\n"
    fi

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
        "    AllowUsers ${_username} (resolved interactively if others are present)\n\n"

        "${_current_allow_users_block}"
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

        # Resolve AllowUsers interactively before writing
        local _allow_users_value
        _sshd_resolve_allow_users _allow_users_value "$_username" "$_ssh_config"

        if sudo grep -q "^AllowUsers" "$_ssh_config"; then
            sudo sed -i "s/^AllowUsers.*/AllowUsers ${_allow_users_value}/" "$_ssh_config"
        else
            echo "AllowUsers ${_allow_users_value}" | sudo tee -a "$_ssh_config" > /dev/null
        fi
        log_answer "AllowUsers" "${_allow_users_value}"

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
