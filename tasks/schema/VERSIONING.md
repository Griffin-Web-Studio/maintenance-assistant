# Schema Versioning

## How versions work

Task files carry a `task-version` field (semver). The runner reads the **major**
component and loads the matching schema file from this directory:

```
tasks/schema/task.schema.v1.json   handles all 1.x.x task files
tasks/schema/task.schema.v2.json   handles all 2.x.x task files
```

The runner only creates a new schema file when a **major** version is bumped.
Minor and patch changes are applied in-place to the current major's schema file.

---

## Semver rules

| Type of change | Bump | Schema file action |
|---|---|---|
| Add a new optional field | **minor** (1.0 -> 1.1) | Update existing file |
| Add a new optional outcome or type | **minor** | Update existing file |
| Fix an incorrect schema constraint | **patch** (1.0.0 -> 1.0.1) | Update existing file |
| Remove a field | **major** (1.x -> 2.0) | New schema file |
| Rename a field | **major** | New schema file |
| Change a field's type or semantics | **major** | New schema file |
| Make an optional field required | **major** | New schema file |

When in doubt, treat the change as **major**. A false major bump has no
operational cost. A missed major bump silently corrupts task files in the field.

---

## Adding a new major version

1. Copy the current schema to a new versioned file:
   ```
   cp tasks/schema/task.schema.v1.json tasks/schema/task.schema.v2.json
   ```

2. Apply breaking changes to `task.schema.v2.json`.

3. Update `$id` inside the new file:
   ```json
   "$id": "gws-maintenance/task/2.0.0"
   ```

4. Add the new major to the runner's supported set (see Runner compatibility
   below).

5. Do not edit `task.schema.v1.json` again. It is now frozen.

6. Update existing task `.yml` files to `task-version: "2.0.0"` and adjust
   any fields that changed.

---

## Adding a minor or patch change

1. Edit the current major's schema file in place
   (e.g. `task.schema.v1.json`).

2. Update `$id` to reflect the new minor or patch:
   ```json
   "$id": "gws-maintenance/task/1.1.0"
   ```

3. No task files need updating — the runner still loads `task.schema.v1.json`
   for all 1.x.x files.

Note: because the schema uses `additionalProperties: false`, a task file
authored against v1.1 (with a new optional field) will fail validation against
a runner that only ships v1.0 of the schema. This is intentional — the runner
version gates what task format it can accept. See Forward compatibility below.

---

## Runner compatibility

The runner defines the range of major versions it supports. Example:

```python
from pathlib import Path
from packaging.version import Version
import json, yaml, jsonschema

SCHEMA_DIR = Path("tasks/schema")
SUPPORTED_MAJORS = {1}            # extend this set as new majors ship

MIN_VERSION = {1: Version("1.0.0")}
MAX_VERSION = {1: Version("1.99.99")}

def load_task(path: Path) -> dict:
    with open(path) as f:
        data = yaml.safe_load(f)

    raw = data.get("task-version", "")
    try:
        v = Version(raw)
        major = v.major
    except Exception:
        raise ValueError(f"Invalid task-version: {raw!r}")

    if major not in SUPPORTED_MAJORS:
        raise ValueError(
            f"task-version {raw!r} is not supported by this runner "
            f"(supported majors: {sorted(SUPPORTED_MAJORS)})"
        )

    if not (MIN_VERSION[major] <= v <= MAX_VERSION[major]):
        raise ValueError(
            f"task-version {raw!r} is outside the supported range for v{major} "
            f"({MIN_VERSION[major]} - {MAX_VERSION[major]})"
        )

    schema_path = SCHEMA_DIR / f"task.schema.v{major}.json"
    with open(schema_path) as f:
        schema = json.load(f)

    jsonschema.validate(data, schema)
    return data
```

---

## Forward compatibility

`additionalProperties: false` is intentional — it catches typos in field names
immediately rather than silently ignoring them. The side effect is that a task
file using a field introduced in v1.1 will fail validation against a runner
shipping only v1.0 schema.

This is the right trade-off for this project: task files and the runner are
deployed together. If they are ever decoupled (e.g. task files shared across
runner versions), revisit this and consider removing `additionalProperties: false`
from fields that are expected to gain new properties over time.

---

## Git history

- Never edit a frozen major schema file after a newer major ships.
- Commit all schema file changes with a message that includes the version change,
  e.g. `docs(schema): add depends_on field (v1.1.0)`.
- The git log on a schema file is the changelog for that major version.

---

## Frozen versions

| Version | File | Status |
|---|---|---|
| v1 | task.schema.v1.json | active |

Update this table when a new major is released.
