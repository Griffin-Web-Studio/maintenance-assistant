import asyncio
from textual.app import App, ComposeResult
from textual.widgets import Log, Input
from textual.events import Click


import sys
import libtmux

from configs.settings import SESSION_NAME, ROOT_DIR
from helpers.cli import CommandRunner
from textual.app import App

cmd = CommandRunner()


class MyApp(App):
    CSS_PATH = f"{ROOT_DIR}/style/console.tcss"

    def compose(self) -> ComposeResult:
        log = Log(id="output", highlight=True,
                  auto_scroll=True, classes="panel")
        log.border_title = "Command Output"
        yield log
        console_input = Input(placeholder=">", id="input", classes="panel")
        console_input.border_title = "Interactive Input"
        console_input.focus()
        yield console_input

    async def on_mount(self) -> None:
        self.process = await asyncio.create_subprocess_exec(
            f"{ROOT_DIR}/assistant.legacy.sh",
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT
        )
        self.output_task = asyncio.create_task(self.read_output())
        self.monitor_task = asyncio.create_task(self.monitor_process())

    async def read_output(self):
        log_widget = self.query_one("#output", Log)
        buffer = ""

        while True:
            chunk = await self.process.stdout.readline()
            if not chunk:
                break

            decoded_chunk = chunk.decode()
            buffer += decoded_chunk

            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                log_widget.write(line + "\n")
                log_widget.scroll_end(animate=False)

        if buffer:
            log_widget.write(buffer)
            log_widget.scroll_end(animate=False)

    async def monitor_process(self):
        await self.process.wait()
        self.exit(message="Process finished.")

    async def on_input_submitted(self, message: Input.Submitted) -> None:
        user_input = message.value + "\n"
        self.process.stdin.write(user_input.encode())
        await self.process.stdin.drain()
        message.input.value = ""

    async def on_click(self, event: Click) -> None:
        print(vars(event))
        if event.widget.id == "output":
            self.query_one("#input", Input).focus()


def close_tmux_session(session_name) -> None:
    """Close a tmux session by name.

    Args:
        session_name (_type_): Name of the tmux session to close.
    """
    # Create a new tmux server connection
    server = libtmux.Server()

    # Find the session by name
    session = server.find_where({'session_name': session_name})

    if session:
        session.kill_session()
        print(f"Session '{session_name}' has been closed.")
    else:
        print(f"No session found with the name '{session_name}'.")

    sys.exit(0)  # Exit the script after closing the session


if __name__ == "__main__":
    while True:
        print("Starting Maintenance Assistant...")
        app = MyApp()
        app.run()
        print("Maintenance Assistant has stopped.")
        if input("Do you want to restart the Maintenance Assistant? (y/N): ").lower() != 'y':
            close_tmux_session(SESSION_NAME)
