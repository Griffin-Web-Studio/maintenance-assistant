#!/bin/bash
. "$DIR/tasks/modules/password.sh"
. "$DIR/tasks/modules/sshd.sh"
. "$DIR/tasks/modules/antivirus.sh"

run_task_4() {
    local answer_1
    local answer_2
    local answer_2b
    local answer_3
    local answer_7
    local task_name="Maintenance: Server Security"
    local current_user=$(whoami)

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will look to ensure all of the server security is in place\n"
        "and still does what we expect it to.\n\n"
        "What steps to expect in this task:\n"
        "1) Check SSH Configuration\n"
        "2) Change root password\n"
        "3) Run Antivirus\n"
        "\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 4)"



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 4 Completed ✅")\n\n"
            "Nice Work! The task 4 is now complete!\n\n"
            "You now have a choice of either going straight to the next task or back to the\n"
            "main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to go straight to next task?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " nav_answer

        case $nav_answer in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go straight to Next Task: yes"

            run_task_5
            ;;
        2)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to go back to Main Menu"
            ;;
        *) echo "Invalid answer, please enter (1/2)" ;;
        esac
    }



    while [ "$answer_1" != "true" ]; do
        sshd_configure "answer_1" "$current_user" "true" "false"
    done

    while [ "$answer_2" != "true" ]; do
        password_change "answer_2" "root"
    done

    while [ "$answer_2b" != "true" ]; do
        password_change "answer_2b" "$current_user"
    done

    while [ "$answer_3" != "true" ]; do
        antivirus_run "answer_3"
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
