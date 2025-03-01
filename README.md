# Kubernetes Helm Chart Collection with Common Templates

This repository contains a collection of Kubernetes Helm charts that use a common template library for deploying applications consistently across environments. The repository is structured by applications, with each application containing multiple services.

## Repository Structure

```
helm-charts/
├── deploy.sh                      # Main deployment script
│
├── common/                        # Common template library chart
│   ├── templates/                 # Reusable templates
│   │   ├── _helpers.tpl           # Helper functions
│   │   ├── configmap.tpl          # ConfigMap template
│   │   ├── deployment.tpl         # Deployment template
│   │   ├── hpa.tpl                # HorizontalPodAutoscaler template
│   │   ├── ingress.tpl            # Ingress template
│   │   ├── networkPolicy.tpl      # NetworkPolicy template
│   │   ├── pdb.tpl                # PodDisruptionBudget template
│   │   ├── pv.tpl                 # PersistentVolume template
│   │   ├── pvc.tpl                # PersistentVolumeClaim template
│   │   ├── role.tpl               # Role template
│   │   ├── rolebinding.tpl        # RoleBinding template
│   │   ├── secret.tpl             # Secret template
│   │   ├── service.tpl            # Service template
│   │   ├── serviceaccount.tpl     # ServiceAccount template
│   │   ├── istio/                 # Istio-specific templates
│   │   │   ├── authorizationPolicy.tpl
│   │   │   ├── destinationRule.tpl
│   │   │   ├── gateway.tpl
│   │   │   ├── peerAuthentication.tpl
│   │   │   └── virtualService.tpl
│   ├── Chart.yaml                 # Chart metadata
│   └── values.yaml                # Default values (for reference)
│
├── app-01/                        # First application directory
│   ├── service-01-nginx/          # Nginx service chart
│   │   ├── templates/             # Service-specific templates
│   │   │   ├── configmap.yaml     # Includes common.configmap.tpl
│   │   │   ├── deployment.yaml    # Includes common.deployment.tpl
│   │   │   ├── hpa.yaml           # Includes common.hpa.tpl
│   │   │   ├── ingress.yaml       # Includes common.ingress.tpl
│   │   │   ├── networkpolicy.yaml # Includes common.networkPolicy.tpl
│   │   │   ├── pdb.yaml           # Includes common.pdb.tpl
│   │   │   └── service.yaml       # Includes common.service.tpl
│   │   ├── Chart.yaml             # Chart metadata with common dependency
│   │   └── values.yaml            # Minimal values with reference to values repository
│   │
│   └── service-02-api/            # API service chart
│       ├── templates/             # Service-specific templates
│       ├── Chart.yaml             # Chart metadata
│       └── values.yaml            # Minimal values file
│
└── app-02/                        # Second application directory
    ├── service-01-frontend/       # Frontend service chart
    │   ├── templates/             # Service-specific templates
    │   ├── Chart.yaml             # Chart metadata
    │   └── values.yaml            # Minimal values file
    │
    └── service-02-backend/        # Backend service chart
        ├── templates/             # Service-specific templates
        ├── Chart.yaml             # Chart metadata
        └── values.yaml            # Minimal values file
```

## Values Repository Structure

Each application has its own values repository, named after the application (e.g., `app-01-values`). The values repositories should be cloned alongside this repository:

```
parent-directory/
├── helm-charts/                   # This repository
└── app-01-values/                 # Values for app-01
    ├── _common.yaml               # Common values for all services in app-01
    │
    ├── service-01-nginx/
    │   ├── values.yaml            # Base configuration for nginx service
    │   ├── values-dev.yaml        # Development environment overrides
    │   ├── values-uat.yaml        # UAT environment overrides
    │   ├── values-prod.yaml       # Production environment overrides
    │   └── files/                 # Service-specific files directory
    │       ├── nginx.conf         # Nginx configuration
    │       └── index.html         # HTML template
    │
    └── service-02-api/            # Another service's values
        ├── values.yaml
        ├── values-dev.yaml
        ├── values-uat.yaml
        ├── values-prod.yaml
        └── files/
```

## Features

- **Multi-Application Support**: Organize multiple applications within a single repository
- **Reusable Templates**: Standardized templates for all Kubernetes resources
- **Environment-Specific Configuration**: Separate values files for different environments
- **Common Library Approach**: Single source of truth for resource definitions
- **Istio Integration**: Built-in support for Istio service mesh resources
- **OpenShift Support**: Templates for OpenShift-specific resources like Routes

