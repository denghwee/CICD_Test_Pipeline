# Task 5: Configure Quality Gate

## Review Sonar Way

In SonarQube, open:

```text
Quality Gates > Sonar Way
```

Review the default conditions.

## Create Custom Quality Gate

Create a new quality gate, for example:

```text
CICD Python Quality Gate
```

Add these conditions on new code:

| Metric | Condition |
| ------ | --------- |
| New bugs | `= 0` |
| New vulnerabilities | `= 0` |
| New code coverage | `>= 80%` |
| New duplicated lines density | `<= 3%` |

Apply the quality gate to:

```text
CICD Python FastAPI
```

## Test Pass and Fail

Passing test:

1. Run tests with coverage.
2. Run SonarQube analysis.
3. Confirm the quality gate passes.
4. Save screenshot as `screenshots/quality-gate-pass.png`.

Failing test:

1. Temporarily add code that lowers coverage or introduces an issue.
2. Run analysis again.
3. Confirm the quality gate fails.
4. Save screenshot as `screenshots/quality-gate-fail.png`.
5. Revert the intentionally failing code after taking the screenshot.
