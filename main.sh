#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# import bundles
source "$DIR/scripts/helpers/env_check.sh"

# Activate virtual python environment
activate_venv

# add an alias for ls -la commands if --docker flag is provided
if [[ "$1" == "--assistant" ]]; then
    python $DIR/assistant.py "$@"
elif [[ "$1" == "--worker" ]]; then
    python $DIR/queue_worker.py "$@"
else
    echo "Starting Maintenance..."
    sleep 1

    # installing pip dependencies
    pip install -r $DIR/requirements.txt

    python $DIR/main.py "$@"
fi
