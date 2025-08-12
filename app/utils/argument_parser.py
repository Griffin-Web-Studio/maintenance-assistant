""" ArgumentsManagerController - This module provides command-line argument
parsing controller Maintenance Assistant. It defines various subcommands,
attributes, and flags to control the behaviour of the application, such as debug
mode, unattended mode, web interface mode etc.
"""
import argparse
import sys


class ArgumentsManagerController():
    """ Class to manage application subcommands and arguments"""

    _parser = argparse.ArgumentParser(
        description="""
            GWS Server-side Maintenance Assistant - Helps with automating the
            maintenance task on your server. Provides options to run in
            unattended mode and if interactions are needed provides ability to
            interact via secure web interface.
            """
    )

    def __init__(self):
        self._parse_args()

    def get_args(self):
        return self._parser.parse_args()

    def _parse_args(self):

        # Flags
        self._parser.add_argument(
            "--debug",
            action="store_true",
            help="is debugging (use in development)"
        )
        self._parser.add_argument(
            "-c",
            "--crontab",
            action="store_true",
            help="is initiated by cron job?",
        )
        self._parser.add_argument(
            "-u",
            "--unattended",
            action="store_true",
            help="is running unattended?",
        )
        self._parser.add_argument(
            "-w", "--web", action="store_true", help="is running web interface?"
        )
        # self._parser.add_argument(
        #     "-x", "--xpath", type=str, help="Specify the path to the log file"
        # )

        # Parse and return the arguments

    def command_runner_args(self):
        # Create the parser
        parser = argparse.ArgumentParser(
            description="""placeholder"""
        )

        self._parser.add_argument(
            "-p",
            "--path",
            type=str,
            required=True,
            help="path to script or a command",
        )

        self._parser.add_argument(
            "-l",
            "--log",
            action="store_true",
            default=False,
            help="Will the executed command be logged?",
        )

        self._parser.add_argument(
            "-L",
            "--Log",
            type=str,
            default=False,
            help="Will the executed command be logged?",
        )

        args = parser.parse_args()

        # Conditional requirement for log-path
        if args.log and not args.log_path:
            print("Error: -L or --Log is required when logging is enabled.")
            sys.exit(1)

        # Parse and return the arguments
        return args
