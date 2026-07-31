#!/usr/bin/env bash
# ==============================================================================
# run_dev.sh — Smart Development Environment Launcher (Linux/Mac/Git Bash)
# ==============================================================================
# Detects if PostgreSQL, Backend (8080), and Frontend (5173) are running.
# If running: Reports active state & skips relaunching.
# If not running: Launches background processes cleanly.
# ==============================================================================

set -euo pipefail

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

step()  { echo -e "${CYAN}[DEV]${NC} $1"; }
ok()    { echo -e "${GREEN} OK ${NC} $1"; }
fail()  { echo -e "${RED}FAIL${NC} $1"; }
info()  { echo -e "${GRAY}      $1${NC}"; }

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "  Spring Boot Dev Environment Launcher"
echo -e "${CYAN}================================================${NC}"
echo ""

# --------------------------------------------------
# Step 1: Check Prerequisites
# --------------------------------------------------
step "Checking prerequisites..."

if ! command -v docker &>/dev/null; then
    fail "Docker is not installed."
    exit 1
fi
ok "Docker: $(docker --version)"

if ! docker info &>/dev/null; then
    fail "Docker daemon is not running."
    exit 1
fi
ok "Docker daemon is running"

if ! command -v java &>/dev/null; then
    fail "Java is not installed."
    exit 1
fi
ok "Java: $(java -version 2>&1 | head -1)"

if ! command -v node &>/dev/null; then
    fail "Node.js is not installed."
    exit 1
fi
ok "Node.js: $(node --version)"

echo ""

# --------------------------------------------------
# Step 2: Check .env.local
# --------------------------------------------------
if [ ! -f ".env.local" ]; then
    step "Creating .env.local from .env.example..."
    cp .env.example .env.local
    ok ".env.local created"
fi

# --------------------------------------------------
# Step 3: Start PostgreSQL + pgAdmin via Docker
# --------------------------------------------------
step "Starting PostgreSQL and pgAdmin via Docker Compose..."

if ! docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d 2>/dev/null; then
    fail "Failed to start Docker Compose services."
    exit 1
fi
ok "Docker Compose services started"

step "Waiting for PostgreSQL container health..."
for i in $(seq 1 30); do
    if docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps | grep -q "healthy"; then
        ok "PostgreSQL database is HEALTHY on port 5432"
        break
    fi
    if [ "$i" -eq 30 ]; then
        fail "PostgreSQL did not become healthy within 30s"
        exit 1
    fi
    sleep 1
done

echo ""

# --------------------------------------------------
# Step 4: Install frontend dependencies if needed
# --------------------------------------------------
if [ ! -d "frontend/node_modules" ]; then
    step "Installing frontend dependencies..."
    (cd frontend && npm install) >/dev/null 2>&1
    ok "Frontend dependencies installed"
    echo ""
fi

# --------------------------------------------------
# Step 5: Check & Launch Backend (Port 8080)
# --------------------------------------------------
step "Checking Spring Boot Backend status (Port 8080)..."
if curl -sf http://localhost:8080/actuator/health >/dev/null 2>&1; then
    ok "Spring Boot Backend is ALREADY RUNNING on port 8080"
else
    step "Launching Spring Boot Backend..."
    (cd backend && chmod +x ./mvnw && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev -Dmaven.multiModuleProjectDirectory=.) &
    ok "Spring Boot Backend process started"
fi

# --------------------------------------------------
# Step 6: Check & Launch Frontend (Port 5173)
# --------------------------------------------------
step "Checking Vite Frontend status (Port 5173)..."
if curl -sf http://localhost:5173 >/dev/null 2>&1; then
    ok "Vite Frontend is ALREADY RUNNING on port 5173"
else
    step "Launching Vite Frontend..."
    (cd frontend && npm run dev) &
    ok "Vite Frontend process started"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "  Development Environment Active!"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "  Frontend (Vite UI): ${CYAN}http://localhost:5173${NC}"
echo -e "  Backend API:        ${CYAN}http://localhost:8080${NC}"
echo -e "  Actuator Health:    ${CYAN}http://localhost:8080/actuator/health${NC}"
echo -e "  Swagger Docs:       ${CYAN}http://localhost:8080/swagger-ui.html${NC}"
echo -e "  pgAdmin:            ${CYAN}http://localhost:5050${NC}"
echo -e "  PostgreSQL DB:      ${CYAN}localhost:5432${NC}"
echo ""
echo -e "  ${YELLOW}Run scripts/stop_dev.sh to stop background processes.${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
