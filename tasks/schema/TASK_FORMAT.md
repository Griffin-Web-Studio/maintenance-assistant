# Task File Format

Task files are YAML documents validated against a JSON Schema.
Each file describes one maintenance task as an ordered sequence of interactive steps.

## Why YAML and JSON Schema

Task files are authored by humans, so YAML is used for its readability,
multi-line string support (block scalars), and inline comments. The JSON
Schema (`task.schema.v1.json`) is the machine-readable contract used for
validation. PyYAML is already a project dependency; validation requires
`jsonschema` (`pip install jsonschema`).

To get IDE autocompletion and inline validation in VS Code, add this comment
to the top of any task YAML file:

```yaml
# yaml-language-server: $schema=./schema/task.schema.v1.json
```

---

## Top-level structure

```yaml
task-version: "1.0.0"

task:
  id: task2
  order: 2
  name: Maintenance Updates & Upgrades
  description: |
    Multi-line description shown on the task overview screen.

steps:
  - id: apt_update
    ...
```

| Field | Required | Description |
|---|---|---|
| `task-version` | yes | Semver. Runner uses the major to pick the schema. |
| `task.id` | yes | snake_case, unique across all task files. |
| `task.order` | yes | Integer >= 1. Controls menu order. Must be unique. |
| `task.name` | yes | Short label shown in menus. |
| `task.description` | no | Shown on the task overview screen. |
| `steps` | yes | Ordered list. See Step below. |

---

## Step types

Every step has a `type` that controls how the runner handles it.

### `manual`

The operator does something externally (e.g. log into a control panel, initiate
a backup) and then confirms via the numbered choices. The runner does not execute
any command — it only manages the prompt and logging.

```yaml
- id: backup_vps_snapshot
  name: VPS Snapshot
  type: manual
  description: |
    Log in to the IONOS ISP and create a complete VPS snapshot.
    THIS IS ESSENTIAL IN CASE SOMETHING GOES WRONG.
  confirm: "Did you create a VPS snapshot?"
  choices:
    - label: "yes"
      outcome: advance
    - label: "no"
      outcome: retry
    - label: "no need"
      outcome: advance
      skip_steps: [backup_vps_snapshot_verify]
```

### `run`

The runner executes a shell command when the operator picks a choice with
`outcome: run`. Output is shown in the terminal and optionally appended to a
log file. A `post_run` block can add follow-up prompts after the command
completes.

```yaml
- id: apt_upgrade
  name: apt-get upgrade
  type: run
  command: sudo apt-get upgrade -y
  log_to: "apt-upgrade/log-{maintenance_start_time}.log"
  confirm: "Are you ready to run 'sudo apt-get upgrade -y'?"
  choices:
    - label: "yes"
      outcome: run
    - label: "no"
      outcome: retry
    - label: "no (after reboot)"
      outcome: advance
  post_run:
    - confirm: "All went well? Reboot now?"
      choices:
        - label: "yes"
          outcome: reboot
        - label: "no (skip, continue)"
          outcome: advance
          recommended: true
```

`command` is required for `type: run`. Validated by the schema.

### `info`

The runner executes the command automatically (after the operator presses a key)
and displays the output for the operator to read or copy. The choices then
confirm the operator is done.

```yaml
- id: server_info_motd
  name: Copy MOTD Banner
  type: info
  command: run-parts /etc/update-motd.d/
  log_to: "mot.d/log-{maintenance_start_time}.log"
  confirm: "Did you copy the banner above?"
  choices:
    - label: "yes"
      outcome: advance
    - label: "no"
      outcome: retry
```

`command` is required for `type: info`. Validated by the schema.

---

## Step fields

| Field | Required | Types | Description |
|---|---|---|---|
| `id` | yes | all | snake_case, unique within the task file. |
| `name` | yes | all | Short label for logs and progress display. |
| `type` | yes | all | `manual`, `run`, or `info`. |
| `title` | no | all | Screen heading. Defaults to `name`. |
| `description` | no | all | Body text shown on the step screen. |
| `command` | yes* | run, info | Shell command to execute. *Required for these types. |
| `log_to` | no | run | Log file path relative to `logDir`. Supports `{maintenance_start_time}`. |
| `confirm` | yes | all | Question displayed above the choices list. |
| `depends_on` | no | all | Step id. If that step was skipped, this step is auto-skipped. Validated at runtime. |
| `choices` | yes | all | Numbered options. See Choices below. |
| `post_run` | no | run | Follow-up prompts after the command completes. See Post-run below. |

---

## Choices

