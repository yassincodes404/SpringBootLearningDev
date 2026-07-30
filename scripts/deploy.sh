#!/usr/bin/env bash
# ==============================================================================
# deploy.sh — Manual deployment helper (optional)
# ==============================================================================
# Production deployment is handled automatically by GitHub Actions.
# See: .github/workflows/deploy.yml
#
# This script is for manual deployment only (e.g., debugging, hotfixes).
# It requires Docker and SSH access to the Azure VM.
# ==============================================================================
set -euo pipefail

echo "⚠️  Production deployment is automated via GitHub Actions."
echo "   Push to 'main' → CI passes → deploy.yml triggers automatically."
echo ""
echo "   Workflow:  .github/workflows/deploy.yml"
echo "   Monitor:   https://github.com/<your-repo>/actions"
echo ""
echo "   For manual deployment, SSH into the VM:"
echo "   ssh -i <key.pem> azureuser@<VM_IP>"
echo "   cd ~/app && sudo docker compose -f infrastructure/compose/prod.yml up -d"
