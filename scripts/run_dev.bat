@echo off
:: ==============================================================================
:: run_dev.bat — Unified Development Environment Launcher (Windows)
:: ==============================================================================
:: Usage: scripts\run_dev.bat
:: Stops: Close this window or press Ctrl+C
:: ==============================================================================

setlocal enabledelayedexpansion
cd /d "%~dp0\.."

echo.
echo ================================================
echo   Spring Boot Dev Environment Launcher
echo ================================================
echo.

:: --------------------------------------------------
:: Step 1: Check Prerequisites
:: --------------------------------------------------
echo [DEV] Checking prerequisites...

:: Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker is not installed or not in PATH.
    echo        Install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)
for /f "delims=" %%v in ('docker --version 2^>nul') do echo [ OK ] Docker: %%v

:: Check Docker daemon
docker info >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker daemon is not running. Please start Docker Desktop.
    pause
    exit /b 1
)
echo [ OK ] Docker daemon is running

:: Check Java
java -version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Java is not installed or not in PATH.
    echo        Install JDK 21: https://adoptium.net/temurin/releases/
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do echo [ OK ] Java: %%v

:: Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Node.js is not installed or not in PATH.
    echo        Install Node.js: https://nodejs.org/
    pause
    exit /b 1
)
for /f "delims=" %%v in ('node --version 2^>nul') do echo [ OK ] Node.js: %%v

echo.

:: --------------------------------------------------
:: Step 2: Check .env.local exists
:: --------------------------------------------------
if not exist ".env.local" (
    echo [FAIL] .env.local not found. Copying from .env.example...
    copy .env.example .env.local >nul
    echo [ OK ] Created .env.local from .env.example
)

:: --------------------------------------------------
:: Step 3: Start PostgreSQL + pgAdmin via Docker
:: --------------------------------------------------
echo [DEV] Starting PostgreSQL and pgAdmin via Docker Compose...
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
if errorlevel 1 (
    echo [FAIL] Failed to start Docker Compose services.
    pause
    exit /b 1
)
echo [ OK ] Docker Compose services started

:: Wait for PostgreSQL health
echo [DEV] Waiting for PostgreSQL to be ready...
set retries=0
:wait_pg
set /a retries+=1
if %retries% gtr 30 (
    echo [FAIL] PostgreSQL did not become healthy within 30s
    echo        Check logs: docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs postgres
    pause
    exit /b 1
)
timeout /t 1 /nobreak >nul
docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps 2>nul | findstr /i "healthy" >nul
if errorlevel 1 goto wait_pg
echo [ OK ] PostgreSQL is healthy and accepting connections
echo.

:: --------------------------------------------------
:: Step 4: Install frontend dependencies if needed
:: --------------------------------------------------
if not exist "frontend\node_modules" (
    echo [DEV] Installing frontend dependencies...
    cd frontend
    call npm install
    cd ..
    echo [ OK ] Frontend dependencies installed
    echo.
)

:: --------------------------------------------------
:: Step 5: Start Backend in background
:: --------------------------------------------------
echo [DEV] Starting Spring Boot backend (dev profile)...
start "SpringBoot-Backend" cmd /c "cd /d %cd%\backend && mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev"

:: Wait for backend readiness
echo [DEV] Waiting for backend to be ready (this may take 30-60s)...
set retries=0
:wait_backend
set /a retries+=1
if %retries% gtr 60 (
    echo [WARN] Backend did not respond within 120s. It may still be starting.
    echo        Check the Spring Boot window for errors.
    goto start_frontend
)
timeout /t 2 /nobreak >nul
curl -sf http://localhost:8080/actuator/health >nul 2>&1
if errorlevel 1 goto wait_backend
echo [ OK ] Spring Boot backend is ready
echo.

:: --------------------------------------------------
:: Step 6: Start Frontend
:: --------------------------------------------------
:start_frontend
echo [DEV] Starting Vite frontend dev server...
start "Vite-Frontend" cmd /c "cd /d %cd%\frontend && npm run dev"

timeout /t 3 /nobreak >nul

:: --------------------------------------------------
:: Summary
:: --------------------------------------------------
echo.
echo ================================================
echo   All Services Running!
echo ================================================
echo.
echo   Frontend (Vite):    http://localhost:5173
echo   Backend (Spring):   http://localhost:8080
echo   API Health Check:   http://localhost:8080/actuator/health
echo   Swagger / OpenAPI:  http://localhost:8080/swagger-ui.html
echo   pgAdmin:            http://localhost:5050
echo   PostgreSQL:         localhost:5432
echo.
echo   Backend and Frontend are running in separate windows.
echo   Close those windows or press Ctrl+C in them to stop.
echo.
echo ================================================
echo   To stop infrastructure (PostgreSQL + pgAdmin):
echo   docker compose --env-file .env.local -f infrastructure/compose/dev.yml down
echo ================================================
echo.
pause
