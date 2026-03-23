#!/usr/bin/env bash
# install-mistral-vibe.sh - Install Mistral Vibe CLI
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Installing Mistral Vibe CLI ==="
echo ""

if command -v mistral-vibe >/dev/null 2>&1 || command -v mistralvibe >/dev/null 2>&1; then
    echo -e "${GREEN}[SKIP]${NC} Mistral Vibe already installed"
    exit 0
fi

if python3 -m pip install --user -U mistral-vibe; then
    echo -e "${GREEN}[OK]${NC}   Mistral Vibe installed via pip"
elif python3 -m pip install --user -U mistralvibe; then
    echo -e "${GREEN}[OK]${NC}   Mistral Vibe installed via fallback package name"
else
    echo -e "${YELLOW}[WARN]${NC} Mistral Vibe installation failed"
fi
