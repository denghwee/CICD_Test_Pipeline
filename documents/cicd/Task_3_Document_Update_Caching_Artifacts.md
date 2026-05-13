# Document Update: Caching and Artifacts

## Dependency caching

The CI workflow caches pip downloads with `actions/cache@v4`.

The cache key includes:

- The runner operating system.
- The Python version.
- A hash of `pyproject.toml`.

```yaml
key: ${{ runner.os }}-python-${{ matrix.python-version }}-pip-${{ hashFiles('pyproject.toml') }}
```

This means the cache is reused when dependencies stay the same, and it is
automatically refreshed when `pyproject.toml` changes.

The workflow also defines a restore key:

```yaml
restore-keys: |
  ${{ runner.os }}-python-${{ matrix.python-version }}-pip-
```

This allows GitHub Actions to use the closest matching pip cache if the exact
hash does not exist yet.

## Test artifacts

The test job creates and uploads these artifacts:

- `reports/junit.xml`: pytest results in JUnit XML format.
- `reports/coverage.xml`: coverage report for Codecov.
- `reports/htmlcov/`: HTML coverage report for manual review.

The upload step uses `if: always()` so artifacts are still uploaded when tests
fail. This makes debugging failed CI runs easier.

## Codecov integration

Coverage is uploaded with `codecov/codecov-action@v4`:

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  if: always()
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    files: reports/coverage.xml
    flags: ${{ matrix.os }}-py${{ matrix.python-version }}
    name: ${{ matrix.os }}-python-${{ matrix.python-version }}
    fail_ci_if_error: false
```

For private repositories, add a repository secret named `CODECOV_TOKEN` in
GitHub. Public repositories can often upload without a token, depending on the
Codecov project settings.

## Cache timing measurement

Record the build time from the GitHub Actions run summary before and after the
pip cache is populated.

| Run Type | Build Time |
| -------- | ---------- |
| Without cache | ? seconds |
| With cache | ? seconds |

To measure it:

1. Run the workflow once after adding the cache. The first run usually has a
   cache miss, so record this as `Without cache`.
2. Re-run the same workflow without changing `pyproject.toml`. This should use
   a cache hit, so record this as `With cache`.
3. Compare the total time of the `Install dependencies` step or the full test
   job time.
