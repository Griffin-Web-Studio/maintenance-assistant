"""configs.constants - Configuration settings for the
Griffin Web Studio Maintenance Assistant application. This module defines
various constants used throughout the application."""
import os
import sys
import yaml
from pathlib import Path
from typing import List
from app.configs.config_file import init_config_file
from app.utils.lock_manager import LockManager

ROOT_DIR: Path = Path(os.path.dirname(
    sys.modules['__main__'].__file__)).resolve()
MAINTENANCE_LOCK = ROOT_DIR / "maintenance.lock"

# Create an instance of LockManager
lock_mgr = LockManager(MAINTENANCE_LOCK)

LOCK_TIMESTAMP = lock_mgr.get_lock_timestamp()
LOG_FILE = ROOT_DIR / "logs" / f"maintenance-{LOCK_TIMESTAMP}.log"


init_config_file(ROOT_DIR)

# Customisation settings
with open(ROOT_DIR / 'config.yml', 'r') as file:
    config = dict(yaml.safe_load(file)).get('config', {})

APP_NAME = config.get('app_name', "Griffin Web Studio - Maintenance Assistant")
SESSION_NAME = config.get('session_name', "gws-maintenance")
MAIN_BANNER_ARRAY: List[str] = config.get(
    'main_banner', 'GWS Maintenance Assistant - Banner Fallback').splitlines()
