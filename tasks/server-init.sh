#!/bin/bash
. "$DIR/tasks/modules/password.sh"
. "$DIR/tasks/modules/sshd.sh"
. "$DIR/tasks/modules/unattended_upgrades.sh"
. "$DIR/tasks/modules/locale.sh"
. "$DIR/tasks/modules/hostname.sh"
. "$DIR/tasks/modules/packages.sh"

run_init_0() {
    local answer_1
    local answer_1b
    local answer_sshd
    local answer_2
    local answer_99
    local task_name="Init: Server Initialiser"
    local current_user=$(whoami)



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
            hostname_setup
            packages_update

            while [ "$answer_2" != "true" ]; do
                unattended_upgrades_setup "answer_2"
            done

            while [ "$answer_99" != "true" ]; do
                complete_step
            done
            ;;
        2)
            while [ "$answer_1" != "true" ]; do
                password_change "answer_1" "root"
            done

            while [ "$answer_1b" != "true" ]; do
                password_change "answer_1b" "$current_user"
            done

            while [ "$answer_sshd" != "true" ]; do
                sshd_configure "answer_sshd" "$current_user" "false" "true"
            done

            locale_setup
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
    esac

}
