from pathlib import Path

APP_NAME = "GWS Server-side Maintenance Assistant"

MAIN_BANNER_ARRAY = [
    "\n",
    "       >>01000111010101110101001100100000010011010010000000110\n",
    "      >1   _______       ________                          00 \n",
    "     00   / ____/ |     / / ____/    MaiNt  aNCe          00  \n",
    "    01   / / __ | | /| / /\__ \      MAI TENA CE         01   \n",
    "   10   / /_/ / | |/ |/ /___/ /      Ma   En  CE        10    \n",
    "  00    \____/  |__/|__/_____/       Ma       CE  01   00     \n",
    " 00                                                   1<      \n",
    "01100000001001011001000000100110010101110101011100010<<       \n\n",  # slant
]


def get_script_directory() -> Path:
    return Path(__file__).resolve().parent
