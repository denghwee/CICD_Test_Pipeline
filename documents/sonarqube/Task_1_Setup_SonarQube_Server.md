# Task 1: Setup SonarQube Server

## Start SonarQube

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

Login with the default credentials:

```text
Username: admin
Password: admin
```

Change the admin password when prompted.

## Create Project

Create a project manually in the SonarQube UI:

| Field | Value |
| ----- | ----- |
| Project key | `cicd-python-fastapi` |
| Display name | `CICD Python FastAPI` |

Generate a project authentication token.

## Token Handling

Do not commit the token to Git.

Store it locally as an environment variable:

```powershell
$env:SONAR_TOKEN="paste-token-here"
```

For GitHub Actions, add it as a repository secret:

```text
SONAR_TOKEN
```

Also add:

```text
SONAR_HOST_URL=http://localhost:9000
```

For a real shared runner, use a network-accessible SonarQube URL instead of `localhost`.

## Screenshot Required

Capture the SonarQube dashboard after setup and save it as:

```text
screenshots/sonarqube-dashboard.png
```
