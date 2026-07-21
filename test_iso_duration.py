"""Tests for iso_duration.parse_duration against the ISO 8601 duration subset.

Specification:
    [+-] P [nW] [nD] [ T [nH] [nM] [nS] ]

Conversion factors (seconds):
    1W = 604800, 1D = 86400, 1H = 3600, 1M (time) = 60, 1S = 1
"""

import pytest

from iso_duration import parse_duration


# ---------------------------------------------------------------------------
# Valid inputs
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "value, expected",
    [
        # 1. Simple single components
        ("PT1H", 3600.0),
        ("PT2H", 7200.0),
        ("PT1M", 60.0),
        ("PT30M", 1800.0),
        ("PT1S", 1.0),
        ("PT45S", 45.0),
        ("P1D", 86400.0),
        ("P2D", 172800.0),
        ("P1W", 604800.0),
        ("P3W", 1814400.0),
        # 2. Combined components
        ("PT1H30M", 5400.0),
        ("PT1H30M15S", 5415.0),
        ("P1DT2H", 93600.0),
        ("P1W2D", 777600.0),
        ("P1W2DT3H4M5S", 788645.0),  # 604800+172800+10800+240+5
        ("P2WT1H", 1213200.0),  # 2*604800 + 3600
        ("P1DT1S", 86401.0),
        ("PT1H1S", 3601.0),
        # 3. Fractional seconds (including non-whole totals)
        ("PT1.5S", 1.5),
        ("PT0.5S", 0.5),
        ("PT1H0.25S", 3600.25),
        ("PT10.125S", 10.125),
        ("P1DT0.5S", 86400.5),
        # 4. Sign handling: none, +, -
        ("PT1H", 3600.0),
        ("+PT1H", 3600.0),
        ("-PT1H", -3600.0),
        ("-P1D", -86400.0),
        ("+P1W", 604800.0),
        ("-P1W2DT3H4M5S", -788645.0),
        ("-PT1.5S", -1.5),
        ("+PT0.5S", 0.5),
        # 5. Zero-ish values
        ("PT0S", 0.0),
        ("PT0H", 0.0),
        ("PT0M", 0.0),
        ("P0D", 0.0),
        ("P0W", 0.0),
        ("PT0H0M0S", 0.0),
        ("P0W0DT0H0M0S", 0.0),
        ("-PT0S", 0.0),
        ("+PT0S", 0.0),
        ("PT0.0S", 0.0),
        ("PT3600S", 3600.0),
        ("P7D", 604800.0),  # equivalent to P1W
    ],
)
def test_parse_duration_valid(value: str, expected: float) -> None:
    result = parse_duration(value)
    assert isinstance(result, float)
    assert result == expected


def test_return_type_is_float() -> None:
    """Return value is always a float, even for whole-second totals."""
    result = parse_duration("PT1H30M")
    assert type(result) is float
    assert result == 5400.0


# ---------------------------------------------------------------------------
# Invalid inputs → ValueError
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "value",
    [
        # Lowercase designators / components
        "pt1h",
        "Pt1H",
        "pT1H",
        "PT1h",
        "PT1m",
        "PT1s",
        "P1d",
        "P1w",
        "p1D",
        "pt1H",
        # Out-of-order components
        "PT1M1H",
        "PT1S1M",
        "PT1S1H",
        "P1DT1S1H",
        "P1D1W",
        "PT1H1S1M",
        # Repeated component
        "PT1H1H",
        "PT1M1M",
        "PT1S1S",
        "P1D1D",
        "P1W1W",
        "PT1H30M1H",
        # Bare P / bare PT
        "P",
        "PT",
        "+P",
        "-P",
        "+PT",
        "-PT",
        # T present but no time component
        "P1DT",
        "P1WT",
        # Comma as decimal separator (only '.' is allowed)
        "PT1,5S",
        "PT0,5S",
        "PT1H1,5S",
        # Empty string
        "",
        # Garbage / malformed
        "hello",
        "1H",
        "T1H",
        "P T1H",
        "PT1H ",
        " PT1H",
        "PT1H2",
        "P1",
        "P1X",
        "PT1X",
        "PX",
        "P1.5D",  # only seconds may be decimal
        "P1.5W",
        "PT1.5H",
        "PT1.5M",
        "P-1D",  # sign only allowed at the start of the whole duration
        "PT-1H",
        "PT1H-30M",
        "PPT1H",
        "PTT1H",
        "PT1HH",
        "P1DD",
        "1",
        # Non-ASCII digits: Python's \d matches these and float() accepts them,
        # so without re.ASCII "PT١H" parses as 3600.0 instead of raising.
        "PT١H",
        "P١D",
        "PT1H\n",  # `$` matches before a trailing newline; fullmatch must not
        # Years and months — no fixed second count
        "P1Y",
        "P2M",
        "P1M",  # date-part M is months, not minutes
        "P1Y2M",
        "P1Y1D",
        "P2MT1H",
        "P1YT1S",
        "P1Y2M3D",
        "-P1Y",
        "+P2M",
    ],
)
def test_parse_duration_invalid_raises_value_error(value: str) -> None:
    with pytest.raises(ValueError):
        parse_duration(value)


# ---------------------------------------------------------------------------
# Non-str input → TypeError
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "value",
    [
        None,
        123,
        1.5,
        True,
        False,
        b"PT1H",
        ["PT1H"],
        {"duration": "PT1H"},
        (),
        object(),
    ],
)
def test_parse_duration_non_str_raises_type_error(value: object) -> None:
    with pytest.raises(TypeError):
        parse_duration(value)  # type: ignore[arg-type]
