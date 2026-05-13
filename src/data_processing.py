import hashlib
import logging
from collections.abc import Callable

logger = logging.getLogger(__name__)


def parse_csv_values(data: str | None) -> list[str]:
    if not data:
        return []

    return [value.strip() for value in data.split(",") if value.strip()]


def mask_secret(secret: str | None) -> str:
    if not secret:
        return ""

    digest = hashlib.sha256(secret.encode("utf-8")).hexdigest()
    return f"sha256:{digest[:12]}"


def run_safely(operation: Callable[[], str]) -> str | None:
    try:
        return operation()
    except RuntimeError as exc:
        logger.warning("Recoverable operation failed: %s", exc)
        return None


def average_score(scores: list[float]) -> float:
    if not scores:
        return 0.0

    return sum(scores) / len(scores)


def normalize_username(username: str | None) -> str:
    if username is None:
        return "anonymous"

    normalized = username.strip().lower()
    return normalized or "anonymous"
