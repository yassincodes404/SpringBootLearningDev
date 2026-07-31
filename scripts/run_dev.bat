@echo off
:: ==============================================================================
:: run_dev.bat — Smart Development Launcher (Windows)
:: ==============================================================================
:: Detects if PostgreSQL, Backend (8080), and Frontend (5173) are running.
:: If running: Reports active state & skips relaunching.
:: If not running: Launches in dedicated, titled log windows!
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

java -version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Java is not installed or not in PATH.
    pause & exit /b 1
)

node --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Node.js is not installed or not in PATH.
    pause & exit /b 1
)
echo [ OK ] Prerequisites verified.

:: --------------------------------------------------
:: Step 2: Ensure .env.local
:: --------------------------------------------------
if not exist ".env.local" (
    echo [WARN] .env.local not found. Creating from .env.example...
    copy .env.example .env.local >nul
    echo [ OK ] Created .env.local
)

:: --------------------------------------------------
:: Step 3: Start Docker Compose (PostgreSQL + pgAdmin)
:: --------------------------------------------------
echo.
echo [DEV] Checking Docker Infrastructure (PostgreSQL + pgAdmin)...
docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d
if errorlevel 1 (
    echo [FAIL] Failed to start Docker Compose services.
    pause & exit /b 1
)

echo [DEV] Waiting for PostgreSQL container health...
set retries=0
:wait_pg
set /a retries+=1
if %retries% gtr 30 (
    echo [FAIL] PostgreSQL container is not healthy.
    pause & exit /b 1
)
timeout /t 1 /nobreak >nul
docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps 2>nul | findstr /i "healthy" >nul
if errorlevel 1 goto wait_pg
echo [ OK ] PostgreSQL database is HEALTHY on port 5432.
echo.

:: --------------------------------------------------
:: Step 4: Install Frontend Dependencies if needed
:: --------------------------------------------------
if not exist "frontend\node_modules" (
    echo [DEV] Installing frontend dependencies...
    cd frontend && call npm install && cd ..
    echo [ OK ] Frontend dependencies installed.
    echo.
)

:: --------------------------------------------------
:: Step 5: Smart Check & Launch Backend (Spring Boot :8080)
:: --------------------------------------------------
echo [DEV] Checking Spring Boot Backend status (Port 8080)...
netstat -o -n -a 2>nul | findstr ":8080" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo [ OK ] Spring Boot Backend is ALREADY RUNNING on port 8080.
) else (
    echo [DEV] Launching Spring Boot Backend in dedicated log window...
    start "SpringBoot Backend (Port 8080)" cmd /k "cd /d %cd%\backend && call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev"
    echo [ OK ] Spring Boot Backend launched in new window.
)

:: --------------------------------------------------
:: Step 6: Smart Check & Launch Frontend (Vite :5173)
:: --------------------------------------------------
echo [DEV] Checking Vite Frontend status (Port 5173)...
netstat -o -n -a 2>nul | findstr ":5173" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo [ OK ] Vite Frontend is ALREADY RUNNING on port 5173.
) else (
    echo [DEV] Launching Vite Frontend in dedicated log window...
    start "Vite Frontend (Port 5173)" cmd /k "cd /d %cd%\frontend && npm run dev"
    echo [ OK ] Vite Frontend launched in new window.
)

:: --------------------------------------------------
:: Summary & Control Guide
:: --------------------------------------------------
echo.
echo ================================================
echo   Development Environment Active!
echo ================================================
echo.
echo   Frontend (Vite UI): http://localhost:5173
echo   Backend API:        http://localhost:8080
echo   Actuator Health:    http://localhost:8080/actuator/health
echo   Swagger / OpenAPI:  http://localhost:8080/swagger-ui.html
echo   pgAdmin:            http://localhost:5050
echo   PostgreSQL DB:      localhost:5432
echo.
echo ================================================
echo   Useful Management Scripts:
echo     - Run scripts\stop_dev.bat to stop all services
echo ================================================
echo.
pause
