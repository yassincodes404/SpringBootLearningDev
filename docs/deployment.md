# Deployment Guide

## Environments

| Environment | Branch   | URL                        |
|-------------|----------|----------------------------|
| Development | develop  | http://localhost:8080       |
| Staging     | release/*| TBD                        |
| Production  | main     | TBD                        |

## Local Development

```bash
# 1. Start infrastructure
make dev-up

# 2. Run backend
make run

# 3. Run frontend
make frontend-dev
```

## Docker (Production-like)

```bash
# Build and start everything
make prod-up

# Stop
make prod-down
```

## Azure Deployment

> Coming soon — will be configured with GitHub Actions CD pipeline.

### Prerequisites
- Azure CLI installed
- Azure Container Registry (ACR) configured
- Azure App Service or AKS provisioned

### Pipeline
1. Push to `main` branch
2. GitHub Actions builds Docker image
3. Image pushed to Azure Container Registry
4. Azure App Service pulls and deploys the new image
5. Health check verifies deployment
