#!/usr/bin/env bash
# install-opencode.sh - Install OpenCode (AI coding assistant)
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Installing OpenCode CLI ==="

# OpenCode is provided by @mariozechner/pi-coding-agent
# We install it globally via our glibc-node npm
echo "Fetching pi-coding-agent packages..."
npm install -g @mariozechner/pi-coding-agent --ignore-scripts --no-audit --no-fund --loglevel=error

echo -e "${GREEN}[OK]${NC} OpenCode installed."
