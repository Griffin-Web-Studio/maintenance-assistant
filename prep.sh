#!/bin/bash

if [ ! -d ".venv" ]; then
    echo ".venv directory not found. Creating virtual environment..."
    python3 -m venv .venv
fi

# Check again if .venv directory exists
if [ -d ".venv" ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
    
    # Run main.py
    echo "Running main.py..."
    python src/main.py "$@"
else
    echo "Failed to create virtual environment."
fi