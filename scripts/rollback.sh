#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"

log() {
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

error() {
  echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
  exit 1
}

usage() {
  echo "Usage: $0 [environment]"
  echo "Rolls back ECS service to the previous active task definition revision."
  exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

CLUSTER_NAME="${ENVIRONMENT}-cluster"
SERVICE_NAME="${ENVIRONMENT}-service"
TASK_FAMILY="${ENVIRONMENT}-app-task"

log "Initiating rollback for ${SERVICE_NAME} in environment ${ENVIRONMENT}"

CURRENT_TASK_DEF=$(aws ecs describe-services \
  --cluster "${CLUSTER_NAME}" \
  --services "${SERVICE_NAME}" \
  --region "${AWS_REGION}" \
  --query 'services[0].taskDefinition' \
  --output text)

log "Current task definition: ${CURRENT_TASK_DEF}"

CURRENT_REVISION=$(echo "${CURRENT_TASK_DEF}" | awk -F: '{print $NF}')
PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

if [ "${PREVIOUS_REVISION}" -lt 1 ]; then
  error "No previous task definition revision available to roll back to."
fi

TARGET_TASK_DEF="${TASK_FAMILY}:${PREVIOUS_REVISION}"
log "Rolling back service to previous task definition: ${TARGET_TASK_DEF}"

aws ecs update-service \
  --cluster "${CLUSTER_NAME}" \
  --service "${SERVICE_NAME}" \
  --task-definition "${TARGET_TASK_DEF}" \
  --region "${AWS_REGION}" > /dev/null

log "Waiting for service to stabilize on previous revision..."
aws ecs wait services-stable \
  --cluster "${CLUSTER_NAME}" \
  --services "${SERVICE_NAME}" \
  --region "${AWS_REGION}"

log "Rollback completed successfully. Service ${SERVICE_NAME} is running on ${TARGET_TASK_DEF}."
