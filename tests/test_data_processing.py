import pytest

from src.data_processing import (
    average_score,
    mask_secret,
    normalize_username,
    parse_csv_values,
    run_safely,
)


def test_parse_csv_values_handles_none_and_empty_values() -> None:
    assert parse_csv_values(None) == []
    assert parse_csv_values("alpha, beta, ,gamma") == ["alpha", "beta", "gamma"]


def test_mask_secret_returns_non_plaintext_digest() -> None:
    masked = mask_secret("admin123")

    assert masked.startswith("sha256:")
    assert "admin123" not in masked


def test_run_safely_handles_expected_runtime_error() -> None:
    def failing_operation() -> str:
        raise RuntimeError("temporary failure")

    assert run_safely(failing_operation) is None


def test_run_safely_does_not_swallow_unexpected_errors() -> None:
    def failing_operation() -> str:
        raise ValueError("bad input")

    with pytest.raises(ValueError, match="bad input"):
        run_safely(failing_operation)


def test_average_score_handles_empty_list() -> None:
    assert average_score([]) == 0.0
    assert average_score([80.0, 90.0]) == 85.0


def test_normalize_username_has_safe_default() -> None:
    assert normalize_username(None) == "anonymous"
    assert normalize_username("  Admin  ") == "admin"
