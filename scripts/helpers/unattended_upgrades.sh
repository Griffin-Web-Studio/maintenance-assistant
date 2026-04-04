#!/bin/bash

#########################################
## DO NOT EXECUTE THIS SCRIPT DIRECTLY ##
#########################################

# Ensures unattended-upgrades is installed, configured, and scheduled.
# When the package is already present the config is always overwritten to
# guarantee all packages and kernels are covered (not just security updates).
# Dist-upgrade is intentionally excluded — run manually each month.
#
# Usage: unattended_upgrades_step <return_var> [log_file]
#   return_var  Name of the caller's variable to set to "true" or "false"
#   log_file    Optional: path to append apt command output to
unattended_upgrades_step() {
    local -n _result="${1}"
    local _log_file="${2:-}"

    clear

    local _pkg_installed=false
    local _timer_override_dir="/etc/systemd/system/apt-daily-upgrade.timer.d"
    local _timer_override_file="$_timer_override_dir/override.conf"
    local _unattended_conf="/etc/apt/apt.conf.d/50unattended-upgrades"
    local _auto_upgrades_conf="/etc/apt/apt.conf.d/20auto-upgrades"

    dpkg-query -W -f='${Status}' unattended-upgrades 2>/dev/null \
        | grep -q "ok installed" && _pkg_installed=true

    description_text_array=(
        "$(center_heading_text "Unattended Upgrades")\n\n"
        "unattended-upgrades is NOT installed on this system.\n\n"
        "Installing it will allow the server to automatically apply all\n"
        "available package and kernel updates daily at 6:00 AM.\n\n"
        "Would you like to install and enable unattended-upgrades?\n\n"
        "1) yes\n"
        "2) no\n"
        "3) no (skip step)\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"
    print_message_array "${description_text_array[@]}"

    # Package not present — ask before installing
    if ! $_pkg_installed; then
        read -p "Possible answers (1/2/3): " _uu_answer
        printf "\n"
        clear_lines 1

        shopt -u nocasematch
        case $_uu_answer in
        1)
            clear
            printf "%s\n\n" "$(center_heading_text "Installing unattended-upgrades")"
            [ -n "$_log_file" ] && log_answer "installing unattended-upgrades" "yes"

            if [ -n "$_log_file" ]; then
                sudo apt-get install -y unattended-upgrades | tee -a "$_log_file"
            else
                sudo apt-get install -y unattended-upgrades
            fi
            ;;
        2)
            clear_lines 1
            _result="false"
            [ -n "$_log_file" ] && log_answer "unattended-upgrades setup" "no"
            return
            ;;
        3)
            clear_lines 1
            _result="true"
            [ -n "$_log_file" ] && log_answer "unattended-upgrades setup" "skipped"
            return
            ;;
        *) echo "Invalid answer, please enter (1/2/3)" ; return ;;
        esac
    else
        echo "unattended-upgrades already installed and enabled."
    fi

    wait_for_input "Press any key when you are ready to automatically configure unattended-upgrades..."

    # Package is present (just installed or was already there) — apply config
    printf "\n%s\n\n" \
        "$(center_heading_text "Configuring: all packages + kernels, 06:00 daily")"
    [ -n "$_log_file" ] \
        && log_answer "configuring unattended-upgrades" "all packages + kernels at 06:00"

    # Write upgrade config: all origins + kernels, no dist-upgrade, no auto-reboot.
    # Single-quoted marker prevents shell expanding APT's own ${} variables.
    cat << 'APTCONF' | sudo tee "$_unattended_conf" > /dev/null
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
APTCONF

    # Enable periodic upgrades
    printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' \
        | sudo tee "$_auto_upgrades_conf" > /dev/null

    # Override systemd timer to run at 06:00 daily
    sudo mkdir -p "$_timer_override_dir"
    printf '[Timer]\nOnCalendar=\nOnCalendar=*-*-* 06:00:00\nRandomizedDelaySec=0\n' \
        | sudo tee "$_timer_override_file" > /dev/null

    sudo systemctl daemon-reload

    if [ -n "$_log_file" ]; then
        sudo systemctl enable --now apt-daily-upgrade.timer | tee -a "$_log_file"
    else
        sudo systemctl enable --now apt-daily-upgrade.timer
    fi

    printf "\n%s\n\n" "$(center_heading_text "Unattended Upgrades configured successfully")"
    [ -n "$_log_file" ] && log_answer "unattended-upgrades configured" "automated"

    # Dry-run to confirm config is valid and show what would be upgraded
    printf "%s\n\n" "$(center_heading_text "Dry-run: packages that would be upgraded")"
    [ -n "$_log_file" ] && log_answer "running unattended-upgrade dry-run" "automated"

    if [ -n "$_log_file" ]; then
        sudo unattended-upgrade --dry-run --debug 2>&1 | tee -a "$_log_file"
    else
        sudo unattended-upgrade --dry-run --debug 2>&1
    fi

    printf "\n%s\n\n" "$(center_heading_text "Dry-run complete — review output above")"

    wait_for_input "Press any key when you are ready to go to the next step..."

    [ -n "$_log_file" ] && log_answer "user clicked the key to get to next step" "acknowledged"

    _result="true"
}
