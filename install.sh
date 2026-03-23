#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"
CLI_MANAGER="$SCRIPT_DIR/scripts/termux_cli_manager.py"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  OCA — OpenClaw on Android v${OCA_VERSION}${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo "This script installs OpenClaw on Termux with platform-aware architecture."
echo ""

step() {
    echo ""
    echo -e "${BOLD}[$1/8] $2${NC}"
    echo "----------------------------------------"
}

step 1 "Environment Check"
if command -v termux-wake-lock &>/dev/null; then
    termux-wake-lock 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC}   Termux wake lock enabled"
fi
bash "$SCRIPT_DIR/scripts/check-env.sh"

step 2 "Platform Selection"
SELECTED_PLATFORM="openclaw"
echo -e "${GREEN}[OK]${NC}   Platform: OpenClaw"
load_platform_config "$SELECTED_PLATFORM" "$SCRIPT_DIR"

step 3 "Tools & Features Selection"
INSTALL_TMUX=false
INSTALL_TTYD=false
INSTALL_DUFS=false
INSTALL_ANDROID_TOOLS=false
INSTALL_CODE_SERVER=false
INSTALL_HOMEBREW=true
INSTALL_GO=true
INSTALL_OPENCODE=false
INSTALL_QWEN_CODE=false
INSTALL_GEMINI_CLI=false
INSTALL_KILO_CODE=false
INSTALL_MISTRAL_VIBE=false
INSTALL_CODEX_CLI=false
INSTALL_GITHUB_COPILOT=false
INSTALL_BOOT=false
INSTALL_TERMUX_API=false

echo ""
echo -e "${CYAN}Select tools and features to install:${NC}"
echo ""

if ask_yn_labeled "Install tmux (terminal multiplexer)?" "optional but highly recommended"; then INSTALL_TMUX=true; fi
if ask_yn_labeled "Install ttyd (web terminal)?" "optional"; then INSTALL_TTYD=true; fi
if ask_yn_labeled "Install dufs (file server)?" "optional"; then INSTALL_DUFS=true; fi
if ask_yn_labeled "Install android-tools (adb)?" "optional but highly recommended"; then INSTALL_ANDROID_TOOLS=true; fi
if ask_yn_labeled "Install code-server (browser IDE)?" "optional"; then INSTALL_CODE_SERVER=true; fi
if ask_yn_labeled "Install Qwen Code CLI?" "recommended first choice on Android"; then INSTALL_QWEN_CODE=true; fi
if ask_yn_labeled "Install Gemini CLI?" "recommended"; then INSTALL_GEMINI_CLI=true; fi
if ask_yn_labeled "Install OpenCode (AI coding assistant)?" "optional"; then INSTALL_OPENCODE=true; fi
if ask_yn_labeled "Install Kilo Code CLI?" "optional"; then INSTALL_KILO_CODE=true; fi
if ask_yn_labeled "Install Mistral Vibe CLI?" "optional"; then INSTALL_MISTRAL_VIBE=true; fi
if ask_yn_labeled "Install Codex CLI?" "optional"; then INSTALL_CODEX_CLI=true; fi
if ask_yn_labeled "Install GitHub Copilot CLI?" "optional"; then INSTALL_GITHUB_COPILOT=true; fi
if ask_yn_labeled "Setup Termux:Boot auto-start?" "optional but highly recommended"; then INSTALL_BOOT=true; fi
if ask_yn_labeled "Install Termux:API tools?" "optional"; then INSTALL_TERMUX_API=true; fi

step 4 "Core Infrastructure (L1)"
bash "$SCRIPT_DIR/scripts/install-infra-deps.sh"
bash "$SCRIPT_DIR/scripts/setup-paths.sh"

echo -e "${CYAN}[INFO]${NC} Homebrew and Go toolchain are installed by default as part of the OCA Linux-like environment."

step 5 "Platform Runtime Dependencies (L2)"
[ "${PLATFORM_NEEDS_GLIBC:-false}" = true ] && bash "$SCRIPT_DIR/scripts/install-glibc.sh" || true
[ "${PLATFORM_NEEDS_NODEJS:-false}" = true ] && bash "$SCRIPT_DIR/scripts/install-nodejs.sh" || true
[ "${PLATFORM_NEEDS_BUILD_TOOLS:-false}" = true ] && bash "$SCRIPT_DIR/scripts/install-build-tools.sh" || true
[ "${PLATFORM_NEEDS_PROOT:-false}" = true ] && pkg install -y proot || true

# Source environment for current session (needed by platform install)
GLIBC_NODE_DIR="$PROJECT_DIR/node"
export PATH="$GLIBC_NODE_DIR/bin:$HOME/.local/bin:$PATH"
export TMPDIR="$PREFIX/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
export OCA_GLIBC=1

step 6 "Platform Package Install (L2)"
bash "$SCRIPT_DIR/platforms/$SELECTED_PLATFORM/install.sh"

echo ""
echo -e "${BOLD}[6.5] Environment Variables + CLI + Marker${NC}"
echo "----------------------------------------"
bash "$SCRIPT_DIR/scripts/setup-env.sh"

