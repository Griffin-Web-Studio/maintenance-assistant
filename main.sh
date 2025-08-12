#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# import bundles
source "$DIR/scripts/helpers/env_check.sh"

# Activate virtual python environment
activate_venv

sleep 1

if [[ "$1" == "--skip-dep-check" ]]; then
    echo "Skipping pip install due to --skip-dep-check flag."
    python $DIR/main.py "$@"
else
    echo "Starting Maintenance..."
    printf "3 "
    sleep 1
    printf "2 "
    sleep 1
    printf "1"
    sleep 1

    # installing pip dependencies
    pip install -r $DIR/requirements.txt
    python $DIR/main.py "$@"
fi