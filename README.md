# CICD Test Pipeline

This repository contains a Python FastAPI application with CI/CD workflows for
testing, Docker image publishing, security scanning, and deployment.

## Application

- Source code: `src/`
- Tests: `tests/`
- Project configuration: `pyproject.toml`
- Deployment script: `scripts/deploy.sh`

## Docker build and run

Build the production image:

```powershell
docker build --target production -t myapp:prod .
```

Build the development image:

```powershell
docker build --target development -t myapp:dev .
```

Run the production container:

```powershell
docker run -d -p 8000:8000 --name myapp-prod myapp:prod
```

If the container name is already in use, remove the old container first:

```powershell
docker stop myapp-prod
docker rm myapp-prod
docker run -d -p 8000:8000 --name myapp-prod myapp:prod
```

Check the health endpoint:

```powershell
curl http://localhost:8000/health
```

Expected response:

```json
{"status":"ok"}
```

Run the local development stack with Docker Compose:

```powershell
docker compose up --build
```

The Compose setup mounts source code for hot reload, maps host port `8000` to
container port `8000`, mounts persistent data at `/data`, mounts configuration
files read-only at `/config`, and configures a health check.

Stop the development stack:

```powershell
docker compose down
```

## Docker image size comparison

Build the comparison images:

```powershell
docker build --target single-stage -t myapp:single .
docker build --target production -t myapp:prod .
docker images myapp
```

Measured result:

| Stage | Image Size |
| ----- | ---------- |
| Single-stage | 160 MB |
| Multi-stage production | 160 MB |

Both images show the same rounded size because this application is small, both
images use `python:3.11-slim`, and both need the same runtime Python
dependencies. The multi-stage image is still cleaner because build tools and
temporary build artifacts remain in the builder stage instead of being copied
into the final runtime stage.

## Security scan

Scan the production image with Docker Scout:

```powershell
docker scout cves myapp:prod
```

Last recorded scan summary:

| Severity | Count |
| -------- | ----- |
| Critical | 0 |
| High | 2 |
| Medium | 5 |
| Low | 23 |

The detailed vulnerability findings and mitigation strategy are documented in
`documents/docker/Task_4_Healthcheck_Instructions.md`.

## SonarQube setup and analysis

Start a local SonarQube server:

```powershell
docker run -d --name sonarqube `
  -p 9000:9000 `
  -v sonarqube_data:/opt/sonarqube/data `
  sonarqube:2026.1-community
```

Open SonarQube:

```text
http://localhost:9000
```

Login with:

```text
admin / admin
```

Change the admin password, then create a manual project:

| Field | Value |
| ----- | ----- |
| Project key | `cicd-python-fastapi` |
| Display name | `CICD Python FastAPI` |

Generate a project token and store it securely. Do not commit the token.

PowerShell local token setup:

```powershell
$env:SONAR_TOKEN="paste-token-here"
```

Generate coverage:

```powershell
venv\Scripts\python.exe -m pytest --cov=src --cov-report=xml:coverage.xml
```

Run local SonarQube analysis:

```powershell
docker run --rm `
  -e SONAR_HOST_URL="http://host.docker.internal:9000" `
  -e SONAR_TOKEN="$env:SONAR_TOKEN" `
  -v "${PWD}:/usr/src" `
  sonarsource/sonar-scanner-cli
```

The project analysis configuration is in:

```text
sonar-project.properties
```

The GitHub Actions workflow is in:

```text
.github/workflows/sonarqube.yml
```

Configure these GitHub repository secrets:

```text
SONAR_TOKEN
SONAR_HOST_URL
```

SonarQube task documentation:

- `documents/sonarqube/Task_1_Setup_SonarQube_Server.md`
- `documents/sonarqube/Task_2_Project_Analysis.md`
- `documents/sonarqube/Task_3_GitHub_Actions_SonarQube.md`
- `documents/sonarqube/Task_4_Issue_Fixes.md`
- `documents/sonarqube/Task_5_Quality_Gate.md`

## Submission deliverables

| Requirement | Status | Location |
| ----------- | ------ | -------- |
| Source code for Python application | Done | `src/app.py` |
| Optimized multi-stage Dockerfile | Done | `Dockerfile` |
| `.dockerignore` file | Done | `.dockerignore` |
| `docker-compose.yml` for development | Done | `docker-compose.yml` |
| README with build and run instructions | Done | `README.md` |
| Screenshots of running container and vulnerability scan results | Add before final submission | `screenshots/` |
| SonarQube project configuration | Done | `sonar-project.properties` |
| SonarQube GitHub Actions workflow | Done | `.github/workflows/sonarqube.yml` |
| Documentation of fixed SonarQube issues | Done | `documents/sonarqube/Task_4_Issue_Fixes.md` |
| SonarQube dashboard and quality gate screenshots | Add before final submission | `screenshots/` |
| Manual SonarQube remaining checklist | Done | `documents/sonarqube/SUBMISSION_CHECKLIST.md` |

## Submission checklist

| Checklist item | Status | Notes |
| -------------- | ------ | ----- |
| Docker image builds without errors | Done | Build with `docker build --target production -t myapp:prod .` |
| Application runs correctly in container | Done | Verify with `curl http://localhost:8000/health` |
| Multi-stage build implemented with measurable size comparison | Done | See Docker image size comparison section |
| Non-root user configured | Done | Runtime targets use `USER appuser` |
| Health check working | Done | Dockerfile and Compose both check `/health` |
| Vulnerability scan completed | Done | Docker Scout summary documented above |
| SonarQube server running locally | Manual step | Start with the Docker command in the SonarQube section |
| Project analyzed successfully | Manual step | Run local scanner after creating token |
| SonarQube workflow configured | Done | `.github/workflows/sonarqube.yml` |
| Quality gate configured and enforced | Manual UI step plus workflow | Configure in SonarQube, enforced by GitHub Actions |
| At least 5 code issues fixed | Done | `src/data_processing.py` and `documents/sonarqube/Task_4_Issue_Fixes.md` |

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

- Running Docker container from `docker ps`.
- Successful health check response from `curl http://localhost:8000/health`.
- Docker Scout or Trivy vulnerability scan results.
- SonarQube dashboard after setup.
- SonarQube quality gate passing result.
- SonarQube quality gate failing result from an intentional test.
- Successful `CI Pipeline` workflow run.
- Successful `Docker Image` workflow run.
- Successful `Deploy` workflow run or pending production approval screen.
- Coverage table from the `Run tests with coverage` step.
- Artifacts section showing uploaded test artifacts.
- Downloaded artifact folder showing `junit.xml`, `coverage.xml`, and `htmlcov/`.
