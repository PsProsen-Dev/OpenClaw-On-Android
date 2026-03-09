#!/data/data/com.termux/files/usr/bin/bash
# OCA — Setup SSH server with default password
set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

SSH_PASSWORD="${1:-1234}"

if ! command -v sshd >/dev/null 2>&1; then
  pkg install -y openssh 2>/dev/null || true
fi

log_info "Setting SSH password..."
if printf "%s\n%s\n" "$SSH_PASSWORD" "$SSH_PASSWORD" | passwd 2>/dev/null; then
  log_ok "SSH password set to: $SSH_PASSWORD"
else
  log_warn "Could not set password automatically. Run 'passwd' manually."
fi

SSHD_CONFIG="$PREFIX/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSHD_CONFIG" 2>/dev/null || true
  sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSHD_CONFIG" 2>/dev/null || true
  log_ok "sshd_config updated (Password + PubKey auth enabled)"
fi

if [ ! -f "$PREFIX/etc/ssh/ssh_host_ed25519_key" ]; then
  ssh-keygen -A 2>/dev/null || true
  log_ok "SSH host keys generated"
fi

pkill sshd 2>/dev/null || true
sleep 1
if sshd 2>/dev/null; then
  log_ok "SSH server started on port 8022"
else
  log_warn "SSH server failed to start. Try running 'sshd' manually."
fi

WHOAMI=$(whoami)
IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "<phone-ip>")
echo ""
log_info "Connect from your PC:"
echo -e "  ${CYAN}ssh -p 8022 ${WHOAMI}@${IP}${NC}"
echo -e "  Password: ${CYAN}${SSH_PASSWORD}${NC}"
echo ""
log_warn "Change password later: passwd"
