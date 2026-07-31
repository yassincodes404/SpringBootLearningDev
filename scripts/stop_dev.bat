@echo off
:: ==============================================================================
:: stop_dev.bat — Stop all development services
:: ==============================================================================

cd /d "%~dp0\.."

echo [DEV] Stopping Docker services (PostgreSQL + pgAdmin)...
docker compose --env-file .env.local -f infrastructure/compose/dev.yml down

echo [DEV] Stopping any running Spring Boot processes...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":8080" ^| findstr "LISTENING"') do (
    taskkill /PID %%p /F >nul 2>&1
)

echo [DEV] Stopping any running Vite processes...
for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":5173" ^| findstr "LISTENING"') do (
    taskkill /PID %%p /F >nul 2>&1
)

echo.
echo [ OK ] All services stopped.
pause
