#!/usr/bin/env bash
# ==============================================================================
# backup-db.sh — Backup the PostgreSQL database
# ==============================================================================
set -euo pipefail

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "💾 Backing up database..."

docker compose -f docker-compose.dev.yml exec -T postgres \
    pg_dump -U "${DB_USERNAME:-postgres}" "${DB_NAME:-myproject}" > "$BACKUP_FILE"

echo "✅ Backup saved to: $BACKUP_FILE"
