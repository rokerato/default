# Task: Implement an ISO 8601 duration parser in Python

## Context
Standalone utility function for a Python 3.11+ codebase. No project
dependencies — standard library only. You cannot see the rest of the repo and
do not need to; everything required is in this brief.

## Task
Create `iso_duration.py` containing exactly one public function:

    def parse_duration(value: str) -> float

It converts an ISO 8601 duration string into a total number of seconds.

### Grammar to accept

    [+-] P [nW] [nD] [ T [nH] [nM] [nS] ]

- Designators are uppercase only. Lowercase input (`pt1h`) is invalid.
- Component values are non-negative integers, except seconds, which may be
  decimal: `PT1.5S` is valid. Use `.` as the decimal separator only; `,` is
  invalid.
- Components are optional individually but at least one must be present:
  `P` alone and `PT` alone are both invalid.
- If `T` is present it must be followed by at least one time component.
- Components must appear in the order shown. `PT1M1H` is invalid.
- Each component may appear at most once. `PT1H1H` is invalid.
- `W` (weeks) may be combined freely with the other components.
- A leading `-` negates the whole duration; a leading `+` is accepted and
  means the same as no sign.

### Conversions
- 1W = 604800s, 1D = 86400s, 1H = 3600s, 1M (time part) = 60s, 1S = 1s.

### Errors
- Years and months (`P1Y`, `P2M` in the date part) are NOT supported, because
  they have no fixed length in seconds. Raise `ValueError` with a message
  that says years and months are unsupported.
- Any other malformed input raises `ValueError`.
- A non-`str` argument raises `TypeError`.

### Return value
Always a `float`, e.g. `parse_duration("PT1H30M") == 5400.0`, and
`parse_duration("-PT1H") == -3600.0`.

## Constraints
- Work only inside the directory you were started in. Create no other files.
- Standard library only. A module-level compiled `re` pattern is fine.
- Do not run any git commands.
- Do not write tests — a separate task covers those.
- Include a concise docstring and type hints. Keep it readable; this is a
  small function, not a framework.

## Deliverable
`iso_duration.py` in the current directory, containing `parse_duration`.
Verify it imports and that `parse_duration("PT1H30M")` returns `5400.0`
before you finish.
