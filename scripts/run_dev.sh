#!/usr/bin/env bash
# ==============================================================================
# run_dev.sh — Unified Single-Terminal Dev Environment Launcher (Linux/Mac/Git Bash)
# ==============================================================================
# Runs both Spring Boot & Vite in the SAME terminal window with color-coded logs
# Usage: bash scripts/run_dev.sh
# Stops: Press Ctrl+C in this terminal window
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

step "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps | grep -q "healthy"; then
        ok "PostgreSQL is healthy and accepting connections"
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
# Step 5: Run Backend & Frontend in 1 Single Terminal
# --------------------------------------------------
echo -e "${GREEN}================================================${NC}"
echo -e "  Launching Services (Unified Stream)"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "  Frontend (Vite):    ${CYAN}http://localhost:5173${NC}"
echo -e "  Backend (Spring):   ${CYAN}http://localhost:8080${NC}"
echo -e "  API Health Check:   ${CYAN}http://localhost:8080/actuator/health${NC}"
echo -e "  Swagger Docs:       ${CYAN}http://localhost:8080/swagger-ui.html${NC}"
echo -e "  pgAdmin:            ${CYAN}http://localhost:5050${NC}"
echo -e "  PostgreSQL:         ${CYAN}localhost:5432${NC}"
echo ""
echo -e "  [BACKEND]  Logs will appear in BLUE"
echo -e "  [FRONTEND] Logs will appear in CYAN"
echo ""
echo -e "  ${YELLOW}Press Ctrl+C to stop both services cleanly.${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

npx --yes concurrently --kill-others --prefix "[{name}]" --names "BACKEND,FRONTEND" --prefix-colors "blue.bold,cyan.bold" "cd backend && chmod +x ./mvnw && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev -Dmaven.multiModuleProjectDirectory=." "cd frontend && npm run dev"
