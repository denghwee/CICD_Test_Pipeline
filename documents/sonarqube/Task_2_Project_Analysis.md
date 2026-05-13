# Task 2: Configure Project Analysis

## Configuration File

The repository includes:

```text
sonar-project.properties
```

Configuration:

```properties
sonar.projectKey=cicd-python-fastapi
sonar.projectName=CICD Python FastAPI
sonar.sources=src
sonar.tests=tests
sonar.python.version=3.11
sonar.python.coverage.reportPaths=coverage.xml
```

## Generate Coverage

```powershell
pytest --cov=src --cov-report=xml:coverage.xml
```

## Run Local SonarQube Analysis

PowerShell:

```powershell
docker run --rm `
  -e SONAR_HOST_URL="http://host.docker.internal:9000" `
  -e SONAR_TOKEN="$env:SONAR_TOKEN" `
  -v "${PWD}:/usr/src" `
  sonarsource/sonar-scanner-cli
```

Review the project dashboard at:

```text
http://localhost:9000
```
