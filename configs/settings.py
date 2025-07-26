"""configs.settings - Configuration settings for the
Griffin Web Studio Maintenance Assistant application. This module defines
various constants used throughout the application."""
from pathlib import Path

from helpers.lock_manager import LockManager

ROOT_DIR: Path = Path(__file__).resolve().parent.parent
APP_NAME = "Griffin Web Studio - Maintenance Assistant"
SESSION_NAME = "gws-maintenance"
MAINTENANCE_LOCK = ROOT_DIR / "maintenance.lock"

# Create an instance of LockManager
lock_mgr = LockManager(MAINTENANCE_LOCK)

LOCK_TIMESTAMP = lock_mgr.get_lock_timestamp()
LOG_FILE = ROOT_DIR / "logs" / f"gws-maintenance-{LOCK_TIMESTAMP}.log"

MAIN_BANNER_ARRAY = [
    '',
    '       >>01000111010101110101001100100000010011010010000000110',
    '      >1   _______       ________                          00',
    '     00   / ____/ |     / / ____/    MaiNt  aNCe          00',
    '    01   / / __ | | /| / /\\__ \\      MAI TENA CE         01',
    '   10   / /_/ / | |/ |/ /___/ /      Ma   En  CE        10',
    '  00    \\____/  |__/|__/_____/       Ma       CE  01   00',
    ' 00                                                   1<',
    '01100000001001011001000000100110010101110101011100010<<',  # slant
    '',
]
