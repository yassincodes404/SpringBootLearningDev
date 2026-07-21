#!/usr/bin/env bash
# ==============================================================================
# build.sh — Build the backend application
# ==============================================================================
set -euo pipefail

echo "🔨 Building backend..."

cd backend
./mvnw clean package -DskipTests

echo ""
echo "✅ Build complete! JAR located at: backend/target/*.jar"