PLATFORM_ENV_SCRIPT="$SCRIPT_DIR/platforms/$SELECTED_PLATFORM/env.sh"
if [ -f "$PLATFORM_ENV_SCRIPT" ]; then
    eval "$(bash "$PLATFORM_ENV_SCRIPT")"
fi

mkdir -p "$PROJECT_DIR"
echo "$SELECTED_PLATFORM" > "$PLATFORM_MARKER"

cp "$SCRIPT_DIR/oca.sh" "$PREFIX/bin/oca"
chmod +x "$PREFIX/bin/oca"
cp "$SCRIPT_DIR/update.sh" "$PREFIX/bin/ocaupdate"
chmod +x "$PREFIX/bin/ocaupdate"

cp "$SCRIPT_DIR/uninstall.sh" "$PROJECT_DIR/uninstall.sh"
chmod +x "$PROJECT_DIR/uninstall.sh"

mkdir -p "$PROJECT_DIR/scripts"
mkdir -p "$PROJECT_DIR/platforms"
cp "$SCRIPT_DIR/scripts/lib.sh" "$PROJECT_DIR/scripts/lib.sh"
cp "$SCRIPT_DIR/scripts/setup-env.sh" "$PROJECT_DIR/scripts/setup-env.sh"
cp "$SCRIPT_DIR/scripts/termux_cli_manager.py" "$PROJECT_DIR/scripts/termux_cli_manager.py"
chmod +x "$PROJECT_DIR/scripts/termux_cli_manager.py"
rm -rf "$PROJECT_DIR/platforms/$SELECTED_PLATFORM"
cp -R "$SCRIPT_DIR/platforms/$SELECTED_PLATFORM" "$PROJECT_DIR/platforms/$SELECTED_PLATFORM"

step 7 "Install Optional Tools & Features (L3)"

# ── Termux packages ──
[ "$INSTALL_TMUX" = true ] && pkg install -y tmux || true
[ "$INSTALL_TTYD" = true ] && pkg install -y ttyd || true
[ "$INSTALL_DUFS" = true ] && pkg install -y dufs || true
[ "$INSTALL_ANDROID_TOOLS" = true ] && pkg install -y android-tools || true

# ── code-server ──
[ "$INSTALL_CODE_SERVER" = true ] && mkdir -p "$PROJECT_DIR/patches" && cp "$SCRIPT_DIR/patches/argon2-stub.js" "$PROJECT_DIR/patches/argon2-stub.js" && bash "$SCRIPT_DIR/scripts/install-code-server.sh" install || true

# ── Homebrew (Linuxbrew) ──
[ "$INSTALL_HOMEBREW" = true ] && bash "$SCRIPT_DIR/scripts/install-homebrew.sh" || true

# ── Go toolchain ──
[ "$INSTALL_GO" = true ] && bash "$SCRIPT_DIR/scripts/install-go.sh" || true

# ── OpenCode ──
[ "$INSTALL_OPENCODE" = true ] && bash "$SCRIPT_DIR/scripts/install-opencode.sh" install || true

# ── AI CLI tools ──
# Note: --ignore-scripts ensures we try to skip bad natives, but for those that force it (like tree-sitter-bash), 
# we also pre-install node-gyp-build globally to prevent 'command not found'.
npm install -g node-gyp node-gyp-build --silent || true

if [ "$INSTALL_QWEN_CODE" = true ]; then
    python3 "$CLI_MANAGER" --ensure-rg --install-qwen --patch-qwen || true
fi

if [ "$INSTALL_GEMINI_CLI" = true ]; then
    python3 "$CLI_MANAGER" --ensure-rg --install-gemini --patch-gemini || true
fi

[ "$INSTALL_KILO_CODE" = true ] && bash "$SCRIPT_DIR/scripts/install-kilocode.sh" || true
[ "$INSTALL_MISTRAL_VIBE" = true ] && bash "$SCRIPT_DIR/scripts/install-mistral-vibe.sh" || true
[ "$INSTALL_CODEX_CLI" = true ] && npm install -g @openai/codex --ignore-scripts --no-audit --no-fund --loglevel=error || true
[ "$INSTALL_GITHUB_COPILOT" = true ] && npm install -g @github/copilot --ignore-scripts --no-audit --no-fund --loglevel=error || true

# ── Termux:Boot ──
[ "$INSTALL_BOOT" = true ] && bash "$SCRIPT_DIR/scripts/setup-boot.sh" || true

# ── Termux:API ──
[ "$INSTALL_TERMUX_API" = true ] && bash "$SCRIPT_DIR/scripts/setup-termux-api.sh" || true

# ── Root access setup ──
if detect_root &>/dev/null 2>&1; then
    echo ""
    echo -e "${CYAN}[INFO]${NC} Rooted device detected — setting up root access wrapper"
    bash "$SCRIPT_DIR/scripts/setup-root.sh" || true
fi

step 8 "Verification"
bash "$SCRIPT_DIR/tests/verify-install.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  $PLATFORM_NAME $($PLATFORM_VERSION_CMD 2>/dev/null || echo '')"
echo ""
echo "Next step:"
echo "  $PLATFORM_POST_INSTALL_MSG"
echo ""
