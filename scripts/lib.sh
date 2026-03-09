#!/usr/bin/env bash
# lib.sh — Shared function library for OCA (OpenClaw on Android)
# Usage: source "$SCRIPT_DIR/scripts/lib.sh"  (from repo)
#        source "$PROJECT_DIR/scripts/lib.sh"  (from installed copy)

# ── Color constants ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Project constants ──
PROJECT_DIR="$HOME/.oca"
PLATFORM_MARKER="$PROJECT_DIR/.platform"
REPO_BASE="https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master"

BASHRC_MARKER_START="# >>> OCA >>>"
BASHRC_MARKER_END="# <<< OCA <<<"
OCA_VERSION="09.03.2026"

# ── Platform detection ──
detect_platform() {
    if [ -f "$PLATFORM_MARKER" ]; then
        cat "$PLATFORM_MARKER"
        return 0
    fi
    if command -v openclaw &>/dev/null; then
        echo "openclaw"
        mkdir -p "$(dirname "$PLATFORM_MARKER")"
        echo "openclaw" > "$PLATFORM_MARKER"
        return 0
    fi
    echo ""
    return 1
}

# ── Platform name validation ──
validate_platform_name() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}[FAIL]${NC} Platform name is empty"
        return 1
    fi
    if [[ ! "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        echo -e "${RED}[FAIL]${NC} Invalid platform name: $name"
        return 1
    fi
    return 0
}

# ── User confirmation prompt (basic) ──
ask_yn() {
    local prompt="$1"
    local reply
    read -rp "$prompt [Y/n] " reply < /dev/tty
    [[ "${reply:-}" =~ ^[Nn]$ ]] && return 1
    return 0
}

# ── User confirmation prompt (labeled) ──
# Usage: ask_yn_labeled "Install tmux?" "optional but highly recommended"
ask_yn_labeled() {
    local prompt="$1"
    local label="${2:-optional}"
    local reply
    read -rp "$prompt (${label}) [Y/n] " reply < /dev/tty
    [[ "${reply:-}" =~ ^[Nn]$ ]] && return 1
    return 0
}

# ── Root detection ──
detect_root() {
    if su -c "id" &>/dev/null 2>&1; then
        echo "rooted"
        return 0
    fi
    echo "not-rooted"
    return 1
}

# ── Load platform config.env ──
load_platform_config() {
    local platform="$1"
    local base_dir="$2"
    local config_path="$base_dir/platforms/$platform/config.env"

    validate_platform_name "$platform" || return 1

    if [ ! -f "$config_path" ]; then
        echo -e "${RED}[FAIL]${NC} Platform config not found: $config_path"
        return 1
    fi
    source "$config_path"
    return 0
}
