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

## Azure VM Deployment

The production deployment workflow in [.github/workflows/cd.yml](../.github/workflows/cd.yml) now builds backend and frontend images, pushes them to GitHub Container Registry, and deploys them to an Azure VM over SSH using Docker Compose.

### Required GitHub Secrets

Configure the following secrets in the GitHub repository:

- `AZURE_VM_HOST`
- `AZURE_VM_PORT`
- `AZURE_VM_USERNAME`
- `AZURE_VM_SSH_PRIVATE_KEY`
- `AZURE_VM_DEPLOY_PATH` (optional; defaults to `/opt/myproject`)
- `PROD_DB_NAME`
- `PROD_DB_USERNAME`
- `PROD_DB_PASSWORD`
- `PROD_JWT_SECRET`

### Deployment Process

1. Push to the `main` branch (or run the workflow manually).
2. GitHub Actions builds the backend and frontend images and publishes them to GHCR.
3. The workflow copies the compose stack and environment file to the Azure VM over SSH.
4. Docker Compose pulls the new images and starts/restarts the production services.
5. The workflow verifies that the backend container becomes healthy.

### Production Environment File

The deployment workflow creates a temporary `.env.production` file on the VM. A sample file is available at [.env.production.example](../.env.production.example).

### Notes

- The deployment target must have Docker and Docker Compose installed.
- The VM should expose port `80` for the nginx reverse proxy.
- The remote directory should be writable by the deployment user.
