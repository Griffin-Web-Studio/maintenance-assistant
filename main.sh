#!/bin/bash

# Activate virtual python environment
activate_venv

echo "Starting Maintenance..."
sleep 1
python main.py "$@"
