#!/bin/bash
skip_dep_check=false
debug_mode=false

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0)

# The directory where current script resides
DIR=$(dirname "${THIS}")

maintenance_start_time=$(date +\%Y\%m\%d_\%H\%M)

# import bundles
source "$DIR/scripts/helpers/env_check.sh"

# Activate virtual python environment
activate_venv

sleep 1

# find arguments
for arg in "$@"; do
    if [[ "$arg" == "--skip-dep-check" ]]; then
        skip_dep_check=true
        break
    elif [[ "$arg" == "--debug" || "$arg" == "-d" ]]; then
        debug_mode=true
    fi
done

if $skip_dep_check; then
    echo "⏩️  Skipping pip install due to --skip-dep-check flag."
else
    echo "▶️  Starting Pre-Maintenance Environment..."
    if ! $debug_mode; then
        printf "3 "
        sleep 1
        printf "2 "
        sleep 1
        printf "1"
        echo ""
        sleep 1
    fi

    # Upgrading pip
    echo "📥️  Checking pip for upgrades..."
    pip install --upgrade pip \
        --log $DIR/logs/pip/install-$maintenance_start_time.log \
        --require-virtualenv \
        $(if ! $debug_mode; then echo " -q --no-input"; fi)

    # installing pip dependencies
    echo "📦️  Checking that all Python dependencies are in place..."
    pip install -r $DIR/requirements.txt \
        --log $DIR/logs/pip/install-$maintenance_start_time.log \
        --require-virtualenv \
        $(if ! $debug_mode; then echo " -q --no-input"; fi)
fi

echo "✅ Pre-Maintenance Environment setup. Elevating to Python."
python $DIR/main.py "$@"