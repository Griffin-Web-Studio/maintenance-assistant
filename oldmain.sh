#!/bin/bash
print_message_array "${main_banner_text_array[@]}"

# Check if required software exists
check_screen_installed
check_python_installed

# Open existing or create new screen session
is_screen_session "$@"

# Activate virtual python environment
activate_venv

