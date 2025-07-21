from npyscreen import TitleText, Textfield, ActionForm, SelectOne

from utils.forms import form_title

task_list = [
    "Initialise the Server",  # 0
    "---------------------",  # 1
    "Preparation",  # 2
    "Updates & Upgrades",  # 3
    "Server Load Monitoring",  # 4
    "Server Security",  # 5
    "Exit",  # 6
]


class MainMenuForm(ActionForm):

    def create(self):
        print("Creating MainMenuForm")
        self.name = form_title("Main Menu")

        # Title
        self.add(
            TitleText,
            name="Welcome to GWS Maintenance V2",
            value="",
            editable=False,
        )

        # Add a non-editable Text widget for the description
        self.description = self.add(
            Textfield,
            name="Description:",
            value="This is a non-editable description.",
            editable=False,
        )

        # Optionally, you can set the color or style to differentiate it
        self.description.color = "STANDOUT"

        self.add(
            Textfield,
            name="spacer",
            value="",
            editable=False,
        )

        # Alternatively, using Textfield for a non-editable label
        self.description = self.add(
            Textfield,
            name="Task Selection",
            value="Please Select a task below:",
            editable=False,
        )

        # Add radio buttons for task selection
        self.task_selection = self.add(
            SelectOne,
            name="Select Task:",
            values=task_list,
            scroll_exit=True,
        )

    def afterEditing(self):
        selected_task = self.task_selection.get_selected_objects()

        if selected_task:
            task_name = selected_task[0]  # Get the selected task name

            if task_name == task_list[0]:  # init server
                self.parentApp.setNextForm("TASK1")
            elif task_name == task_list[2]:  # init server
                self.parentApp.setNextForm("TASK2")
            elif task_name == task_list[3]:  # init server
                self.parentApp.setNextForm("TASK3")
            elif task_name == task_list[4]:  # init server
                self.parentApp.setNextForm("TASK3")
            elif task_name == task_list[5]:  # init server
                self.parentApp.setNextForm("TASK3")
            elif task_name == task_list[6]:  # init server
                self.parentApp.setNextForm(None)  # Exit if no task is selected
        else:
            self.parentApp.setNextForm(None)  # Exit if no task is selected
