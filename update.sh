#!/usr/bin/env bash
# update.sh - Thin wrapper that downloads and runs update-core.sh
# Usage: curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/update.sh | bash
#   or:  ocaupdate  (after initial install)
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_BASE="https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master"
LOGFILE="$HOME/.oca/update.log"

if ! command -v curl &>/dev/null; then
    echo -e "${RED}[FAIL]${NC} curl not found. Install it with: pkg install curl"
    exit 1
fi

mkdir -p "$HOME/.oca"

TMPFILE=$(mktemp "${PREFIX:-/tmp}/tmp/update-core.XXXXXX.sh" 2>/dev/null) || TMPFILE=$(mktemp /tmp/update-core.XXXXXX.sh)
trap 'rm -f "$TMPFILE"' EXIT

if ! curl -sfL "$REPO_BASE/update-core.sh" -o "$TMPFILE"; then
    echo -e "${RED}[FAIL]${NC} Failed to download update-core.sh"
    exit 1
fi

bash "$TMPFILE" 2>&1 | tee "$LOGFILE"

echo ""
echo -e "${YELLOW}Log saved to $LOGFILE${NC}"
