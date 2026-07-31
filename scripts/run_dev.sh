#!/usr/bin/env bash
# ==============================================================================
# run_dev.sh — Unified Development Environment Launcher (Linux/Mac/Git Bash)
# ==============================================================================
# Usage: bash scripts/run_dev.sh
# Stops: Press Ctrl+C (gracefully stops all services)
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

# Track PIDs for cleanup
BACKEND_PID=""
FRONTEND_PID=""

cleanup() {
    echo ""
    step "Shutting down all services..."
    
    # Kill backend
    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        kill "$BACKEND_PID" 2>/dev/null || true
        wait "$BACKEND_PID" 2>/dev/null || true
    fi
    
    # Kill frontend
    if [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        kill "$FRONTEND_PID" 2>/dev/null || true
        wait "$FRONTEND_PID" 2>/dev/null || true
    fi
    
    # Stop Docker services
    docker compose --env-file .env.local -f infrastructure/compose/dev.yml down 2>/dev/null || true
    
    ok "All services stopped. Goodbye!"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "  Spring Boot Dev Environment Launcher"
echo -e "${CYAN}================================================${NC}"
echo ""

# --------------------------------------------------
# Step 1: Check Prerequisites
# --------------------------------------------------
step "Checking prerequisites..."

# Check Docker
if ! command -v docker &>/dev/null; then
    fail "Docker is not installed."
    info "Install: https://docs.docker.com/engine/install/"
    exit 1
fi
ok "Docker: $(docker --version)"

# Check Docker is running
if ! docker info &>/dev/null; then
    fail "Docker daemon is not running."
    exit 1
fi
ok "Docker daemon is running"

# Check Java
if ! command -v java &>/dev/null; then
    fail "Java is not installed."
    info "Install JDK 21: https://adoptium.net/temurin/releases/"
    exit 1
fi
ok "Java: $(java -version 2>&1 | head -1)"

# Check Node.js
if ! command -v node &>/dev/null; then
    fail "Node.js is not installed."
    info "Install: https://nodejs.org/"
    exit 1
fi
ok "Node.js: $(node --version)"

echo ""

# --------------------------------------------------
# Step 2: Start PostgreSQL + pgAdmin via Docker
# --------------------------------------------------
step "Starting PostgreSQL and pgAdmin via Docker Compose..."

if ! docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d 2>/dev/null; then
    fail "Failed to start Docker Compose services."
    info "Make sure .env.local exists (copy from .env.example)"
    exit 1
fi
ok "Docker Compose services started"

# Wait for PostgreSQL health
step "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps | grep -q "healthy"; then
        ok "PostgreSQL is healthy and accepting connections"
        break
    fi
    if [ "$i" -eq 30 ]; then
        fail "PostgreSQL did not become healthy within 30s"
        info "Check logs: docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs postgres"
        exit 1
    fi
    sleep 1
done

echo ""

# --------------------------------------------------
# Step 3: Install frontend dependencies if needed
# --------------------------------------------------
if [ ! -d "frontend/node_modules" ]; then
    step "Installing frontend dependencies..."
    (cd frontend && npm install) >/dev/null 2>&1
    ok "Frontend dependencies installed"
    echo ""
fi

# --------------------------------------------------
# Step 4: Start Backend & Frontend
# --------------------------------------------------
step "Starting Spring Boot backend (dev profile)..."
(cd backend && chmod +x ./mvnw && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev) &
BACKEND_PID=$!

# Poll for backend readiness
step "Waiting for backend to be ready..."
for i in $(seq 1 60); do
    if curl -sf http://localhost:8080/actuator/health >/dev/null 2>&1; then
        ok "Spring Boot backend is ready"
        break
    fi
    if [ "$i" -eq 60 ]; then
        fail "Backend did not start within 120s."
        info "Run manually: cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev"
    fi
    sleep 2
done

echo ""
step "Starting Vite frontend dev server..."
(cd frontend && npm run dev) &
FRONTEND_PID=$!

sleep 3

# --------------------------------------------------
# Summary
# --------------------------------------------------
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "  All Services Running!"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "  Frontend (Vite):    ${CYAN}http://localhost:5173${NC}"
echo -e "  Backend (Spring):   ${CYAN}http://localhost:8080${NC}"
echo -e "  API Health Check:   ${CYAN}http://localhost:8080/actuator/health${NC}"
echo -e "  Swagger / OpenAPI:  ${CYAN}http://localhost:8080/swagger-ui.html${NC}"
echo -e "  pgAdmin:            ${CYAN}http://localhost:5050${NC}"
echo -e "  PostgreSQL:         ${CYAN}localhost:5432${NC}"
echo ""
echo -e "  ${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Keep alive
wait
