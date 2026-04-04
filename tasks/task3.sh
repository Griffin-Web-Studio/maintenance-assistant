#!/bin/bash
. "$DIR/tasks/modules/btop.sh"
. "$DIR/tasks/modules/smart.sh"

run_task_3() {
    local answer_1
    local answer_2
    local answer_7
    local task_name="Maintenance: Server Load & Stress Monitoring"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will monitor server load and check the health of all disks\n"
        "using SMART diagnostics. Report any findings on the wiki.\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 3)"



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Task 3 Completed ✅")\n\n"
            "Nice Work! The task 3 is now complete!\n\n"
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

            run_task_4
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
        btop_monitor "answer_1"
    done

    while [ "$answer_2" != "true" ]; do
        smart_disk_check "answer_2"
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
