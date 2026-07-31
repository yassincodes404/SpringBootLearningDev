# Infrastructure Manual

> **Status** ✅ — PostgreSQL 16 Alpine, pgAdmin 4, NGINX reverse proxy, and GitHub Actions CD to Azure VM fully configured.

---

## Quick Reference

| What you want | Command |
|---|---|
| Start dev environment (Unified) | `scripts\run_dev.bat` (Win) or `make dev` (Bash) |
| Stop dev environment | `scripts\stop_dev.bat` (Win) or `make dev-down` |
| Start DB only (Docker) | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d` |
| View DB container logs | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs -f` |
| Connect to DB shell | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml exec postgres psql -U postgres -d myproject` |
| Backup database | `bash scripts/backup-db.sh` |
| Restore database | `bash scripts/restore-db.sh` |

---

## 1. Local Development Setup

### 1.1 Environment Configuration

Copy [.env.example](file:///e:/Projects/SpringBootLearningDev/.env.example) to `.env.local`:

```bash
cp .env.example .env.local
```

`.env.local` contains default local credentials:
```env
DB_NAME=myproject
DB_USERNAME=postgres
DB_PASSWORD=password
```

### 1.2 Starting Dev Environment

Run the unified dev launcher:
- **Windows**: `scripts\run_dev.bat`
- **Linux/Mac**: `make dev`

The script:
1. Verifies Docker, Java 21, and Node.js prerequisites.
2. Boots PostgreSQL 16 and pgAdmin in Docker.
3. Waits for PostgreSQL healthcheck (`pg_isready`).
4. Launches Spring Boot and Vite with color-coded log streams.

---

## 2. Directory Structure & Infrastructure Seeds

```text
infrastructure/
├── README.md           ← Future tools roadmap (Seeds for Redis, MailHog, MinIO, Keycloak, etc.)
├── compose/
│   ├── dev.yml         ← Dev stack: PostgreSQL 16 + pgAdmin 4
│   └── prod.yml        ← Prod stack: NGINX + Backend + Frontend + PostgreSQL
├── nginx/
│   └── nginx.conf      ← Production reverse proxy config
└── postgres/
    └── init.sql        ← Runs once on container init (installs uuid-ossp & pg_trgm)
```

Refer to [infrastructure/README.md](file:///e:/Projects/SpringBootLearningDev/infrastructure/README.md) when you are ready to add new services (e.g. Redis caching, MinIO file uploads, MailHog email testing).

---

## 3. Database Operations

### Backup
```bash
bash scripts/backup-db.sh
# Saved to ./backups/backup_YYYYMMDD_HHMMSS.sql
```

### Restore
```bash
bash scripts/restore-db.sh
# Restores from the most recent SQL file in ./backups/
```

### Complete Database Reset
```bash
docker compose --env-file .env.local -f infrastructure/compose/dev.yml down -v
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
```

---

## 4. Production Stack Reference

Production runs on an Azure Virtual Machine via `infrastructure/compose/prod.yml`:
- **NGINX**: Ports 80 and 443 (routes `/api` to Spring Boot, `/` to React)
- **Backend**: Built from `backend/Dockerfile` (Eclipse Temurin JRE 21 Alpine)
- **Frontend**: Built from `frontend/Dockerfile` (Node 22 build $\rightarrow$ NGINX static serve)
- **PostgreSQL**: PostgreSQL 16 Alpine with persisted volume `postgres-prod-data`
