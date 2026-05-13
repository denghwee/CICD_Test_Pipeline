# Volume and Port Configuration

## Volumes

| Purpose | Host / Volume | Container Path | Mode |
| ------- | ------------- | -------------- | ---- |
| Hot reload source code | `.` | `/app` | read-write |
| Persistent application data | `myapp-data` | `/data` | read-write |
| Configuration files | `./config` | `/config` | read-only |

The production/runtime image declares `/data` as a persistent data volume:

```dockerfile
VOLUME ["/data"]
```

Configuration is mounted read-only so local config can be supplied to the container without allowing the application to modify it:

```yaml
- ./config:/config:ro
```

The default config path is exposed with:

```yaml
APP_CONFIG_PATH: /config/app.env
```

## Ports

The application listens on container port `8000`.

For local development, Docker Compose maps host port `8000` to container port `8000`:

```yaml
ports:
  - "8000:8000"
```

After starting the service, the health endpoint is available at:

```text
http://localhost:8000/health
```

## Local development

Start the development container:

```powershell
docker compose up --build
```

The Compose service builds the `development` target, mounts the project directory into `/app` for hot reload, sets environment variables, mounts persistent data at `/data`, mounts config files read-only at `/config`, and defines a health check against `/health`.
