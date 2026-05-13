# Task 4: Build and Push Docker Image

## Docker build workflow

The workflow is defined in:

```text
.github/workflows/docker-image.yml
```

It runs on every push to the `main`, `master`, or `develop` branch, but only
when source or Docker build files change.

```yaml
on:
  push:
    branches: [master, main, develop]
    paths:
      - "src/**"
      - "Dockerfile"
      - ".dockerignore"
      - "requirements*.txt"
      - "pyproject.toml"
      - ".github/workflows/docker-image.yml"
```

Documentation-only changes are skipped because files under `documents/**` are
not included in the paths filter.

## Image tags

The image is published to GitHub Container Registry:

```text
ghcr.io/<owner>/<repository>
```

The workflow converts the repository path to lowercase before tagging because
container image names must be lowercase.

Each successful build creates a commit SHA tag:

- `${{ github.sha }}`: immutable tag for the exact commit.

Production branch builds also push:

- `latest`: moving tag for the newest image from `main` or `master`.

Example:

```text
ghcr.io/<owner>/<repository>:<commit-sha>
ghcr.io/<owner>/<repository>:latest
```

## Registry authentication

The workflow logs in to GHCR with the built-in GitHub Actions token:

```yaml
permissions:
  contents: read
  packages: write

- name: Log in to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

No custom secret is required for this repository workflow because
`GITHUB_TOKEN` is automatically provided by GitHub Actions. If pushing to a
different organization or registry, create a repository secret such as
`GHCR_TOKEN` or `REGISTRY_TOKEN` and use it as the login password.

## Conditional builds

The `paths` filter prevents Docker image builds when only documentation changes.

Use this pattern when Docker images should only rebuild for changes that affect
the application runtime, dependencies, or Docker build instructions.

## Image scanning

The pipeline scans the image before pushing it:

```yaml
- name: Scan Docker image with Trivy
  uses: aquasecurity/trivy-action@0.24.0
  with:
    image-ref: ${{ steps.image.outputs.image_name }}:${{ github.sha }}
    format: table
    severity: CRITICAL,HIGH
    vuln-type: os,library
    exit-code: "1"
```

The scan fails the workflow when Trivy finds high or critical vulnerabilities.
Because the scan runs before the push steps, vulnerable images are not published
to GHCR.
