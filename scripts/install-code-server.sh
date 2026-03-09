#!/usr/bin/env bash
# install-code-server.sh - Install code-server (glibc arm64)
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

OCA_DIR="$HOME/.oca"
INSTALL_DIR="$OCA_DIR/code-server"
VERSION="4.96.1"
TARBALL="code-server-${VERSION}-linux-arm64.tar.gz"
URL="https://github.com/coder/code-server/releases/download/v${VERSION}/${TARBALL}"

echo "=== Installing code-server (glibc) ==="

if [ -f "$INSTALL_DIR/bin/code-server" ]; then
    echo -e "${GREEN}[SKIP]${NC} code-server already installed"
    exit 0
fi

mkdir -p "$INSTALL_DIR"
TMP_DIR=$(mktemp -d "$PREFIX/tmp/code-server.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading code-server v${VERSION}..."
if ! curl -fL "$URL" -o "$TMP_DIR/$TARBALL"; then
    echo -e "${RED}[FAIL]${NC} Failed to download code-server"
    exit 1
fi

echo "Extracting..."
tar -xzf "$TMP_DIR/$TARBALL" -C "$INSTALL_DIR" --strip-components=1 || echo -e "${YELLOW}[WARN]${NC} Tar reported errors (likely hardlink permissions on Android). Ignored."

if [ ! -f "$INSTALL_DIR/bin/code-server" ]; then
    echo -e "${RED}[FAIL]${NC} Critical files missing after extraction!"
    exit 1
fi

# Create wrapper
echo "Creating wrapper..."
mv "$INSTALL_DIR/bin/code-server" "$INSTALL_DIR/bin/code-server.real"

cat > "$INSTALL_DIR/bin/code-server" << EOF
#!/data/data/com.termux/files/usr/bin/bash
exec "$PREFIX/bin/grun" "$INSTALL_DIR/bin/code-server.real" "\$@"
EOF
chmod +x "$INSTALL_DIR/bin/code-server"

# Patch for Android (argon2 fix)
STUB="$OCA_DIR/patches/argon2-stub.js"
if [ -f "$STUB" ]; then
    echo "Applying argon2 stub..."
    # Hunt for argon2 in code-server lib
    find "$INSTALL_DIR/lib" -name "argon2.js" -exec cp "$STUB" {} \; 2>/dev/null || true
fi

# Link to bin
ln -sf "$INSTALL_DIR/bin/code-server" "$PREFIX/bin/code-server"

echo -e "${GREEN}[OK]${NC} code-server installed."
