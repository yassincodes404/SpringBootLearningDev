# ==============================================================================
# run_dev.ps1 — Unified Development Environment Launcher (Windows PowerShell)
# ==============================================================================
# Usage: .\scripts\run_dev.ps1
# Stops: Press Ctrl+C (gracefully stops all services)
# ==============================================================================

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

# Colors
function Write-Step($msg)  { Write-Host "[DEV]" -ForegroundColor Cyan -NoNewline; Write-Host " $msg" }
function Write-Ok($msg)    { Write-Host " OK " -ForegroundColor Green -NoNewline; Write-Host " $msg" }
function Write-Fail($msg)  { Write-Host "FAIL" -ForegroundColor Red -NoNewline; Write-Host " $msg" }
function Write-Info($msg)  { Write-Host "    " -NoNewline; Write-Host " $msg" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Spring Boot Dev Environment Launcher" -ForegroundColor White
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# Step 1: Check Prerequisites
# --------------------------------------------------
Write-Step "Checking prerequisites..."

# Check Docker
try {
    $dockerVersion = docker --version 2>&1
    Write-Ok "Docker: $dockerVersion"
} catch {
    Write-Fail "Docker is not installed or not in PATH."
    Write-Info "Install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/"
    exit 1
}

# Check Docker is running
try {
    docker info 2>&1 | Out-Null
    Write-Ok "Docker daemon is running"
} catch {
    Write-Fail "Docker daemon is not running. Please start Docker Desktop."
    exit 1
}

# Check Java
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Ok "Java: $javaVersion"
} catch {
    Write-Fail "Java is not installed or not in PATH."
    Write-Info "Install JDK 21: https://adoptium.net/temurin/releases/"
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version 2>&1
    Write-Ok "Node.js: $nodeVersion"
} catch {
    Write-Fail "Node.js is not installed or not in PATH."
    Write-Info "Install Node.js: https://nodejs.org/"
    exit 1
}

Write-Host ""

# --------------------------------------------------
# Step 2: Start PostgreSQL + pgAdmin via Docker
# --------------------------------------------------
Write-Step "Starting PostgreSQL and pgAdmin via Docker Compose..."

try {
    docker compose --env-file .env.local -f infrastructure/compose/dev.yml up -d 2>&1 | Out-Null
    Write-Ok "Docker Compose services started"
} catch {
    Write-Fail "Failed to start Docker Compose services."
    Write-Info "Make sure .env.local exists (copy from .env.example)"
    exit 1
}

# Wait for PostgreSQL health
Write-Step "Waiting for PostgreSQL to be ready..."
$maxRetries = 30
$retryCount = 0
do {
    Start-Sleep -Seconds 1
    $retryCount++
    $healthy = docker compose --env-file .env.local -f infrastructure/compose/dev.yml ps --format json 2>&1 | 
        ConvertFrom-Json | Where-Object { $_.Service -eq "postgres" -and $_.Health -eq "healthy" }
} while (-not $healthy -and $retryCount -lt $maxRetries)

if ($healthy) {
    Write-Ok "PostgreSQL is healthy and accepting connections"
} else {
    Write-Fail "PostgreSQL did not become healthy within ${maxRetries}s"
    Write-Info "Check logs: docker compose --env-file .env.local -f infrastructure/compose/dev.yml logs postgres"
    exit 1
}

Write-Host ""

# --------------------------------------------------
# Step 3: Install frontend dependencies if needed
# --------------------------------------------------
if (-not (Test-Path "frontend/node_modules")) {
    Write-Step "Installing frontend dependencies..."
    Push-Location frontend
    npm install 2>&1 | Out-Null
    Pop-Location
    Write-Ok "Frontend dependencies installed"
    Write-Host ""
}

# --------------------------------------------------
# Step 4: Start Backend & Frontend
# --------------------------------------------------
Write-Step "Starting Spring Boot backend (dev profile)..."
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:ProjectRoot
    Set-Location backend
    & cmd /c ".\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev 2>&1"
}

# Give backend a moment to start
Start-Sleep -Seconds 5

# Poll for backend readiness
Write-Step "Waiting for backend to be ready..."
$backendReady = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            break
        }
    } catch { }
    Start-Sleep -Seconds 2
}

if ($backendReady) {
    Write-Ok "Spring Boot backend is ready"
} else {
    Write-Fail "Backend did not start within 120s. Check backend logs."
    Write-Info "Run manually: cd backend && .\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev"
}

Write-Host ""
Write-Step "Starting Vite frontend dev server..."
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:ProjectRoot
    Set-Location frontend
    & cmd /c "npm run dev 2>&1"
}

Start-Sleep -Seconds 3

# --------------------------------------------------
# Summary
# --------------------------------------------------
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  All Services Running!" -ForegroundColor White
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend (Vite):    " -NoNewline; Write-Host "http://localhost:5173" -ForegroundColor Cyan
Write-Host "  Backend (Spring):   " -NoNewline; Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "  API Health Check:   " -NoNewline; Write-Host "http://localhost:8080/actuator/health" -ForegroundColor Cyan
Write-Host "  Swagger / OpenAPI:  " -NoNewline; Write-Host "http://localhost:8080/swagger-ui.html" -ForegroundColor Cyan
Write-Host "  pgAdmin:            " -NoNewline; Write-Host "http://localhost:5050" -ForegroundColor Cyan
Write-Host "  PostgreSQL:         " -NoNewline; Write-Host "localhost:5432" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Press Ctrl+C to stop all services" -ForegroundColor Yellow
Write-Host ""

# --------------------------------------------------
# Keep alive & cleanup on Ctrl+C
# --------------------------------------------------
try {
    while ($true) {
        # Check if backend job is still running
        if ($backendJob.State -eq "Completed" -or $backendJob.State -eq "Failed") {
            Write-Fail "Backend process exited unexpectedly."
            Receive-Job $backendJob | Write-Host
            break
        }
        Start-Sleep -Seconds 5
    }
} finally {
    Write-Host ""
    Write-Step "Shutting down all services..."
    
    # Stop background jobs
    Stop-Job $backendJob -ErrorAction SilentlyContinue
    Stop-Job $frontendJob -ErrorAction SilentlyContinue
    Remove-Job $backendJob -Force -ErrorAction SilentlyContinue
    Remove-Job $frontendJob -Force -ErrorAction SilentlyContinue
    
    # Stop Docker services
    docker compose --env-file .env.local -f infrastructure/compose/dev.yml down 2>&1 | Out-Null
    
    Write-Ok "All services stopped. Goodbye!"
}
