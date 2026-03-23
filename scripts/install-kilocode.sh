#!/usr/bin/env bash
# install-kilocode.sh - Install Kilo Code CLI
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Installing Kilo Code CLI ==="
echo ""

if command -v kilo >/dev/null 2>&1; then
    echo -e "${GREEN}[SKIP]${NC} Kilo Code already installed: $(kilo --version 2>/dev/null | head -n 1 || echo installed)"
    exit 0
fi

if npm install -g @kilocode/cli --ignore-scripts --no-audit --no-fund --loglevel=error; then
    echo -e "${GREEN}[OK]${NC}   Kilo Code installed"
else
    echo -e "${YELLOW}[WARN]${NC} Kilo Code installation failed"
fi
