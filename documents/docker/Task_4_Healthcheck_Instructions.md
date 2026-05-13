# Container Security

## Security changes

1. Added a non-root runtime user:

   ```dockerfile
   RUN addgroup --system appgroup \
       && adduser --system --ingroup appgroup --home /app appuser \
       && chown -R appuser:appgroup /app
   ```

   The `development` and `production` targets now run as `appuser` instead of `root`.

2. Copied runtime files with explicit ownership:

   ```dockerfile
   COPY --from=builder --chown=appuser:appgroup /opt/venv /opt/venv
   COPY --chown=appuser:appgroup app.py .
   ```

   This avoids permission issues after switching to the non-root user.

3. Added `.dockerignore` to exclude local, sensitive, and unnecessary files:

   - `.git`
   - `__pycache__`
   - `.venv`
   - `.env`
   - tests
   - documentation

   This reduces build context size and prevents accidental inclusion of secrets or local-only files.

4. Added a container health check:

   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
       CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).read()" || exit 1
   ```

   The health check monitors the `/health` endpoint without adding extra packages such as `curl`.

## Vulnerability scan

Run one of these after building the production image:

```powershell
docker build --target production -t myapp:prod .
docker scout cves myapp:prod
```

Or:

```powershell
trivy image myapp:prod
```

## Vulnerabilities found

Docker Scout scan command:

```powershell
docker scout cves myapp:prod
```

Scan summary:

| Severity | Count |
| -------- | ----- |
| Critical | 0 |
| High | 2 |
| Medium | 5 |
| Low | 23 |

Image details:

| Field | Value |
| ----- | ----- |
| Image | `myapp:prod` |
| Size | 73 MB |
| Packages | 174 |

Notable findings:

| Package | Version | Severity | CVE | Fixed version |
| ------- | ------- | -------- | --- | ------------- |
| `starlette` | 0.41.3 | High | CVE-2025-62727 | 0.49.1 |
| `starlette` | 0.41.3 | Medium | CVE-2025-54121 | 0.47.2 |
| `wheel` | 0.45.1 | High | CVE-2026-24049 | 0.46.2 |
| `pip` | 24.0 | Medium | CVE-2025-8869 | 25.3 |
| `pip` | 24.0 | Medium | CVE-2026-6357 | 26.1 |
| `pip` | 24.0 | Medium | CVE-2026-3219 | Not fixed |
| `tar` | 1.35+dfsg-3.1 | Medium | CVE-2025-45582 | Not fixed |

Docker Scout also reported 23 low-severity vulnerabilities in Debian packages including `glibc`, `systemd`, `sqlite3`, `coreutils`, `util-linux`, `perl`, `openssl`, `shadow`, and `apt`. Most of those did not have fixed versions listed in the scan output.

## Mitigation strategy

- Keep the base image updated by rebuilding regularly from `python:3.11-slim`.
- Pin and review Python dependencies in `requirements.txt` and `requirements-dev.txt`.
- Upgrade vulnerable Python packages when scan results identify affected versions.
- Keep build tools out of the production runtime with the multi-stage build.
- Run the application as a non-root user to reduce container escape and privilege escalation impact.
- Keep `.env`, local virtual environments, tests, docs, and Git metadata out of the image with `.dockerignore`.
- Upgrade FastAPI to a version that supports `starlette>=0.49.1`, or explicitly pin a compatible patched Starlette release after checking dependency compatibility.
- Upgrade build tooling in the builder stage so the copied virtual environment receives patched `pip` and `wheel` versions when available.
- Monitor Debian base image updates and rebuild when fixed package versions become available for unfixed OS-level CVEs.
