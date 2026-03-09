#!/usr/bin/env bash
# uninstall.sh — Clean removal of OCA (OpenClaw on Android)
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_DIR="$HOME/.oca"
BASHRC="$HOME/.bashrc"
BASHRC_MARKER_START="# >>> OCA >>>"
BASHRC_MARKER_END="# <<< OCA <<<"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  OCA — OpenClaw on Android Uninstaller${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

echo -e "${YELLOW}This will remove OCA and all installed components.${NC}"
echo ""
read -rp "Are you sure? [y/N] " reply < /dev/tty
if [[ ! "${reply:-}" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# ── Remove OpenClaw npm package ──
if command -v openclaw &>/dev/null; then
    echo "Removing openclaw npm package..."
    npm uninstall -g openclaw 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   openclaw removed"
fi

# ── Remove clawdhub ──
if command -v clawdhub &>/dev/null; then
    echo "Removing clawdhub..."
    npm uninstall -g clawdhub 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   clawdhub removed"
fi

# ── Remove AI CLI tools (only if installed) ──
command -v claude &>/dev/null && npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
command -v gemini &>/dev/null && npm uninstall -g @google/gemini-cli 2>/dev/null || true
command -v codex &>/dev/null && npm uninstall -g @openai/codex 2>/dev/null || true
command -v qwen-code &>/dev/null && npm uninstall -g @qwen-code/qwen-code 2>/dev/null || true

# ── Remove CLI tools from $PREFIX/bin ──
rm -f "$PREFIX/bin/oca"
rm -f "$PREFIX/bin/ocaupdate"
rm -f "$PREFIX/bin/oca-root"
rm -f "$PREFIX/bin/systemctl"
echo -e "${GREEN}[OK]${NC}   CLI tools removed from \$PREFIX/bin"

# ── Remove Termux:Boot script ──
BOOT_SCRIPT="$HOME/.termux/boot/oca-boot.sh"
if [ -f "$BOOT_SCRIPT" ]; then
    rm -f "$BOOT_SCRIPT"
    echo -e "${GREEN}[OK]${NC}   Boot script removed"
fi
# Also remove legacy boot script name
rm -f "$HOME/.termux/boot/openclaw-boot.sh" 2>/dev/null || true

# ── Remove .bashrc environment block ──
if [ -f "$BASHRC" ]; then
    if grep -qF "$BASHRC_MARKER_START" "$BASHRC"; then
        sed -i "/${BASHRC_MARKER_START//\//\\/}/,/${BASHRC_MARKER_END//\//\\/}/d" "$BASHRC"
        echo -e "${GREEN}[OK]${NC}   .bashrc environment block removed"
    fi
    # Also clean up legacy markers
    sed -i "/# >>> OpenClaw Pocket Server >>>/,/# <<< OpenClaw Pocket Server <<</d" "$BASHRC" 2>/dev/null || true
    sed -i "/# >>> OpenClaw on Android >>>/,/# <<< OpenClaw on Android <<</d" "$BASHRC" 2>/dev/null || true
fi

# ── Remove project directory ──
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo -e "${GREEN}[OK]${NC}   Removed $PROJECT_DIR"
fi

# ── Remove legacy directories ──
rm -rf "$HOME/.openclaw-pocket-server" 2>/dev/null || true
rm -rf "$HOME/.openclaw-android" 2>/dev/null || true

# ── Remove OpenClaw data (ask first) ──
if [ -d "$HOME/.openclaw" ]; then
    echo ""
    read -rp "Also remove OpenClaw data (~/.openclaw)? [y/N] " reply2 < /dev/tty
    if [[ "${reply2:-}" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.openclaw"
        echo -e "${GREEN}[OK]${NC}   Removed ~/.openclaw"
    else
        echo -e "${YELLOW}[KEEP]${NC} ~/.openclaw preserved"
    fi
fi

# ── Remove root marker ──
rm -f "$HOME/.oca/.rooted" 2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}  Uninstall Complete!${NC}"
echo ""
echo "Run 'source ~/.bashrc' to apply changes to the current session."
echo ""
