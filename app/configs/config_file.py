""" config_file - This module houses the configuration file initialisation logic
for the Griffin Web Studio Maintenance Assistant. It ensures that the
configuration file exists and is readable, copying a sample file if necessary.
"""
import os
from pathlib import Path


def init_config_file(root_dir: Path) -> None:
    """Initialise the configuration file for the application.

    This function checks if the configuration file exists and is readable.
    If not, it copies a sample configuration file to the expected location.

    Args:
        root_dir (Path): The root directory of the application where the config
        file is located.
    """

    config_file = root_dir / "config.yml"
    config_file_sample = root_dir / "config.sample.yml"

    if not config_file.exists() or not os.access(config_file, os.R_OK):
        print(
            f"🫗  Configuration file {config_file}",
            "does not exist or is not readable.",
            f"\n📖  Copying sample config file to {config_file}.")

        with (
            open(config_file_sample, 'r') as src,
            open(config_file, 'w') as dst
        ):
            dst.write(src.read())

    print("📜  Configuration file is present and readable.")
