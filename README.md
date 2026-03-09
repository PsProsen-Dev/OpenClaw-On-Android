# 🦞 OCA — OpenClaw on Android

> **Turn any Android phone into a 24/7 AI server — one command, zero hassle.**
> No proot, no Ubuntu, pure Termux.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 💡 The Idea

Your old Android phone? It's a powerful ARM server waiting to happen. OCA installs [OpenClaw](https://github.com/openclaw) directly on Termux with glibc compatibility — no Linux distribution needed.

**What you get:**
- ☁️ OpenClaw AI gateway on your phone
- 🔧 Full Node.js v24 environment (glibc, not Bionic)
- 🛠️ AI CLI tools (Claude Code, Gemini, Codex, Qwen Code, OpenCode)
- 🌐 Browser IDE (code-server)
- 📱 SSH access + auto-start on boot
- 🔐 Root access integration (for rooted devices)

---

## 🚀 Quick Start

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh | bash && source ~/.bashrc
```

That's it. The installer handles everything.

---

## 📋 Prerequisites

- Android phone (aarch64/arm64 — API 24+)
- [Termux](https://f-droid.org/en/packages/com.termux/) (F-Droid version)
- ~2GB free storage
- WiFi connection

### Recommended Add-ons (from F-Droid):
| App | Purpose |
|-----|---------|
| [Termux:Boot](https://f-droid.org/en/packages/com.termux.boot/) | Auto-start on reboot |
| [Termux:API](https://f-droid.org/en/packages/com.termux.api/) | Camera, sensors, notifications |

---

## 📖 Full Setup Guide

### 1️⃣ Prepare Your Phone

1. Install **Termux** from F-Droid (NOT Play Store)
2. Open Termux and run: `pkg update && pkg upgrade`
3. (Optional) Install Termux:Boot and Termux:API from F-Droid

### 2️⃣ Install & Configure

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh | bash && source ~/.bashrc
```

The installer will ask which optional tools you want:

| Tool | Description | Recommendation |
|------|-------------|---------------|
| tmux | Terminal multiplexer | ⭐ Highly recommended |
| ttyd | Web terminal | Optional |
| dufs | File server | Optional |
| android-tools | ADB access | ⭐ Highly recommended |
| code-server | Browser IDE | Optional |
| OpenCode | AI coding assistant | Optional |
| Claude Code CLI | Anthropic's CLI | Optional |
| Gemini CLI | Google's CLI | Optional |
| Codex CLI | OpenAI's CLI | Optional |
| Qwen Code CLI | Qwen's CLI | Optional |
| SSH server | Remote access | ⭐ Highly recommended |
| Termux:Boot | Auto-start | ⭐ Highly recommended |
| Termux:API | Device sensors | Optional |

### 3️⃣ Run the Gateway

```bash
openclaw gateway
```

### 4️⃣ Access From Your PC

```bash
# Via SSH (port 8022)
ssh -p 8022 <phone-ip>

# Via browser (if code-server installed)
http://<phone-ip>:8080
```

---

## 🔐 SSH Access

Default: port 8022, password 1234

```bash
# From your PC
ssh -p 8022 <phone-ip>
```

Change password (do this first!):
```bash
passwd
```

Use SSH keys (recommended):
```bash
# On your PC
ssh-keygen -t ed25519 -f ~/.ssh/oca_server -N ""
ssh-copy-id -i ~/.ssh/oca_server.pub -p 8022 <phone-ip>
ssh -i ~/.ssh/oca_server -p 8022 <phone-ip>
```

📘 [Full SSH guide →](docs/termux-ssh-guide.md)

---

## 🛑 Android 12+ — Kill Phantom Process Killer

Android 12+ aggressively kills background processes (`[Process completed (signal 9)]`). Fix it once:

```bash
# Already installed by the setup script
adb pair localhost:<PAIRING_PORT> <CODE>
adb connect localhost:<CONNECTION_PORT>
adb shell "settings put global settings_enable_monitor_phantom_procs false"
```

📘 [Step-by-step guide →](docs/disable-phantom-process-killer.md)

---

## ⚙️ CLI Reference

```bash
oca --help        # Show all commands
oca --version     # Version + update check
oca --update      # Update OpenClaw + patches + tools
oca --install     # Install optional tools
oca --status      # Show installation status
oca --uninstall   # Remove everything
```

---

## 🔄 Updates

```bash
oca --update
# or
ocaupdate
```

Or re-run the installer for a full refresh:
```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh | bash
```

---

## 🗑️ Uninstall

```bash
oca --uninstall
```

This cleanly removes:
- `~/.oca/` (project directory)
- `$PREFIX/bin/oca`, `ocaupdate`, `oca-root`
- `~/.termux/boot/oca-boot.sh`
- `.bashrc` environment block
- Optionally: `~/.openclaw` data + AI CLI tools

---

## 🔐 Root Access (Rooted Devices)

If your device is rooted, OCA automatically sets up a safe root wrapper:

```bash
oca-root getprop ro.build.version.release   # ✅ Allowed
oca-root rm -rf /                           # ❌ Blocked
```

Only whitelisted commands are allowed. Edit `$PREFIX/bin/oca-root` to add more.

---

## ⚙️ How It Works

The installer bridges Termux (Bionic libc) and standard Linux (glibc):

1. **glibc-runner** provides `ld-linux-aarch64.so.1` via pacman
2. **Node.js v24** (linux-arm64) runs through a wrapper script that uses `ld.so`
3. **Path patches** rewrite `/tmp`, `/bin/sh`, `/usr/bin/env` to Termux equivalents
4. **glibc-compat.js** fixes Android kernel quirks (`os.cpus()`, `os.networkInterfaces()`)

---

## 📁 Project Structure

```
OpenClaw-On-Android/
├── bootstrap.sh              # One-liner entry point
├── install.sh                # Master installer (8 steps)
├── oca.sh                    # CLI management tool
├── update.sh                 # Update wrapper
├── update-core.sh            # Update logic
├── uninstall.sh              # Clean removal
├── scripts/
│   ├── lib.sh                # Shared library (colors, constants, functions)
│   ├── check-env.sh          # Pre-flight checks
│   ├── install-infra-deps.sh # Termux packages
│   ├── install-glibc.sh      # glibc-runner setup
│   ├── install-nodejs.sh     # Node.js v24 + wrapper
│   ├── install-build-tools.sh # Build tools
│   ├── setup-paths.sh        # Path mappings
│   ├── setup-env.sh          # .bashrc configuration
│   ├── setup-ssh.sh          # SSH server setup
│   ├── setup-boot.sh         # Termux:Boot auto-start
│   ├── setup-termux-api.sh   # Termux:API integration
│   └── setup-root.sh         # Root access wrapper
├── patches/
│   ├── glibc-compat.js       # Runtime compatibility patches
│   ├── bionic-compat.js      # Platform patches
│   ├── patch-paths.sh        # Path rewriter
│   ├── apply-patches.sh      # Patch orchestrator
│   ├── spawn.h               # POSIX spawn stub
│   ├── systemctl             # systemctl stub
│   └── termux-compat.h       # renameat2 stub
├── platforms/openclaw/        # OpenClaw platform plugin
├── tests/
│   └── verify-install.sh     # Post-install health check
├── docs/                     # Guides and troubleshooting
└── LICENSE
```

---

## 🙏 Credits

Inspired by [AidanPark/openclaw-android](https://github.com/AidanPark/openclaw-android).

Built by **[PsProsen-Dev](https://github.com/PsProsen-Dev)** ⚡

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
