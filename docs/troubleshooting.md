# Troubleshooting Guide

Common issues and their solutions for OpenClaw Pocket Server on Android/Termux.

## Build Errors

### `renameat2` / `RENAME_NOREPLACE` not declared

**Symptoms**: `koffi` or other native modules fail to build with errors about undeclared `renameat2` or `RENAME_NOREPLACE`.

**Cause**: Android Bionic libc doesn't expose `renameat2()` in older API levels, even though the kernel supports it.

**Fix**: The installer automatically handles this via `termux-compat.h`. If you need to rebuild manually:

```bash
export CXXFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
export CFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
npm install -g openclaw@latest
```

### `make: ar: No such file or directory`

**Symptoms**: `sharp` or other native modules fail during `node-gyp` rebuild.

**Cause**: Termux's `binutils` installs `llvm-ar` but doesn't create the standard `ar` symlink.

**Fix**:

```bash
ln -sf $PREFIX/bin/llvm-ar $PREFIX/bin/ar
npm rebuild sharp --prefix $PREFIX/lib/node_modules/openclaw
```

## Gateway Errors

### `error: expected absolute path: "--disable-warning=ExperimentalWarning"`

**Symptoms**: `openclaw gateway` crashes immediately with this error.

**Cause**: OpenClaw respawns itself with `--disable-warning=ExperimentalWarning` prepended to `process.execArgv`. On Node.js v24+, the existing `-r bionic-compat.js` from `NODE_OPTIONS` causes argument parsing conflicts.

**Fix**:

```bash
echo 'export OPENCLAW_NODE_OPTIONS_READY=1' >> ~/.bashrc
source ~/.bashrc
openclaw gateway
```

### Gateway `ECONNREFUSED` on port 18789

**Symptoms**: `openclaw status` shows "unreachable (connect ECONNREFUSED 127.0.0.1:18789)".

**Cause**: The gateway process isn't running.

**Fix**:

```bash
source ~/.bashrc
tmux new-session -s OpenClaw
openclaw gateway
```

## SSH Issues

### Password not working after automated install

**Cause**: If the install script ran from a Windows host (via ADB), CRLF line endings may have corrupted the password hash. The stored password becomes `1234\r` instead of `1234`.

**Fix**:

```bash
passwd
# Enter your desired password twice
```

### `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`

**Cause**: Termux was reinstalled or SSH host keys were regenerated.

**Fix** (run on your PC):

```bash
ssh-keygen -R "[<phone-ip>]:8022"
```

Then connect again normally.

## tmux Issues

### `tmux: no sessions`

**Cause**: The tmux session was killed (phone rebooted, Android killed Termux, etc.).

**Fix**:

```bash
tmux new-session -s OpenClaw
openclaw gateway
```

**Prevention**: Install Termux:Boot and open it once. The boot script at `~/.termux/boot/openclaw-boot.sh` will auto-recreate the session on reboot.

### tmux session created via SSH dies when SSH disconnects

**Cause**: tmux sessions created from within an SSH session may be linked to that session's process tree.

**Fix**: Start the tmux session directly from the Termux app on the phone, not via SSH. Or use:

```bash
tmux new-session -d -s OpenClaw "source ~/.bashrc && openclaw gateway"
```

## Android-Specific Issues

### Termux killed in background

**Cause**: Android battery optimization kills background apps.

**Fix**:

1. Run `termux-wake-lock` in Termux
2. Settings > Battery > Find Termux > Set to "Not optimized" / "Unrestricted"
3. Enable "Stay awake while charging" in Developer Options

### Mirror errors during `pkg install`

**Cause**: Default Termux mirror may be unreachable.

**Fix**:

```bash
termux-change-repo
```

Select a mirror closer to your location.
