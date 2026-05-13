# Task 4: Analyze and Fix Code Issues

## Intentional Issue Sample

Before:

```python
def process_data(data):
    result = data.split(",")
    password = "admin123"
    try:
        risky_operation()
    except:
        pass
    average = sum(result) / len(result)
    return password, average
```

## Fixed Implementation

The fixed code is implemented in:

```text
src/data_processing.py
```

## Before / After Comparison

| Issue Type | Before | After | Severity |
| ---------- | ------ | ----- | -------- |
| Bug | Called `data.split(",")` without checking for `None` | `parse_csv_values` accepts `str | None` and returns an empty list for missing input | Major |
| Vulnerability | Hardcoded password `admin123` | `mask_secret` hashes secrets and never returns plaintext | Critical |
| Code Smell | Used bare `except` and silently ignored errors | `run_safely` catches only `RuntimeError` and logs the failure | Major |
| Bug | Divided by `len(scores)` without handling an empty list | `average_score` returns `0.0` for empty input | Major |
| Code Smell | Used untyped, unclear data handling | Functions include type hints and focused responsibilities | Minor |
| Bug | Assumed username input is always present | `normalize_username` safely handles `None` and blank strings | Major |

## Verification

Run tests and coverage:

```powershell
pytest --cov=src --cov-report=xml:coverage.xml
```

Re-run SonarQube analysis:

```powershell
docker run --rm `
  -e SONAR_HOST_URL="http://host.docker.internal:9000" `
  -e SONAR_TOKEN="$env:SONAR_TOKEN" `
  -v "${PWD}:/usr/src" `
  sonarsource/sonar-scanner-cli
```

Confirm the issues are resolved in the SonarQube dashboard.
