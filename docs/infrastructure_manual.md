# Infrastructure Manual

> **Tested** ✅ — PostgreSQL 16.14, pgAdmin, uuid-ossp + pg_trgm extensions confirmed working.

---

## Quick Reference

| What you want | Command |
|---|---|
| Start dev environment | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d` |
| Stop dev environment | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml down` |
| View logs | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs -f` |
| Check what's running | `docker ps` |
| Connect to DB shell | `docker compose --env-file .env.local -f infrastructure/compose/dev.yml exec postgres psql -U postgres -d myproject` |
| Backup database | `bash scripts/backup-db.sh` |
| Restore database | `bash scripts/restore-db.sh` |

> **Windows note**: `make` is not available in PowerShell by default.
> All `make` targets map directly to the raw `docker compose` commands above.
> To install `make` on Windows: `winget install GnuWin32.Make` or use Git Bash.

---

## 1. First-Time Setup

### 1.1 Create your local env file

```bash
# Copy the example — do this once
cp .env.example .env.local
```

> [!IMPORTANT]
> `.env.local` is gitignored and never committed. It holds your personal dev secrets.
> `.env.example` is committed and serves as the canonical template.

### 1.2 Review `.env.local`

Open [.env.local](file:///e:/Projects/SpringBootLearningDev/.env.local) and check the values.
The defaults work out of the box for local development — no changes needed to start.

```env
DB_NAME=myproject
DB_USERNAME=postgres
DB_PASSWORD=password     ← fine locally, never use this in production
```

### 1.3 Start the environment

```bash
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
```

Expected output (all green):
```
✔ Network compose_default    Created
✔ Volume compose_postgres-data   Created
✔ Volume compose_pgadmin-data    Created
✔ Container myproject-postgres   Started
✔ Container myproject-pgadmin    Started
```

### 1.4 Verify it's running

```bash
docker ps
```

You should see **exactly two containers**:

```
NAMES                STATUS                    PORTS
myproject-pgadmin    Up N seconds              0.0.0.0:5050->80/tcp
myproject-postgres   Up N seconds (healthy)    0.0.0.0:5432->5432/tcp
```

> [!NOTE]
> `(healthy)` means the healthcheck passed — PostgreSQL accepted the `pg_isready` probe.
> pgAdmin will say `Up` without a health badge, which is normal.

---

## 2. Daily Workflow

### Start your day

```bash
# 1. Start infrastructure
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d

# 2. Run the backend (in a separate terminal)
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 3. Run the frontend (in another terminal)
cd frontend && npm run dev
```

### End your day

```bash
# Stop infrastructure (data is preserved in named volumes)
docker compose --env-file .env.local -f infrastructure/compose/dev.yml down
```

### Check logs while working

```bash
# All services
docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs -f

# One service only
docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs -f postgres
docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs -f pgadmin
```

---

## 3. Service Reference

### PostgreSQL

| Property | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `myproject` |
| Username | `postgres` |
| Password | `password` |
| JDBC URL | `jdbc:postgresql://localhost:5432/myproject` |

**Connect via psql:**
```bash
docker compose --env-file .env.local \
  -f infrastructure/compose/dev.yml \
  exec postgres psql -U postgres -d myproject
```

