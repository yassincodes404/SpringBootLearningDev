# Deployment Guide

## Environments

| Environment | Branch | Host / URL | Access |
|---|---|---|---|
| Development | `develop` | `http://localhost:5173` | Local Dev Machine |
| Production | `main` | `20.174.9.212` (Azure VM) | Public / GHCR Deployed |

---

## Local Development Workflow

Run the unified dev launcher script which boots PostgreSQL in Docker and starts Spring Boot and Vite natively:

**Windows:**
```cmd
scripts\run_dev.bat
```

**Linux / Mac / Git Bash:**
```bash
make dev
```

To stop all services and free up ports:
```cmd
scripts\stop_dev.bat
```

---

## Production Deployment (Azure Virtual Machine)

Deployment is fully automated via GitHub Actions continuous deployment (`.github/workflows/ci.yml`).

### Infrastructure Overview
- **Hosting**: Azure Virtual Machine (Standard B2als v2 - 2 vCPUs, 4 GiB Memory)
- **Region**: UAE North (`20.174.9.212`)
- **Orchestration**: Docker Compose (`infrastructure/compose/prod.yml`)
- **Registry**: GitHub Container Registry (`ghcr.io`)

### Pipeline Execution Flow

```
1. Push to `main` branch
    │
2. GitHub Actions CI Job (Compiles Java, runs tests, type-checks React)
    │
3. GitHub Actions CD Job
    ├── Builds Backend & Frontend Docker Images
    ├── Tags images with git commit SHA & `latest`
    ├── Pushes images to ghcr.io
    ├── Copies infrastructure/ config to Azure VM via SCP
    └── SSHs into Azure VM & runs `docker compose up -d --remove-orphans`
```

---

## Manual Production Deployment (Fallback)

If you ever need to manually deploy or inspect containers on the Azure VM:

```bash
# 1. SSH into the VM
ssh azureuser@20.174.9.212

# 2. Navigate to application folder
cd ~/app

# 3. Pull latest images and restart stack
docker compose -f infrastructure/compose/prod.yml up -d

# 4. View container status
docker ps
```
