"""Parse the supported fixed-length subset of ISO 8601 durations."""

import re


_DURATION_PATTERN = re.compile(
    r"^(?P<sign>[+-]?)P"
    r"(?P<weeks>\d+W)?"
    r"(?P<days>\d+D)?"
    r"(?:T"
    r"(?P<hours>\d+H)?"
    r"(?P<minutes>\d+M)?"
    r"(?P<seconds>\d+(?:\.\d+)?S)?"
    r")?$",
    # re.ASCII: without it \d also matches non-ASCII digits (e.g. Arabic-Indic
    # "PT١H"), which float() then happily converts.
    re.ASCII,
)


def parse_duration(value: str) -> float:
    """Convert a supported ISO 8601 duration string to seconds."""
    if not isinstance(value, str):
        raise TypeError("duration must be a string")

    date_part = value.lstrip("+-").partition("T")[0]
    if re.search(r"\d+[YM]", date_part, re.ASCII):
        raise ValueError("years and months are unsupported")

    match = _DURATION_PATTERN.fullmatch(value)
    if match is None:
        raise ValueError(f"invalid ISO 8601 duration: {value!r}")

    parts = match.groupdict()
    date_components = parts["weeks"] or parts["days"]
    time_components = parts["hours"] or parts["minutes"] or parts["seconds"]
    if not date_components and not time_components:
        raise ValueError(f"invalid ISO 8601 duration: {value!r}")
    if "T" in value and not time_components:
        raise ValueError(f"invalid ISO 8601 duration: {value!r}")

    total = 0.0
    for name, multiplier in (
        ("weeks", 604800),
        ("days", 86400),
        ("hours", 3600),
        ("minutes", 60),
        ("seconds", 1),
    ):
        component = parts[name]
        if component:
            total += float(component[:-1]) * multiplier

    return -total if parts["sign"] == "-" else total
