FROM python:3.11-slim AS single-stage

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src ./src

EXPOSE 8000

CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]


FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM builder AS dev-builder

COPY requirements-dev.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements-dev.txt


FROM python:3.11-slim AS runtime-base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_CONFIG_PATH=/config/app.env \
    APP_DATA_DIR=/data

WORKDIR /app

RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup --home /app appuser \
    && mkdir -p /config /data \
    && chown -R appuser:appgroup /app /data

VOLUME ["/data"]

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).read()" || exit 1


FROM runtime-base AS development

COPY --from=dev-builder /install /usr/local
COPY --chown=appuser:appgroup src ./src

USER appuser

CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]


FROM runtime-base AS production

COPY --from=builder /install /usr/local
COPY --chown=appuser:appgroup src ./src

USER appuser

CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
