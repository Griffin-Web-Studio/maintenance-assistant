"""
Text Utils
"""

import os
import math
from typing import Optional


def center_text(text: str, spacer: str = "=", length: Optional[int] = None) -> str:
    """Center text within length

    Args:
        text (str): text to be centred
        spacer (str): spacer character.
        length (Optional[int], optional): length (overrides auto console width). Defaults to None.

    Returns:
        str: new string with centred text
    """
    ter_len = length or os.get_terminal_size().columns
    text_len = len(text)

    padding = (ter_len - text_len - 4) / 2
    padding_text = spacer * math.floor(padding)

    return padding_text + " " + text + " " + padding_text


def print_message_array(message_array: list[str]) -> None:
    """Prints an array of messages, each on a new line.

    Args:
        message_array (list[str]): Array of messages to print.
    """
    for message in message_array:
        print(message)
