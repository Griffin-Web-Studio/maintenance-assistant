import argparse


def parse_args():
    # Create the parser
    parser = argparse.ArgumentParser(
        description="""
        GWS Server-side Maintenance Assistant - Helps with automating the
        maintenance task on your server. Provides options to run in unattended
        mode and if interactions are needed provides ability to interact via
        secure web interface.
        """
    )

    # Flags
    parser.add_argument(
        "-c",
        "--crontab",
        action="store_true",
        help="is initiated by cron job?",
    )
    parser.add_argument(
        "-u",
        "--unattended",
        action="store_true",
        help="is running unattended?",
    )
    parser.add_argument(
        "-w", "--web", action="store_true", help="is running web interface?"
    )
    # parser.add_argument(
    #     "-x", "--xpath", type=str, help="Specify the path to the log file"
    # )

    # Parse and return the arguments
    return parser.parse_args()
