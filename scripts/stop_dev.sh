#!/usr/bin/env bash
# ==============================================================================
# stop_dev.sh — Stop all development services (Linux/Mac/Git Bash)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "[DEV] Stopping Docker services (PostgreSQL + pgAdmin)..."
docker compose --env-file .env.local -f infrastructure/compose/dev.yml down

echo "[DEV] Stopping any processes on port 8080 and 5173..."
fuser -k 8080/tcp >/dev/null 2>&1 || true
fuser -k 5173/tcp >/dev/null 2>&1 || true

echo "[ OK ] All development services stopped."
