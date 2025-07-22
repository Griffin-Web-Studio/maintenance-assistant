"""upgrade - A script to check for and apply updates to the
Griffin Web Studio Maintenance Assistant application."""

import sys
import os
from argparse import Namespace
from packaging.version import Version
import git
import git.exc

from helpers.cli_params import parse_args
from utils.text import center_text


def run_upgrade(args: Namespace):
    print("\n/ / / / / Fetching Maintenance Script Updates 🔍 / / / / /\n")

    repo_path = os.getcwd()

    try:
        repo = git.Repo(repo_path)

    except git.exc.InvalidGitRepositoryError:
        print("No valid Git repository found in the current directory.")
        return 1

    try:
        current_branch = repo.active_branch
        print("- Attached to a branch. 😱")
        print(f"- Current branch: {current_branch}")
        print(
            "- You are currently on a branch that may be ahead of the"
            " latest tag."
        )
        print(
            "⚠️  Please manually upgrade your software to ensure you are on "
            "the latest version."
        )

        # Let's not disturb the flow 😌
        # 🍾, what, wha, what was I thinking about... uuuuh....... ahA 💡
        if not args.debug and not args.unattended and not args.crontab:
            print(
                "📝 if you are developing, then happy coding time 😊.\n"
                "psst, pss... pSSSt you may want to use `--debug` option"
            )
            input("Hit enter to continue: [ENTER]")

        return 1
    except TypeError:
        print("In Detached HEAD state, safe to proceed.")

    # Get the current commit
    current_commit = repo.head.commit

    # Check if the current HEAD is on a tag
    if current_commit not in repo.tags:
        # Don't let this continue, clearly a bad state
        print(
            "Current HEAD is not on a tag. "
            "Please check your repository state."
        )
        print("Heuston, we have a problem! 🚨")
        print("Please ensure you are on a tag before running this script.")
        print("Exiting...")
        return 1

    current_tag = next(
        tag for tag in repo.tags if tag.commit == current_commit
    )
    print(f"- Current version is on tag: {current_tag}")

    # Get all tags and sort them
    tags = sorted(repo.tags, key=lambda t: t.commit.committed_datetime)
    latest_tag = tags[-1] if tags else None

    # Check if there is a latest tag
    if not latest_tag:
        print("No tags found in the repository. Wh-a... how?????")
        return 1

    print(f"- Latest version tag: {latest_tag}")

    # Compare versions
    current_version = Version(current_tag.name.strip().replace("v", ""))
    latest_version = Version(latest_tag.name.strip().replace("v", ""))

    if current_version < latest_version:
        print(
            f"- Update available: {latest_version} is newer than {current_version}")
        # TODO: Add Upgrading mechanism
        sys.exit(0)
    else:
        print("You are on the latest version.")


if __name__ == "__main__":
    sys.exit(run_upgrade(parse_args()))
