"""
Form Util Functions
"""

from app.configs.constants import APP_NAME


def form_title(title: str) -> str:
    """Generates a form title with app name

    Args:
        title (str): Form title name

    Returns:
        str: full form title string
    """
    return f"{APP_NAME} - {title}"
