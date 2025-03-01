#!/bin/bash
# deploy.sh - Script to deploy a service with environment-specific values

# Command-line arguments
SERVICE=$1       # Service name (e.g., service-01-nginx)
ENVIRONMENT=$2   # Environment (e.g., dev, uat, prod)
NAMESPACE=$3     # Kubernetes namespace
RELEASE_NAME=$4  # Helm release name

# Default values
ENVIRONMENT=${ENVIRONMENT:-dev}
NAMESPACE=${NAMESPACE:-default}
RELEASE_NAME=${RELEASE_NAME:-${SERVICE}}

# Application identifier (extracted from current directory)
APP_ID=$(basename $(pwd))

# Values repository path
VALUES_REPO_PATH="../${APP_ID}-values"

# Check if values repository exists
if [ ! -d "$VALUES_REPO_PATH" ]; then
  echo "Error: Values repository not found at $VALUES_REPO_PATH"
  exit 1
fi

# Path to service values files
COMMON_VALUES="${VALUES_REPO_PATH}/_common.yaml"
BASE_VALUES="${VALUES_REPO_PATH}/${SERVICE}/values.yaml"
ENV_VALUES="${VALUES_REPO_PATH}/${SERVICE}/values-${ENVIRONMENT}.yaml"

# Check if required values files exist
if [ ! -f "$BASE_VALUES" ]; then
  echo "Error: Base values file not found at $BASE_VALUES"
  exit 1
fi

if [ ! -f "$ENV_VALUES" ]; then
  echo "Warning: Environment values file not found at $ENV_VALUES"
  echo "Proceeding with only base values..."
  ENV_VALUES_PARAM=""
else
  ENV_VALUES_PARAM="-f $ENV_VALUES"
fi

# Common values parameter (if exists)
if [ -f "$COMMON_VALUES" ]; then
  COMMON_VALUES_PARAM="-f $COMMON_VALUES"
else
  COMMON_VALUES_PARAM=""
fi

# Files directory (for ConfigMaps, etc.)
FILES_DIR="${VALUES_REPO_PATH}/${SERVICE}/files"
if [ -d "$FILES_DIR" ]; then
  echo "Files directory found at $FILES_DIR"
  # Copy files to the service chart directory if needed
  cp -r "$FILES_DIR" "./${SERVICE}/"
fi

# Print deployment info
echo "Deploying $SERVICE to $ENVIRONMENT environment"
echo "Application: $APP_ID"
echo "Release Name: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"

# Execute Helm deployment
helm upgrade --install $RELEASE_NAME "./${SERVICE}" \
  $COMMON_VALUES_PARAM \
  -f $BASE_VALUES \
  $ENV_VALUES_PARAM \
  --namespace $NAMESPACE \
  --create-namespace \
  --atomic \
  --timeout 5m \
  --set valueRepo.environment=$ENVIRONMENT

# Check deployment status
if [ $? -eq 0 ]; then
  echo "Deployment successful!"
else
  echo "Deployment failed!"
  exit 1
fi