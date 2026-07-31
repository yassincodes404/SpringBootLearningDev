@echo off
:: ==============================================================================
:: run_dev.bat — Unified Single-Terminal Dev Environment Launcher (Windows)
:: ==============================================================================
:: Runs both Spring Boot & Vite in the SAME terminal window with color-coded logs
:: Usage: scripts\run_dev.bat
:: Stops: Press Ctrl+C in this terminal window
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

docker --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker is not installed or not in PATH.
    pause & exit /b 1
)
for /f "delims=" %%v in ('docker --version 2^>nul') do echo [ OK ] Docker: %%v

docker info >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker daemon is not running. Please start Docker Desktop.
    pause & exit /b 1
)
echo [ OK ] Docker daemon is running

java -version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Java is not installed or not in PATH.
    pause & exit /b 1
)
for /f "tokens=*" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do echo [ OK ] Java: %%v

node --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Node.js is not installed or not in PATH.
    pause & exit /b 1
)
for /f "delims=" %%v in ('node --version 2^>nul') do echo [ OK ] Node.js: %%v

echo.

:: --------------------------------------------------
:: Step 2: Check .env.local
:: --------------------------------------------------
if not exist ".env.local" (
    echo [WARN] .env.local not found. Copying from .env.example...
    copy .env.example .env.local >nul
    echo [ OK ] Created .env.local from .env.example
)

:: --------------------------------------------------
:: Step 3: Start PostgreSQL + pgAdmin
:: --------------------------------------------------
echo [DEV] Starting PostgreSQL and pgAdmin via Docker Compose...
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
if errorlevel 1 (
    echo [FAIL] Failed to start Docker Compose services.
    pause & exit /b 1
)
echo [ OK ] Docker Compose services started

echo [DEV] Waiting for PostgreSQL to be ready...
set retries=0
:wait_pg
set /a retries+=1
if %retries% gtr 30 (
    echo [FAIL] PostgreSQL did not become healthy within 30s
    pause & exit /b 1
)
timeout /t 1 /nobreak >nul
docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps 2>nul | findstr /i "healthy" >nul
if errorlevel 1 goto wait_pg
echo [ OK ] PostgreSQL is healthy
echo.

:: --------------------------------------------------
:: Step 4: Install frontend deps if needed
:: --------------------------------------------------
if not exist "frontend\node_modules" (
    echo [DEV] Installing frontend dependencies...
    cd frontend && call npm install && cd ..
    echo [ OK ] Frontend dependencies installed
    echo.
)

:: --------------------------------------------------
:: Step 5: Run Backend & Frontend in 1 Single Terminal
:: --------------------------------------------------
echo ================================================
echo   Launching Services (Unified Stream)
echo ================================================
echo.
echo   Frontend (Vite):    http://localhost:5173
echo   Backend (Spring):   http://localhost:8080
echo   Health Check:       http://localhost:8080/actuator/health
echo   Swagger Docs:       http://localhost:8080/swagger-ui.html
echo   pgAdmin:            http://localhost:5050
echo   PostgreSQL:         localhost:5432
echo.
echo   [BACKEND]  Logs will appear in BLUE
echo   [FRONTEND] Logs will appear in CYAN
echo.
echo   Press Ctrl+C to stop both services cleanly.
echo ================================================
echo.

call npx --yes concurrently --kill-others --prefix "[{name}]" --names "BACKEND,FRONTEND" --prefix-colors "blue.bold,cyan.bold" "cd backend && call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev -Dmaven.multiModuleProjectDirectory=." "cd frontend && npm run dev"

echo.
echo [DEV] Development session ended.
pause
