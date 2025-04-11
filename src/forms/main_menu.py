import distro
from npyscreen import (
    TitleText,
    Form,
)

from utils.forms import form_title


class MainMenuForm(Form):
    def create(self):
        self.name = form_title("Main Menu")

        # Access the global parameters from the app
        os_name = distro.name()
        os_version = distro.version()

        # Display the parameters in the form
        self.add(TitleText, name="OS Name:", value=str(os_name))
        self.add(TitleText, name="OS Version:", value=str(os_version))

    def afterEditing(self):
        self.parentApp.setNextForm(None)