## Getting Started

### Prerequisites

- Kubernetes cluster 1.19+
- Helm 3.8+
- Access to your application's values repository

### Repository Setup

1. Clone both the chart repository and your application's values repository:

```bash
# Create a parent directory for related repositories
mkdir my-k8s-apps && cd my-k8s-apps

# Clone chart repository
git clone https://github.com/example/helm-charts.git
cd helm-charts

# Clone application values repositories in the parent directory
git clone https://github.com/example/app-01-values.git ../app-01-values
git clone https://github.com/example/app-02-values.git ../app-02-values
```

### Deploying a Service

The easiest way to deploy a service is using the provided `deploy.sh` script:

```bash
# Basic usage
./deploy.sh <app-id> <service-name> [environment] [namespace] [release-name]
```

By default:
- `namespace` defaults to the app-id
- `release-name` defaults to the service name
- `environment` defaults to "dev" if not specified

#### Examples:

```bash
# Deploy nginx from app-01 to production
# Will deploy to namespace "app-01" with release name "service-01-nginx"
./deploy.sh app-01 service-01-nginx prod

# Deploy with custom namespace but default release name
./deploy.sh app-01 service-01-nginx uat custom-namespace

# Deploy with custom namespace and release name
./deploy.sh app-02 service-01-frontend prod frontend-ns frontend-prod
```

#### Manual Deployment:

You can also deploy manually using Helm:

```bash
# Deploy manually by referencing values files
helm upgrade --install service-01-nginx ./app-01/service-01-nginx \
  -f ../app-01-values/_common.yaml \
  -f ../app-01-values/service-01-nginx/values.yaml \
  -f ../app-01-values/service-01-nginx/values-uat.yaml \
  --namespace app-01 \
  --create-namespace
```

## Configuration

Each service's values.yaml file contains minimal information and references the application's values repository:

```yaml
# Reference configuration
valueRepo:
  # Application values repository
  name: "app-01-values" 
  # Current service identifier
  service: "service-01-nginx"

# Default environment to use if not specified
defaultEnv: "dev"

# Minimal configuration for local development/testing
replicaCount: 1
image:
  repository: nginx
  tag: "1.21.6"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
```

The actual configuration is loaded from the values repository, with environment-specific overrides.

## Environment-Specific Configuration

The values repository contains files for different environments:

1. **_common.yaml**: Common values for all services in the app
2. **service-01-nginx/values.yaml**: Base values for the nginx service
3. **service-01-nginx/values-{env}.yaml**: Environment-specific overrides

This allows for a layered approach to configuration:
- Common settings shared across services
- Service-specific base configuration
- Environment-specific overrides

## Common Templates Usage

Each template in the common chart can be included in your service's templates. For example:

```yaml
{{- include "common.deployment.tpl" . }}
```

This creates a Deployment resource based on the values provided in your values files.

## Additional Resources

The `files` directory in the values repository can contain service-specific files like configuration files, HTML templates, etc. These will be automatically copied to the service chart directory when deploying using `deploy.sh`.

## Customizing Templates

If a service needs to customize a common template, it can:
1. Include the common template and add additional resources
2. Create a custom template that extends the common one
3. Override specific values in the values files

## GitHub Actions Integration

For CI/CD integration with GitHub Actions, you can use:

1. **Composite Actions** - Create reusable deployment actions
2. **Reusable Workflows** - Define standard deployment workflows
3. **Organizational Actions** - Share actions across multiple repositories

## Troubleshooting

### Common Issues

- **Template Not Found**: Ensure the common chart is correctly referenced as a dependency
- **Values Not Applied**: Check the order of values files (environment-specific should be last)
- **Resource Not Created**: Verify that the feature is enabled in values (e.g., `ingress.enabled: true`)

### Debugging

To see the rendered templates without deploying:

```bash
helm template service-01-nginx ./app-01/service-01-nginx \
  -f ../app-01-values/_common.yaml \
  -f ../app-01-values/service-01-nginx/values.yaml \
  -f ../app-01-values/service-01-nginx/values-uat.yaml
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

When modifying common templates, ensure they remain backward compatible or document breaking changes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.