**Pre-installed extensions** (from [init.sql](file:///e:/Projects/SpringBootLearningDev/infrastructure/postgres/init.sql)):
- `uuid-ossp` — generate UUIDs with `uuid_generate_v4()`
- `pg_trgm` — fuzzy text search with trigrams

### pgAdmin

| Property | Value |
|---|---|
| URL | http://localhost:5050 |
| Email | `admin@admin.com` |
| Password | `admin` |

**First-time pgAdmin setup** (one-time, saved in the volume):
1. Open http://localhost:5050
2. Click **Add New Server**
3. Name: `myproject-local`
4. Connection tab → Host: `postgres` *(container name, not localhost)*
5. Port: `5432`, Username: `postgres`, Password: `password`
6. Save

> [!NOTE]
> The host must be `postgres` (the Docker container name) — not `localhost`.
> pgAdmin runs inside Docker and resolves service names via the Docker network.

---

## 4. File Structure

```text
infrastructure/
├── compose/
│   ├── database.yml    ← Phase 1: PostgreSQL + pgAdmin
│   ├── dev.yml         ← Dev entry point (includes layers)
│   └── prod.yml        ← Production: NGINX + backend + frontend + DB
│
├── nginx/
│   └── nginx.conf      ← Reverse proxy config (used in prod only)
│
└── postgres/
    └── init.sql        ← Runs once on first container creation
```

```text
scripts/
├── start-dev.sh        ← Wraps the docker compose up command
├── stop-dev.sh         ← Wraps the docker compose down command
├── backup-db.sh        ← pg_dump to ./backups/
└── restore-db.sh       ← psql restore from latest backup
```

```text
.env.example            ← Committed template (no secrets)
.env.local              ← Your dev secrets (gitignored)
.env.production         ← Prod secrets (gitignored, you create this)
```

---

## 5. How the Layer System Works

[`dev.yml`](file:///e:/Projects/SpringBootLearningDev/infrastructure/compose/dev.yml) uses Docker Compose `include` to assemble layers:

```yaml
# dev.yml — Phase 1
include:
  - database.yml

  # Phase 2 — uncomment when adding Redis:
  # - cache.yml
```

When you run `docker compose ... -f dev.yml up`, Docker reads `dev.yml`, then reads each included file, and merges them into a single virtual compose configuration.

**What this means in practice:**

| Phase | What you do | What runs |
|---|---|---|
| Now (Phase 1) | Nothing — it's the default | PostgreSQL + pgAdmin |
| Phase 2 | Uncomment `- cache.yml` in `dev.yml` | + Redis + RedisInsight |
| Phase 3 | Uncomment `- storage.yml` | + MinIO |
| Phase 4 | Uncomment `- messaging.yml` | + RabbitMQ |

---

## 6. Database Operations

### Backup

Backups are saved to `./backups/` with a timestamp:

```bash
bash scripts/backup-db.sh
# ✅ Backup saved to: ./backups/backup_20260724_165900.sql
```

### Restore

Restores from the **most recent** backup automatically:

```bash
bash scripts/restore-db.sh
# 🔄 Restoring from: ./backups/backup_20260724_165900.sql
# ✅ Database restored successfully.
```

### Reset the database completely

> [!WARNING]
> This deletes all data permanently. Use only in development.

```bash
# Stop containers and remove volumes
docker compose --env-file .env.local -f infrastructure/compose/dev.yml down -v

# Start fresh — init.sql will run again
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
```

---

## 7. Production (Reference)

Production requires `.env.production` to exist at the project root (never committed):

```bash
cp .env.example .env.production
# Edit .env.production with real secrets
```

```bash
# Start production stack
docker compose --env-file .env.production -f infrastructure/compose/prod.yml up -d --build

# Stop
docker compose --env-file .env.production -f infrastructure/compose/prod.yml down
```

The production stack additionally runs:
- **NGINX** on ports 80 and 443 (reverse proxy)
- **Spring Boot** built from `backend/Dockerfile`
- **React** built from `frontend/Dockerfile`

---

## 8. Troubleshooting

### Container won't start

```bash
# Check logs for the failing container
docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs postgres
```

### Port already in use

```bash
# Find what's using port 5432
netstat -ano | findstr :5432

# Or change the port in .env.local
DB_PORT=5433
```

### pgAdmin forgets the server connection

The pgAdmin data volume may have been deleted. Re-add the server following the [First-time pgAdmin setup](#pgadmin) steps above.

### `env file not found` error

```
couldn't find env file: .env.local
```

You haven't created `.env.local` yet:
```bash
cp .env.example .env.local
```

### Data disappeared after `docker compose down`

Normal `down` preserves data. Data is only deleted when you add the `-v` flag (`down -v`).
Check that you didn't accidentally run `down -v`.

### Check what volumes exist

```bash
docker volume ls | findstr myproject
# or on bash:
docker volume ls | grep myproject
```
