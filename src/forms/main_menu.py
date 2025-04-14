from npyscreen import TitleText, Textfield, Form, SelectOne

from utils.forms import form_title


class MainMenuForm(Form):

    def create(self):
        self.name = form_title("Main Menu")

        # Title
        self.add(
            TitleText,
            name="Select a Task",
            value="",
            editable=False,
        )

        # Alternatively, using Textfield for a non-editable label
        self.add(
            Textfield,
            name="Task Selection",
            value="Choose one of the tasks below:",
            editable=False,
        )

        # Add radio buttons for task selection
        self.task_selection = self.add(
            SelectOne,
            name="Select Task:",
            values=["Task 1", "Task 2", "Task 3"],
            scroll_exit=True,
        )

    def afterEditing(self):
        selected_task = self.task_selection.get_selected_objects()
        if selected_task:
            task_name = selected_task[0]  # Get the selected task name
            if task_name == "Task 1":
                self.parentApp.setNextForm("MAIN")
            elif task_name == "Task 2":
                self.parentApp.setNextForm("TASK2")
            elif task_name == "Task 3":
                self.parentApp.setNextForm("TASK3")
        else:
            self.parentApp.setNextForm(None)  # Exit if no task is selected
