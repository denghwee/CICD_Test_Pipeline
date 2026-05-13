# Multi-stage Docker Build

## What changed

The Dockerfile now has separate build and runtime stages:

- `builder`: installs system build tools and production Python dependencies into `/install`
- `dev-builder`: extends `builder` and adds development tools from `requirements-dev.txt`
- `runtime-base`: starts again from `python:3.11-slim` without build tools
- `development`: copies development package artifacts and runs Uvicorn with reload enabled
- `production`: copies only installed production package artifacts and app code

The Dockerfile also keeps a `single-stage` target so the original style can be built for image size comparison.

## Why this improves the image

Build dependencies such as `build-essential` are needed only while compiling or installing packages. In the multi-stage build, those tools stay in the builder image and are not copied into the runtime image.

The runtime stages copy only installed Python package artifacts and `app.py`, so the final production image avoids package manager caches, compiler tools, and temporary build files.

Dependencies are still installed before application code is copied, so changes to `app.py` do not invalidate the dependency installation layers.

## Build commands

```powershell
docker build --target single-stage -t myapp:single .
docker build --target development -t myapp:dev .
docker build --target production -t myapp:prod .
```

## Image size comparison

| Stage | Image Size |
| ----- | ---------- |
| Single-stage | 160 MB |
| Multi-stage production | 160 MB |

Measure the image sizes after building:

```powershell
docker images myapp:single myapp:prod
```

Measured with:

```powershell
docker images myapp
```

Result:

```text
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
myapp        prod      7255f0ff6de2   5 minutes ago    160MB
myapp        single    ee3820c35058   8 minutes ago    160MB
myapp        dev       26d8672c3604   17 minutes ago   216MB
```

The rounded Docker CLI output shows the single-stage and production multi-stage images at the same size. The multi-stage production image is still safer and cleaner because build dependencies such as `build-essential`, compiler packages, temporary build files, and package manager caches remain in the builder stage instead of being copied into the final runtime stage.

Note: The two images are the same rounded size because this application is very small and the original single-stage image was already lightweight. Both images use `python:3.11-slim`, both need the same runtime Python dependencies, and the single-stage image does not install heavy build tools. Multi-stage builds usually reduce image size more clearly when the build stage needs compilers, native package headers, or large temporary build artifacts that are not needed at runtime.
