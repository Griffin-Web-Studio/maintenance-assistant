#!/bin/bash

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

# import bundles
source "$DIR/scripts/helpers/env_check.sh"

# Activate virtual python environment
activate_venv

echo "Starting Maintenance..."
sleep 1
python $DIR/main.py "$@"
