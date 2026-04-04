#!/bin/bash
. "$DIR/tasks/modules/maintenance_log.sh"

run_task_5() {
    local answer_1
    local answer_7
    local task_name="Maintenance: Completion"

    clear

    local task_description_text_array=(
        "$(center_heading_text "$task_name")\n\n"
        "During this task we will log the end of maintenance time.\n"
        "\n\n"
    )

    print_message_array "${main_banner_text_array[@]}"
    print_message_array "${task_description_text_array[@]}"

    log_task "Started Task: $task_name (Task 5)"



    # function to show completion screen and ask user what to do next
    complete_step() {
        clear

        local description_text_array=(
            "$(center_heading_text "Maintenance Completed ✅")\n\n"
            "Great Work! You have completed the final task 5 and the maintenance is now\n"
            "complete! You now have a choice of either ending the maintenance script or\n"
            "going back to the main menu.\n\n"
        )

        print_message_array "${main_banner_text_array[@]}"
        print_message_array "${task_description_text_array[@]}"
        print_message_array "${description_text_array[@]}"

        printf "Do you want to end the Maintenance script?\n"
        printf "1) yes\n"
        printf "2) no\n\n"
        read -p "Possible answers (1/2): " nav_answer

        case $nav_answer in
        1)
            answer_7=true

            log_task "Task $task_name: completed"
            log_task "User chose to exit maintenance: yes"
            log_task "Exited program"
            exit 0
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
        maintenance_log_end_time "answer_1"
    done

    while [ "$answer_7" != "true" ]; do
        complete_step
    done
}
