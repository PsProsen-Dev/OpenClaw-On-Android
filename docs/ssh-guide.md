# SSH Setup Guide

## Quick Start (Password)

SSH is auto-configured during installation:

- **Port**: `8022`
- **Password**: `1234`

Connect from your PC:

```bash
ssh -p 8022 u0_a294@<phone-ip>
```

> Find your phone's IP: run `ifconfig` in Termux and look for `wlan0` → `inet` address.

## Change Password

```bash
passwd
# Enter new password twice
```

## SSH Key Authentication (Recommended)

SSH keys are more secure than passwords and don't require typing a password each time.

### Step 1: Generate a key on your PC

**Windows (PowerShell)**:
```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\openclaw_key" -N ""
```

**macOS / Linux**:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/openclaw_key -N ""
```

### Step 2: Copy the key to your phone

```bash
ssh-copy-id -i ~/.ssh/openclaw_key.pub -p 8022 u0_a294@<phone-ip>
```

Or manually:

```bash
cat ~/.ssh/openclaw_key.pub | ssh -p 8022 u0_a294@<phone-ip> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"
```

### Step 3: Connect with your key

```bash
ssh -i ~/.ssh/openclaw_key -p 8022 u0_a294@<phone-ip>
```

### Step 4 (Optional): Disable password auth

For maximum security, disable password authentication once keys are set up:

```bash
# On the phone (via SSH or Termux):
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config
pkill sshd; sshd
```

## Using SSH Keys from Multiple Devices

Each device needs its own key pair. Generate a key on the new device and add its public key to `~/.ssh/authorized_keys` on the phone:

```bash
echo "<new-public-key>" >> ~/.ssh/authorized_keys
```

## SSH Tunnel for Dashboard

Access the OpenClaw dashboard from your PC browser:

```bash
ssh -N -L 18789:127.0.0.1:18789 -p 8022 u0_a294@<phone-ip>
```

Then open: `http://localhost:18789/`

## Troubleshooting

### `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`

```bash
ssh-keygen -R "[<phone-ip>]:8022"
```

### Permission denied

- Check password: run `passwd` on the phone to reset
- Check key permissions: `chmod 600 ~/.ssh/openclaw_key`
- Ensure sshd is running: `sshd` on the phone

### Connection refused

- Ensure sshd is running: `sshd`
- Ensure correct port: `8022` (not `22`)
- Check phone IP has not changed
