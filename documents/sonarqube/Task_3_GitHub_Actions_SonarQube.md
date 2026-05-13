# Task 3: Integrate with GitHub Actions

## Workflow File

The SonarQube workflow is defined in:

```text
.github/workflows/sonarqube.yml
```

It runs on:

- push to `main`
- push to `master`
- pull requests targeting `main`
- pull requests targeting `master`

## Workflow Steps

The workflow:

1. Checks out the repository with full history.
2. Sets up Python 3.11.
3. Installs project dependencies with development tools.
4. Runs tests and creates `coverage.xml`.
5. Runs the SonarQube scan.
6. Waits for the quality gate result.

## Required GitHub Secrets

Configure these in the GitHub repository:

```text
SONAR_TOKEN
SONAR_HOST_URL
```

For a local-only SonarQube server, `SONAR_HOST_URL` is usually:

```text
http://localhost:9000
```

For GitHub-hosted runners, use a public or network-accessible SonarQube URL
instead of `localhost`.

## Quality Gate Enforcement

The workflow uses:

```yaml
- name: SonarQube Quality Gate
  uses: SonarSource/sonarqube-quality-gate-action@v1
  timeout-minutes: 5
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

If the quality gate fails, the workflow fails.
