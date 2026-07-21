#!/usr/bin/env bash
# ==============================================================================
# restore-db.sh — Restore a PostgreSQL database backup
# ==============================================================================
set -euo pipefail

BACKUP_DIR="./backups"

# Find the latest backup
LATEST_BACKUP=$(ls -t "${BACKUP_DIR}"/backup_*.sql 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No backups found in ${BACKUP_DIR}/"
    exit 1
fi

echo "🔄 Restoring from: $LATEST_BACKUP"

docker compose -f docker-compose.dev.yml exec -T postgres \
    psql -U "${DB_USERNAME:-postgres}" "${DB_NAME:-myproject}" < "$LATEST_BACKUP"

echo "✅ Database restored successfully."
