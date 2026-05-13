# CICD Test Pipeline

This repository contains a Python FastAPI application with CI/CD workflows for
testing, Docker image publishing, security scanning, and deployment.

## Application

- Source code: `src/`
- Tests: `tests/`
- Project configuration: `pyproject.toml`
- Deployment script: `scripts/deploy.sh`

## Workflows

### CI pipeline

Workflow file:

```text
.github/workflows/ci.yml
```

The CI pipeline runs on pushes to `master`, `main`, and `develop`, and on pull
requests targeting `master` or `main`.

It includes:

- Ruff linting.
- Black formatting check.
- Matrix testing across Python `3.10`, `3.11`, and `3.12`.
- Matrix testing on `ubuntu-latest` and `macos-latest`.
- pip dependency caching with a cache key based on `pyproject.toml`.
- pytest coverage reporting.
- JUnit XML test results.
- Uploaded test artifacts.
- Codecov coverage upload.

The test job depends on the lint job, so tests only run after linting passes.

### Docker build pipeline

Workflow file:

```text
.github/workflows/docker.yml
```

The Docker workflow runs on pushes to `master`, `main`, and `develop`, but only
when application or Docker build files change. Documentation-only changes are
skipped by the paths filter.

It includes:

- Docker image build using the `production` target.
- GHCR login with `GITHUB_TOKEN`.
- Image tags using the commit SHA.
- `latest` tag for `master` and `main`.
- Trivy image scanning.
- Push to GitHub Container Registry.

Images are published to:

```text
ghcr.io/<owner>/<repository>
```

### Deployment pipeline

Workflow file:

```text
.github/workflows/deploy.yml
```

The deployment workflow runs after the Docker workflow completes successfully.

Deployment behavior:

- `develop` branch deploys automatically to `staging`.
- `main` and `master` deploy to `production`.
- Production approval is handled with GitHub Environment protection rules.
- `scripts/deploy.sh` pulls the Docker image, starts the container, runs a
  health check, and reports deployment status.

Deployment flow:

```text
Code Push -> CI Tests -> Build Image -> Deploy Staging -> Manual Approval -> Deploy Production
```

## GitHub setup

Enable workflow package publishing:

1. Open the GitHub repository.
2. Go to `Settings > Actions > General`.
3. Set workflow permissions to `Read and write permissions`.

Configure production approval:

1. Go to `Settings > Environments`.
2. Create or open the `production` environment.
3. Enable `Required reviewers`.
4. Add the reviewer who must approve production deployments.

Configure Codecov if required:

1. Add repository secret `CODECOV_TOKEN`.
2. The CI workflow uses it automatically during coverage upload.

## Screenshots for submission

Recommended screenshots:

- Successful `CI Pipeline` workflow run.
- Successful `Docker Image` workflow run.
- Successful `Deploy` workflow run or pending production approval screen.
- Coverage table from the `Run tests with coverage` step.
- Artifacts section showing uploaded test artifacts.
- Downloaded artifact folder showing `junit.xml`, `coverage.xml`, and `htmlcov/`.
