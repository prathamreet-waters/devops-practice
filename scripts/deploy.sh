#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
IMAGE_TAG="${2:-latest}"
AWS_REGION="${AWS_REGION:-us-east-1}"

log() {
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

error() {
  echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
  exit 1
}

usage() {
  echo "Usage: $0 [environment] [image_tag]"
  echo "Deploys updated container image to AWS ECS Fargate."
  exit 0
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

CLUSTER_NAME="${ENVIRONMENT}-cluster"
SERVICE_NAME="${ENVIRONMENT}-service"
REPO_NAME="${ENVIRONMENT}-devops-app"

log "Initiating deployment for environment: ${ENVIRONMENT}, image tag: ${IMAGE_TAG}"

if ! command -v aws &> /dev/null; then
  error "AWS CLI is not installed or not in PATH."
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null) || error "Failed to fetch AWS Account ID. Check credentials."
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

log "Authenticating with AWS ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

log "Tagging and pushing image to ECR (${ECR_URL}:${IMAGE_TAG})..."
docker tag "devops-app:${IMAGE_TAG}" "${ECR_URL}:${IMAGE_TAG}"
docker push "${ECR_URL}:${IMAGE_TAG}"

log "Triggering ECS service deployment (${SERVICE_NAME} on ${CLUSTER_NAME})..."
aws ecs update-service \
  --cluster "${CLUSTER_NAME}" \
  --service "${SERVICE_NAME}" \
  --force-new-deployment \
  --region "${AWS_REGION}" > /dev/null

log "Waiting for service deployment stability..."
aws ecs wait services-stable \
  --cluster "${CLUSTER_NAME}" \
  --services "${SERVICE_NAME}" \
  --region "${AWS_REGION}"

log "Deployment completed successfully for ${SERVICE_NAME} in ${ENVIRONMENT}."
