#!/usr/bin/env bash
# bootstrap.sh - Download and run OpenClaw on Android installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh -o /tmp/oca-bootstrap.sh \
#     && bash /tmp/oca-bootstrap.sh
set -euo pipefail

REPO_TARBALL="https://github.com/PsProsen-Dev/OpenClaw-On-Android/archive/refs/heads/master.tar.gz"
INSTALL_DIR="$HOME/.oca/installer"

RED='\033[0;31m'
BOLD='\033[1m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_curl_repair_hint() {
    echo -e "${YELLOW}[FIX]${NC} Termux curl/OpenSSL packages look out of sync. Run:"
    echo ""
    echo "  pkg update -y && pkg upgrade -y"
    echo "  pkg install -y curl openssl libngtcp2 ca-certificates"
    echo "  hash -r"
    echo ""
    echo "Then re-run the OCA install command."
}

echo ""
echo -e "${BOLD}OpenClaw on Android - Bootstrap${NC}"
echo ""

if command -v curl &>/dev/null; then
    if ! curl --version &>/dev/null; then
        echo -e "${RED}[FAIL]${NC} curl is installed but cannot start."
        print_curl_repair_hint
        exit 1
    fi
    DOWNLOADER=(curl -sfL "$REPO_TARBALL")
elif command -v wget &>/dev/null; then
    DOWNLOADER=(wget -qO- "$REPO_TARBALL")
else
    echo -e "${RED}[FAIL]${NC} curl/wget not found. Install one with: pkg install curl"
    exit 1
fi

echo "Downloading installer..."
mkdir -p "$INSTALL_DIR"
"${DOWNLOADER[@]}" | tar xz -C "$INSTALL_DIR" --strip-components=1

bash "$INSTALL_DIR/install.sh"

cp "$INSTALL_DIR/uninstall.sh" "$HOME/.oca/uninstall.sh"
chmod +x "$HOME/.oca/uninstall.sh"
rm -rf "$INSTALL_DIR"
