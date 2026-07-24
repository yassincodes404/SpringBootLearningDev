#!/usr/bin/env bash
# ==============================================================================
# start-dev.sh — Start the development environment (Phase 1: Database)
# ==============================================================================
set -euo pipefail

echo "🚀 Starting development environment..."

docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d

echo "⏳ Waiting for PostgreSQL to be ready..."
until docker compose --env-file .env.local -f infrastructure/compose/dev.yml \
    exec -T postgres pg_isready -U "${DB_USERNAME:-postgres}" > /dev/null 2>&1; do
    sleep 1
done

echo ""
echo "✅ Development environment is running!"
echo ""
echo "   PostgreSQL : localhost:5432"
echo "   pgAdmin    : http://localhost:5050"
echo ""
echo "   Run the backend:  cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev"
echo "   Run the frontend: cd frontend && npm run dev"
