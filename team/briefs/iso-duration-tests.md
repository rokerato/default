# Task: Write a pytest suite for an ISO 8601 duration parser

## Context
A teammate is implementing, in parallel, a module `iso_duration.py` exposing:

    def parse_duration(value: str) -> float

You are writing the test suite for it against the specification below. The
implementation does not exist in your directory yet and you must NOT write it
— your tests will be run against the other teammate's module after both tasks
finish. Write the tests purely from this spec. Python 3.11+, pytest.

## Specification under test

    [+-] P [nW] [nD] [ T [nH] [nM] [nS] ]

- Designators are uppercase only. Lowercase input (`pt1h`) is invalid.
- Component values are non-negative integers, except seconds, which may be
  decimal: `PT1.5S` is valid. `.` is the only decimal separator; `,` is
  invalid.
- Components are optional individually but at least one must be present:
  `P` alone and `PT` alone are both invalid.
- If `T` is present it must be followed by at least one time component.
- Components must appear in the order shown. `PT1M1H` is invalid.
- Each component may appear at most once. `PT1H1H` is invalid.
- `W` (weeks) may be combined freely with the other components.
- A leading `-` negates the whole duration; `+` means the same as no sign.
- 1W = 604800s, 1D = 86400s, 1H = 3600s, 1M (time part) = 60s, 1S = 1s.
- Years and months (`P1Y`, `P2M`) raise `ValueError` — no fixed second count.
- Any other malformed input raises `ValueError`.
- Non-`str` input raises `TypeError`.
- The return value is always a `float`: `parse_duration("PT1H30M") == 5400.0`.

## Task
Create `test_iso_duration.py` with `from iso_duration import parse_duration`
at module level. Cover at least:

1. Simple single components (hours, minutes, seconds, days, weeks).
2. Combined components, including a full `P1W2DT3H4M5S`-style value.
3. Fractional seconds, including a case where the total is not a whole number.
4. Sign handling: `-`, `+`, and none.
5. Zero-ish values such as `PT0S`.
6. Every invalid-input rule above, each asserting `ValueError` via
   `pytest.raises` — lowercase, out-of-order, repeated component, bare `P`,
   bare `PT`, `T` with no time part, comma decimal, empty string, garbage,
   and years/months.
7. `TypeError` for non-string input (e.g. `None`, `123`).

Use `@pytest.mark.parametrize` for the tabular valid/invalid cases rather than
writing many near-identical test functions.

## Constraints
- Work only inside the directory you were started in.
- Create exactly one file: `test_iso_duration.py`. Do NOT create
  `iso_duration.py` or any stub, mock, or fake of it — not even to make the
  tests importable or runnable. It is expected and correct that the suite
  cannot run yet.
- Do not run any git commands.
- pytest only; no other third-party dependencies.
- Assert exact expected values, not just "does not raise".

## Deliverable
`test_iso_duration.py` in the current directory. Since the module under test
is absent, you cannot execute the suite — instead re-read your file and check
each expected value by hand against the spec above before finishing.
