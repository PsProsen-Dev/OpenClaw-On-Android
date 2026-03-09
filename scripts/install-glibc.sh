#!/usr/bin/env bash
# install-glibc.sh - Install glibc-runner (L2 conditional)
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

OCA_DIR="$HOME/.oca"
GLIBC_LDSO="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
PACMAN_CONF="$PREFIX/etc/pacman.conf"

echo "=== OCA — Installing glibc Runtime ==="
echo ""

# ── Pre-checks ───────────────────────────────

if [ -z "${PREFIX:-}" ]; then
    echo -e "${RED}[FAIL]${NC} Not running in Termux (\$PREFIX not set)"
    exit 1
fi

ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo -e "${RED}[FAIL]${NC} glibc environment requires aarch64 (got: $ARCH)"
    exit 1
fi

# Check if already installed
if [ -f "$OCA_DIR/.glibc-arch" ] && [ -x "$GLIBC_LDSO" ]; then
    echo -e "${GREEN}[SKIP]${NC} glibc-runner already installed"
    exit 0
fi

# ── Step 1: Install pacman ────────────────────

echo "Installing pacman..."
if ! pkg install -y pacman; then
    echo -e "${RED}[FAIL]${NC} Failed to install pacman"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}   pacman installed"

# ── Step 2: Initialize pacman ─────────────────

echo ""
echo "Initializing pacman..."
echo "  (This may take a few minutes for GPG key generation)"

SIGLEVEL_PATCHED=false
if [ -f "$PACMAN_CONF" ]; then
    if ! grep -q "^SigLevel = Never" "$PACMAN_CONF"; then
        cp "$PACMAN_CONF" "${PACMAN_CONF}.bak"
        sed -i 's/^SigLevel\s*=.*/SigLevel = Never/' "$PACMAN_CONF"
        SIGLEVEL_PATCHED=true
        echo -e "${YELLOW}[INFO]${NC} Applied SigLevel = Never workaround (GPGME bug)"
    fi
fi

pacman-key --init 2>/dev/null || true
pacman-key --populate 2>/dev/null || true

# ── Step 3: Install glibc-runner ──────────────

echo ""
echo "Installing glibc-runner..."

if pacman -Sy glibc-runner --noconfirm --assume-installed bash,patchelf,resolv-conf 2>&1; then
    echo -e "${GREEN}[OK]${NC}   glibc-runner installed"
else
    echo -e "${RED}[FAIL]${NC} Failed to install glibc-runner"
    if [ "$SIGLEVEL_PATCHED" = true ] && [ -f "${PACMAN_CONF}.bak" ]; then
        mv "${PACMAN_CONF}.bak" "$PACMAN_CONF"
    fi
    exit 1
fi

# Restore SigLevel
if [ "$SIGLEVEL_PATCHED" = true ] && [ -f "${PACMAN_CONF}.bak" ]; then
    mv "${PACMAN_CONF}.bak" "$PACMAN_CONF"
    echo -e "${GREEN}[OK]${NC}   Restored pacman SigLevel"
fi

# ── Verify ────────────────────────────────────

if [ ! -x "$GLIBC_LDSO" ]; then
    echo -e "${RED}[FAIL]${NC} glibc dynamic linker not found at $GLIBC_LDSO"
    exit 1
fi
echo -e "${GREEN}[OK]${NC}   glibc dynamic linker available"

if command -v grun &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   grun command available"
else
    echo -e "${YELLOW}[WARN]${NC} grun command not found (will use ld.so directly)"
fi

# ── Create marker file ────────────────────────

mkdir -p "$OCA_DIR"
touch "$OCA_DIR/.glibc-arch"
echo -e "${GREEN}[OK]${NC}   glibc architecture marker created"

echo ""
echo -e "${GREEN}glibc runtime installed successfully.${NC}"
echo "  ld.so: $GLIBC_LDSO"
