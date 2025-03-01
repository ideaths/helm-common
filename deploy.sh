#!/bin/bash
# deploy.sh - Enhanced script to deploy a service from any app with environment-specific values

# Command-line arguments
APP_ID=$1          # Application ID (e.g., app-01)
SERVICE=$2         # Service name (e.g., service-01-nginx)
ENVIRONMENT=$3     # Environment (e.g., dev, uat, prod)
NAMESPACE=$4       # Kubernetes namespace (defaults to APP_ID)
RELEASE_NAME=$5    # Helm release name (defaults to SERVICE)

# Display usage if not enough arguments
if [ -z "$APP_ID" ] || [ -z "$SERVICE" ]; then
  echo "Usage: $0 <app-id> <service-name> [environment] [namespace] [release-name]"
  echo "Example: $0 app-01 service-01-nginx prod app01-prod nginx-prod"
  exit 1
fi

# Default values
ENVIRONMENT=${ENVIRONMENT:-dev}
NAMESPACE=${NAMESPACE:-$APP_ID}        # Use APP_ID as default namespace
RELEASE_NAME=${RELEASE_NAME:-$SERVICE} # Use SERVICE as default release name

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if app directory exists
if [ ! -d "$APP_ID" ]; then
  echo -e "${RED}Error: Application directory '$APP_ID' not found${NC}"
  echo "Available applications:"
  ls -d */ | grep -v "common\|scripts" | sed 's/\///'
  exit 1
fi

# Check if service directory exists in the app
if [ ! -d "$APP_ID/$SERVICE" ]; then
  echo -e "${RED}Error: Service directory '$SERVICE' not found in application '$APP_ID'${NC}"
  echo "Available services in $APP_ID:"
  ls -d $APP_ID/*/ | cut -d'/' -f2
  exit 1
fi

# Get the repository root directory
REPO_ROOT=$(pwd)

# Values repository path (assuming one values repo per application)
VALUES_REPO_PATH="../${APP_ID}-values"

# Check if values repository exists
if [ ! -d "$VALUES_REPO_PATH" ]; then
  echo -e "${RED}Error: Values repository not found at $VALUES_REPO_PATH${NC}"
  echo "Please ensure you have cloned the ${APP_ID}-values repository in the parent directory."
  exit 1
fi

# Path to service values files
COMMON_VALUES="${VALUES_REPO_PATH}/_common.yaml"
BASE_VALUES="${VALUES_REPO_PATH}/${SERVICE}/values.yaml"
ENV_VALUES="${VALUES_REPO_PATH}/${SERVICE}/values-${ENVIRONMENT}.yaml"

# Check if required values files exist
if [ ! -f "$BASE_VALUES" ]; then
  echo -e "${RED}Error: Base values file not found at $BASE_VALUES${NC}"
  exit 1
fi

# Build the Helm command with available values files
HELM_VALUES_PARAMS=""

# Common values parameter (if exists)
if [ -f "$COMMON_VALUES" ]; then
  HELM_VALUES_PARAMS+=" -f $COMMON_VALUES"
else
  echo -e "${YELLOW}Warning: Common values file not found at $COMMON_VALUES${NC}"
fi

# Add base values
HELM_VALUES_PARAMS+=" -f $BASE_VALUES"

# Add environment-specific values (if exists)
if [ -f "$ENV_VALUES" ]; then
  HELM_VALUES_PARAMS+=" -f $ENV_VALUES"
else
  echo -e "${YELLOW}Warning: Environment values file not found at $ENV_VALUES${NC}"
  echo "Proceeding with only base values..."
fi

# Files directory (for ConfigMaps, etc.)
FILES_DIR="${VALUES_REPO_PATH}/${SERVICE}/files"
if [ -d "$FILES_DIR" ]; then
  echo -e "${GREEN}Files directory found at $FILES_DIR${NC}"
  # Create files directory if it doesn't exist in the service chart
  mkdir -p "${APP_ID}/${SERVICE}/files"
  # Copy files to the service chart directory
  echo "Copying files from values repository to service chart..."
  cp -r "${FILES_DIR}/"* "${APP_ID}/${SERVICE}/files/"
else
  echo -e "${YELLOW}No files directory found at $FILES_DIR${NC}"
fi

# Print deployment info
echo -e "\n${GREEN}=== Deployment Information ===${NC}"
echo "Application:    $APP_ID"
echo "Service:        $SERVICE"
echo "Environment:    $ENVIRONMENT"
echo "Namespace:      $NAMESPACE"
echo "Release Name:   $RELEASE_NAME"
echo -e "Chart Path:     ${APP_ID}/${SERVICE}\n"

# Preview the values files being used
echo -e "${GREEN}=== Values Files ===${NC}"
[ -f "$COMMON_VALUES" ] && echo "Common:        $COMMON_VALUES"
echo "Base:          $BASE_VALUES"
[ -f "$ENV_VALUES" ] && echo "Environment:   $ENV_VALUES"
echo ""

# Confirm deployment
read -p "Do you want to proceed with the deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Execute Helm deployment
echo -e "\n${GREEN}Executing Helm deployment...${NC}"
helm upgrade --install $RELEASE_NAME "${APP_ID}/${SERVICE}" \
  $HELM_VALUES_PARAMS \
  --namespace $NAMESPACE \
  --create-namespace \
  --atomic \
  --timeout 5m \
  --set valueRepo.environment=$ENVIRONMENT

# Check deployment status
if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✓ Deployment successful!${NC}"
  echo "To check the status of your deployment, run:"
  echo "  kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME"
else
  echo -e "\n${RED}✗ Deployment failed!${NC}"
  echo "Check the error messages above for details."
  exit 1
fi