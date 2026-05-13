# Docker Layer Caching Optimization

## Current caching issues

The initial Dockerfile was already close to the preferred cache-friendly layout because it copied `requirements.txt` before `app.py`. That means Docker can reuse the dependency installation layer when only application code changes.

The main remaining improvement was to group related environment settings into one `ENV` instruction, keeping the Dockerfile smaller and reducing unnecessary image metadata instructions.

## Changes made

1. Combined Python environment variables into one `ENV` instruction:

   ```dockerfile
   ENV PYTHONDONTWRITEBYTECODE=1 \
       PYTHONUNBUFFERED=1
   ```

   This keeps related runtime configuration together and avoids extra Dockerfile instructions.

2. Kept dependency files before application code:

   ```dockerfile
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY app.py .
   ```

   `requirements.txt` changes less often than application source code, so dependency installation remains cached during normal code edits.

3. Ordered instructions from least to most frequently changed:

   - Base image
   - Environment variables
   - Working directory
   - Dependency file copy
   - Dependency installation
   - Application code copy
   - Runtime settings

   This improves build time because Docker can reuse earlier layers until it reaches the first changed instruction.

## Why this improves build time

Docker builds images layer by layer. When an instruction and its inputs have not changed, Docker reuses the cached layer instead of running the instruction again.

The dependency installation step is usually slower than copying source code. By copying `requirements.txt` and installing dependencies before copying `app.py`, Docker only reruns `pip install` when dependencies change. Regular application edits only invalidate the later `COPY app.py .` layer, making rebuilds much faster.
