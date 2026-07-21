#!/usr/bin/env bash
# ==============================================================================
# start-dev.sh — Start the full development environment
# ==============================================================================
set -euo pipefail

echo "🚀 Starting development environment..."

# Start infrastructure services
docker compose -f docker-compose.dev.yml up -d

echo "⏳ Waiting for PostgreSQL to be ready..."
until docker compose -f docker-compose.dev.yml exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done

echo ""
echo "✅ Development environment is running!"
echo ""
echo "   PostgreSQL : localhost:5432"
echo "   Redis      : localhost:6379"
echo "   pgAdmin    : http://localhost:5050"
echo "   MailHog    : http://localhost:8025"
echo ""
echo "   Run the backend:  cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev"
echo "   Run the frontend: cd frontend && npm run dev"
