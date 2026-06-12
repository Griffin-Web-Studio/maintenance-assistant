#!/bin/bash

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

# Add aliases for common ls commands if --docker flag is provided
if [[ "$1" == "--docker" ]]; then
    echo "Adding alias for ls -la commands..."
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -la"' >> ~/.bashrc
    echo 'alias l="ls -l"' >> ~/.bashrc
    echo "Installing tmux..."
    sudo apt update
    sudo apt install -y tmux
else
    echo "No --docker flag provided, skipping alias creation."
fi

# ───────────────────────────────────────────────────────| Environment Setup |──

# Install dependency managers
pipx install uv

# install all dependencies
uv sync --all-extras

# Activate virtual python environment
source .venv/bin/activate


# ────────────────────────────────────────────────────────| Pre-commit hooks |──

if ! command -v pre-commit &>/dev/null; then
  echo "ERROR: pre-commit is not installed." >&2
  echo "       Install it with: pip install pre-commit or look for errors" >&2
  echo "       above as UV should have been already installed and" >&2
  echo "       activated, which means there's another issue." >&2
  exit 1 # early fail - no pre-commit hook
fi

echo "Installing pre-commit hooks..."
(cd "$SCRIPT_DIR" && pre-commit install)
(cd "$SCRIPT_DIR" && pre-commit install --hook-type commit-msg)


echo "Setup complete!"
