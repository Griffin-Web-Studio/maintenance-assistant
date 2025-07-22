from pathlib import Path

ROOT_DIR: Path = Path(__file__).resolve().parent.parent
APP_NAME = "Griffin Web Studio - Maintenance Assistant"
SESSION_NAME = "gws-maintenance"
LOG_FILE = ROOT_DIR / "logs" / "gws-maintenance"
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
