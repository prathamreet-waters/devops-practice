#!/usr/bin/env bash
set -euo pipefail

APP_NAME="devops-app"
IMAGE_TAG="${1:-latest}"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

error() {
  echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
  exit 1
}

usage() {
  echo "Usage: $0 [image_tag]"
  echo "Builds and tests the application container image."
  exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

log "Starting build process for ${APP_NAME}:${IMAGE_TAG}"

if ! command -v docker &> /dev/null; then
  error "Docker CLI is not installed or not in PATH."
fi

log "Building Docker image..."
docker build -t "${APP_NAME}:${IMAGE_TAG}" -t "${APP_NAME}:latest" "${BUILD_DIR}/app"

log "Testing container startup and health check..."
CONTAINER_ID=$(docker run -d -p 8000:8000 "${APP_NAME}:${IMAGE_TAG}")

cleanup() {
  log "Cleaning up test container ${CONTAINER_ID}..."
  docker stop "${CONTAINER_ID}" &>/dev/null || true
  docker rm "${CONTAINER_ID}" &>/dev/null || true
}
trap cleanup EXIT

log "Waiting for container health endpoint..."
MAX_RETRIES=10
RETRY_COUNT=0
HEALTHY=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if curl -sf http://localhost:8000/health > /dev/null; then
    HEALTHY=true
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  sleep 2
done

if [ "$HEALTHY" = true ]; then
  log "Container health check passed successfully!"
else
  error "Container health check failed after ${MAX_RETRIES} attempts."
fi

log "Build complete for ${APP_NAME}:${IMAGE_TAG}"
