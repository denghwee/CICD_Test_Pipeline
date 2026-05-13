# Document Update: Matrix Testing

## Matrix configuration

The CI workflow uses a test matrix to run the same `test` job across multiple
Python versions and operating systems:

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, macos-latest]
    python-version: ["3.10", "3.11", "3.12"]
```

This creates six test combinations:

| OS | Python |
| --- | --- |
| ubuntu-latest | 3.10 |
| ubuntu-latest | 3.11 |
| ubuntu-latest | 3.12 |
| macos-latest | 3.10 |
| macos-latest | 3.11 |
| macos-latest | 3.12 |

The job name includes the matrix values so each result is easy to identify in
GitHub Actions:

```yaml
name: Test (${{ matrix.os }}, Python ${{ matrix.python-version }})
```

## Fail-fast behavior

The workflow sets:

```yaml
fail-fast: false
```

This means GitHub Actions will continue running all matrix combinations even if
one combination fails. This is useful for CI because it shows whether a failure
is isolated to one Python version or operating system.

Use `fail-fast: true` when you want quicker feedback and lower CI cost, and
when one failed combination is enough to stop the rest of the matrix.

## When to use exclude

Use `exclude` when one or more matrix combinations should not run.

Common reasons:

- A dependency does not support a specific Python version on one OS.
- A test is known to be unsupported on a specific platform.
- A combination is too slow or unnecessary for the project.

Example:

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, macos-latest]
    python-version: ["3.10", "3.11", "3.12"]
    exclude:
      - os: macos-latest
        python-version: "3.10"
```

In this example, every combination runs except `macos-latest` with Python
`3.10`.
