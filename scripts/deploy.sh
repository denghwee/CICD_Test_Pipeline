#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:?environment is required}"
IMAGE="${2:?image is required}"
PORT="${3:-8000}"
CONTAINER_NAME="cicd-${ENVIRONMENT}"
HEALTH_URL="http://127.0.0.1:${PORT}/health"

echo "Starting deployment"
echo "Environment: ${ENVIRONMENT}"
echo "Image: ${IMAGE}"
echo "Health URL: ${HEALTH_URL}"

docker pull "${IMAGE}"

if docker ps -a --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
  echo "Removing existing container: ${CONTAINER_NAME}"
  docker rm -f "${CONTAINER_NAME}"
fi

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${PORT}:8000" \
  "${IMAGE}"

echo "Waiting for health check"
for attempt in {1..30}; do
  if curl --fail --silent --show-error "${HEALTH_URL}" >/tmp/deploy-health.json; then
    echo "Deployment succeeded"
    echo "Health response:"
    cat /tmp/deploy-health.json
    exit 0
  fi

  echo "Health check attempt ${attempt}/30 failed; retrying"
  sleep 2
done

echo "Deployment failed: health check did not pass"
docker logs "${CONTAINER_NAME}" || true
exit 1
