from npyscreen import NPSAppManaged

from helpers.cli_params import parse_args
from forms.main_menu import MainMenuForm


class SMA(NPSAppManaged):
    def __init__(self, args):
        super().__init__()
        self.args = args

    def onStart(self):
        self.addForm("MAIN", MainMenuForm)


if __name__ == "__main__":
    app = SMA(parse_args())
    app.run()
