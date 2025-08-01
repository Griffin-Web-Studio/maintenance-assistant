#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

maintenance_start_time=$(date +\%Y\%m\%d_\%H\%M)
logDir="$DIR/logs"
logFile="$logDir/maintenance-$maintenance_start_time.log"

source "$DIR/utils/utils.sh"

log_task "check for updates ⌛"

printf "$(center_heading_text "Fetching Maintenance Script Updates 🔍")\n\n"

# check if there is an updates in the remote repo
git -C $DIR fetch
if [ "$(git -C "$DIR" rev-parse HEAD)" != "$(git -C "$DIR" rev-parse @{u})" ]; then

    printf "$(center_heading_text "Pulling New Updates 📥")\n\n"
    # pull new changes from git
    git -C $DIR pull

    wait_for_input "Press any key to restart script... 🔄️"

    printf "$(center_heading_text "Updated Successfully ✅")\n\n"

    # restart script
    exec "$DIR/main.sh"
fi

printf "$(center_heading_text "Already Up-to-date ✅")\n\n"
wait_for_input "Press any key to start script... 💨"