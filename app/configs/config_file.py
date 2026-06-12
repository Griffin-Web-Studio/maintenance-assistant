"""config_file - This module houses the configuration file initialisation logic
for the Griffin Web Studio Maintenance Assistant. It ensures that the
configuration file exists and is readable, copying a sample file if necessary.
"""

import os
import yaml
from pathlib import Path
from typing import Union, Dict, List, Optional


def load_yaml(file_path: str) -> Optional[Union[Dict, List]]:
    with open(file_path, "r") as file:
        return yaml.safe_load(file)


def write_yaml(file_path: str, data: dict) -> Optional[Union[Dict, List]]:
    with open(file_path, "w") as file:
        yaml.dump(data, file, default_flow_style=False)


def check_and_set_instance_type(data: any, config_dir: Path) -> Dict:
    """Check and set the instance type in the configuration.

    This function checks if the instance_type property exists in the config.
    If not, it prompts the user to specify it and updates the config accordingly.

    Args:
        data (any): raw yaml data
        config_dir (Path): path to a yaml config file

    Returns:
        Dict: The updated configuration dictionary
    """

    if isinstance(data, dict):
        print("📜  Configuration file is present and readable.")
        print("🔍️  Checking where the script is executed")
        config = data.get("config")

        if config is None:
            config = {}

        instance_type = config.get("instance_type")

        while instance_type not in ["client", "server"]:
            instance_type = (
                input("Please specify the instance type (client/server): ")
                .strip()
                .lower()
            )
            if instance_type not in ["client", "server"]:
                print("Invalid input. Please enter 'client' or 'server'.")

            # Update the configuration with the new instance type
            config["instance_type"] = instance_type
            print(
                f"✅  Updated configuration with instance_type: {instance_type}"
            )

            data["config"] = config

            # Write the updated configuration back to the file
            write_yaml(config_dir, data)

        print(
            "☁️  Server - detected"
            if instance_type == "server"
            else "🖥️  Client - detected"
        )

    return config


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
            f"\n📖  Copying sample config file to {config_file}.",
        )

        with (
            open(config_file_sample, "r") as src,
            open(config_file, "w") as dst,
        ):
            dst.write(src.read())

    data = load_yaml(root_dir / "config.yml")

    return check_and_set_instance_type(data, config_file)

    raise ValueError(
        data,
        """Does not conform to expected data type in config.yml.
        Please double check that the format of the file with
        config.sample.yml""",
    )