Each step has a `choices` list — the numbered options shown to the operator.

```yaml
choices:
  - label: "yes"
    outcome: run
  - label: "no"
    outcome: retry
  - label: "no (after reboot)"
    outcome: advance
```

| Field | Required | Description |
|---|---|---|
| `label` | yes | Text shown next to the number, e.g. `yes`, `no (skip)`. |
| `outcome` | yes | See Outcomes below. |
| `recommended` | no | Marks the preferred option. Renders `[Y/n]`. Empty input selects this choice. At most one per step. |
| `skip_steps` | no | List of step ids to auto-skip when this choice is taken. Validated at runtime. |

### Outcomes

| Outcome | Description |
|---|---|
| `advance` | Mark step done and move to the next. |
| `retry` | Redisplay this step. Use for `no` when the operator must act before continuing. |
| `run` | Execute the step command, then show `post_run` if present, then advance. Only valid on `type: run` steps. |

`outcome: run` is only valid on `type: run` steps. Validated at runtime.

### The `recommended` field

Setting `recommended: true` on a choice renders a `[Y/n]` hint next to the
`confirm` question and accepts empty input as that choice. Only one choice
per step should have this set. The capital letter in `[Y/n]` or `[y/N]` signals
which is the default — this is a display convention the runner is responsible
for rendering correctly.

### The `skip_steps` field

Used for the "no need" pattern: when an operator confirms that a step is not
applicable, later steps that depend on that outcome should be skipped rather
than shown.

```yaml
- label: "no need"
  outcome: advance
  skip_steps: [backup_vps_snapshot_verify]
```

The step ids in `skip_steps` must exist in the same task file. Validated at
runtime, not by the schema.

An alternative to `skip_steps` for tighter coupling is `depends_on` on the
downstream step:

```yaml
- id: backup_vps_snapshot_verify
  depends_on: backup_vps_snapshot
  ...
```

If the `backup_vps_snapshot` step was skipped (i.e. the operator chose
`outcome: advance` without running the command, or `skip_steps` pointed at it),
`backup_vps_snapshot_verify` is auto-skipped.

---

## Post-run prompts

`post_run` is a list of follow-up prompts shown after a `type: run` step's
command completes. Use it for decisions tightly coupled to the execution that
just happened — not for independent next-step decisions.

```yaml
post_run:
  - confirm: "Disable root shell login?"
    choices:
      - label: "yes"
        recommended: true
        command: sudo usermod -s /usr/sbin/nologin root
        log: "Root shell login: disabled"
      - label: "no"
        command: sudo usermod -s /bin/bash root
        log: "Root shell login: left enabled"
```

Post-run choices differ from step choices: they run a secondary command and/or
navigate, rather than deciding whether to run the primary command.

| Field | Required | Description |
|---|---|---|
| `label` | yes | Text shown next to the number. |
| `recommended` | no | Same as step choice recommended. |
| `command` | no | Shell command to run when this option is selected. |
| `log` | no | Log entry written when this option is selected. |
| `outcome` | no | `advance` (default) or `reboot`. |

When `outcome` is omitted the runner always advances after the post-run prompt
resolves.

### When to use post_run vs a separate step

Use `post_run` when:
- The follow-up question only makes sense in the context of the command that
  just ran (e.g. "reboot after upgrade?" has no meaning without the upgrade).
- The follow-up is not reusable on its own.

Use a separate step with `depends_on` when:
- The follow-up is a distinct action that could appear in other tasks.
- The follow-up involves more than a single command or its own choices.

---

## Nesting depth reference

```
steps                            level 1
  step                           level 2
    choices / post_run           level 3
      choice / post_run item     level 4
        post_run.choices         level 5
          post_run choice        level 6
```

Six logical levels. The schema and runner support this depth. Do not exceed it
by adding nesting inside post_run choices — if you need that, it is a signal
that the logic belongs in a shell script called from a `run` step.

---

## Runtime-validated constraints

These are enforced by the runner, not the JSON Schema, because JSON Schema
cannot perform cross-field reference checks.

| Constraint | Notes |
|---|---|
| `outcome: run` only on `type: run` steps | Error raised at load time. |
| `post_run` only on `type: run` steps | Error raised at load time. |
| `depends_on` id must exist in this task | Error raised at load time. |
| `skip_steps` ids must exist in this task | Error raised at load time. |
| At most one `recommended: true` per step | Warning at load time. |
| `task.order` must be unique across task files | Error raised at runner startup. |
| Step `id` must be unique within the task | Error raised at load time. |
