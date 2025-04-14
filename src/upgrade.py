from argparse import Namespace
import sys
import os
import git
import git.exc
from packaging.version import Version
from helpers.cli_params import parse_args


def main(args: Namespace):
    # Get the current working directory
    repo_path = os.getcwd()

    # Open the repository
    try:
        repo = git.Repo(repo_path)
    except git.exc.InvalidGitRepositoryError:
        print("No valid Git repository found in the current directory.")
        return 1

    # Check if is a branch
    try:
        current_branch = repo.active_branch
        print("Detected current branch!")
        print(f"Current branch: {current_branch}")
        print("You are currently on a branch that may be ahead of the latest tag.")
        print(
            "Please manually upgrade your software to ensure you are on the latest version."
        )
        print(
            "if you are developing, then happy coding time 😊. psst, pss... pSSSt you may want to use `--debug` option"
        )

        # Let's not disturb the flow 😌
        # 🍾, what, wha, what was I thinking about... uuuuh....... ahA 💡
        if not args.debug and not args.unattended and not args.crontab:
            input("Hit enter to continue: [ENTER]")

        return 1
    except TypeError:
        print("Not in a branch, good.")

    # Get the current commit
    current_commit = repo.head.commit

    # Check if the current HEAD is on a tag
    if current_commit in repo.tags:

        current_tag = next(tag for tag in repo.tags if tag.commit == current_commit)
        print(f"Current version is on tag: {current_tag}")

        # Get all tags and sort them
        tags = sorted(repo.tags, key=lambda t: t.commit.committed_datetime)
        latest_tag = tags[-1] if tags else None

        if latest_tag:
            print(f"Latest version tag: {latest_tag}")

            # Compare versions
            current_version = Version(current_tag.name.strip().replace("v", ""))
            latest_version = Version(latest_tag.name.strip().replace("v", ""))

            if current_version < latest_version:
                print(
                    f"Update available: {latest_version} is newer than {current_version}"
                )
                # TODO: Add Upgrading mechanism
                sys.exit(0)
            else:
                print("You are on the latest version.")

        else:
            print("No tags found in the repository. Wh-a... how?????")
    else:
        print("You are in a detached HEAD state, not on a branch or tag either.")

        # Don't let this continue, clearly a bad state
        while True:
            input("soooo, what now? [TEXT]: ")
            print("yeah didn't really care...")


if __name__ == "__main__":
    sys.exit(main(parse_args()))
