""" ArgumentParser - A module housing wrapper Class for ArgumentParser.
"""
import argparse
import sys


class ArgumentParser(argparse.ArgumentParser):
    """A wrapper Class for ArgumentParser which extends the class by adding some
    useful methods. It also includes some procedures for setting up the
    application, not ideal... but it works so be it.

    Extends: argparse.ArgumentParser
    """

    def __init__(self, *args, **kwargs):
        description = """
            GWS Maintenance Assistant - Helps with automating the maintenance
            task on your server. It provides options to run in the script in
            unattended mode and utilises tmux for session restore functionality
            if the SSH connection to the server got interrupted during an
            important task such as upgrade.
            """
        super().__init__(*args, description=description, ** kwargs)
        self._script_subparsers: dict[str, argparse._SubParsersAction] = {}

    def parse_args(self) -> argparse.Namespace:
        """Parses the user defined args when the script was run and collects
        them into a Namespace for later retrieval.

        Returns:
            argparse.Namespace: Namespace for all args and their values
        """

        self._add_script_args()

        args = super().parse_args()

        if args.command == 'run' and args.run:
            if args.log and not args.log_path:
                print("Error: -L or --log-path is required when logging is enabled.")
                sys.exit(1)

        return args

    def _add_script_args(self):
        """Set all the global and sub command args"""

        # set command subparser
        self._set_script_subparser(
            dest="command", parser=self, help="Subcommands")

        # add commands are equivalent to procedures
        self._add_global_args()
        self._add_run_subparser()
        self._add_run_module_parser("assistant")
        self._add_run_module_parser("upgrade")
        self._add_run_module_parser("worker")

    def _set_script_subparser(
            self, parser: argparse.ArgumentParser, dest: str, **kwargs):
        """Sets subparser

        Args:
            dest (str): destination name
        """
        self._script_subparsers[dest] = parser.add_subparsers(
            dest=dest, **kwargs)

    def _get_script_subparser(self, dest: str) -> argparse._SubParsersAction:
        """Gets subparser

        Args:
            dest (str): destination name

        Raises:
            ValueError: If the subparser is not yet set

        Returns:
            argparse._SubParsersAction: _description_
        """

        run_subparser = self._script_subparsers[dest]

        if not run_subparser:
            raise ValueError(
                run_subparser, "run subparser is not set, set it first!")

        return run_subparser

    #
    # PROCEDURES
    #

    def _add_global_args(self):
        """Method sets the global args"""

        self.add_argument(
            "--debug",
            action="store_true",
            help="is debugging (use in development)"
        )
        self.add_argument(
            "-c",
            "--crontab",
            action="store_true",
            help="is initiated by cron job?",
        )
        self.add_argument(
            "-u",
            "--unattended",
            action="store_true",
            help="is running unattended?",
        )
        self.add_argument(
            "--skip-dep-check",
            action="store_true",
            help="Skip dependencies check?",
        )
        self.add_argument(
            "-w", "--web", action="store_true", help="is running web interface?"
        )

    def _add_run_subparser(self):
        """Sets run subparser"""
        cmd_subparser = self._get_script_subparser(dest="command")
        run_parser = cmd_subparser.add_parser(
            "run", help="run a specific module")
        self._set_script_subparser(
            dest="run", parser=run_parser, help="What Module Should be run")

    def _add_run_module_parser(self, name: str):
        """sets the sub command modules and their args for the run subparser.
        some of the run commands have common arguments so this is here to
        provide ability to aupdate them all simultaneously.

        Args:
            name (str): Name of the module
        """
        run_subparser = self._get_script_subparser("run")

        run_module_parser: ArgumentParser = run_subparser.add_parser(
            name, help=f"Run {name} module")

        run_module_parser.add_argument(
            "-l",
            "--log",
            action="store_true",
            default=False,
            help="Will the executed command be logged?",
        )

        run_module_parser.add_argument(
            "-L",
            "--log-path",
            type=str,
            default=False,
            help="Will the executed command be logged?",
        )
