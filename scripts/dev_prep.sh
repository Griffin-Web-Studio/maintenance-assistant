#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create a virtual environment if the --venv flag is provided
if [[ "$1" == "--venv" ]]; then
    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv .venv
    fi

    # Activate the virtual environment
    echo "Activating virtual environment..."
    source .venv/bin/activate
else
    echo "No --venv flag provided, skipping virtual environment creation."
fi

# add an alias for ls -la commands if --docker flag is provided
if [[ "$1" == "--docker" ]]; then
    echo "Adding alias for ls -la commands..."
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -la"' >> ~/.bashrc
    echo 'alias l="ls -l"' >> ~/.bashrc
else
    echo "No --docker flag provided, skipping alias creation."
fi

# Install required Python packages
echo "Installing required packages..."
pip install -r requirements.txt

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
pre-commit install
pre-commit install --hook-type commit-msg -f
pre-commit autoupdate

echo "Setup complete!"
