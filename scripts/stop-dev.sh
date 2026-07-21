#!/usr/bin/env bash
# ==============================================================================
# stop-dev.sh — Stop the development environment
# ==============================================================================
set -euo pipefail

echo "🛑 Stopping development environment..."

docker compose -f docker-compose.dev.yml down

echo "✅ Development environment stopped."
