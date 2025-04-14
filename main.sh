#!/bin/bash

# Name of the screen session
SESSION_NAME="gws-maintenance"

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# import bundles
source "$DIR/scripts/configs/settings.sh"
source "$DIR/scripts/utils/bundle.sh"
source "$DIR/scripts/helpers/bundle.sh"


print_message_array "${main_banner_text_array[@]}"

# Check if required software exists
check_screen_installed
check_python_installed

# Open existing or create new screen session
is_screen_session "$@"

# Activate virtual python environment
activate_venv

# Run upgrades
check_for_upgrades "$@"

echo "Starting Maintenance..."
sleep 1
python src/main.py "$@"
