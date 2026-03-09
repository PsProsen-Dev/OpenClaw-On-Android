<div align="center">

![OCA Banner](docs/images/banner.png)

# 🤖 OpenClaw on Android (OCA)

### 🚀 Turn any Android phone into a 24/7 AI server — one command, zero hassle.

**Native performance via Termux & glibc. No Proot. No VM. Pure ARM64 power.**

<br/>

[![Release](https://img.shields.io/github/v/release/PsProsen-Dev/OpenClaw-On-Android?color=blue&label=latest&style=for-the-badge)](https://github.com/PsProsen-Dev/OpenClaw-On-Android/releases)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Discussions](https://img.shields.io/github/discussions/PsProsen-Dev/OpenClaw-On-Android?style=for-the-badge)](https://github.com/PsProsen-Dev/OpenClaw-On-Android/discussions)
[![Stars](https://img.shields.io/github/stars/PsProsen-Dev/OpenClaw-On-Android?style=for-the-badge&color=gold)](https://github.com/PsProsen-Dev/OpenClaw-On-Android/stargazers)
[![Forks](https://img.shields.io/github/forks/PsProsen-Dev/OpenClaw-On-Android?style=for-the-badge&color=orange)](https://github.com/PsProsen-Dev/OpenClaw-On-Android/network/members)

<br/>

[🚀 Quick Start](#-quick-start) • [⚡ Features](#-features) • [🦙 Local LLM](#-local-llm) • [📖 Docs](#-documentation) • [🏗 Architecture](#-project-architecture) • [🤝 Community](#-community)

</div>

---

## 🌟 The Vision

> **Your old Android phone is not e-waste. It's a powerful ARM64 server waiting to happen.**

OCA seamlessly installs the **OpenClaw** AI ecosystem directly onto your device via Termux. This completely bypasses sluggish Linux distributions (like Ubuntu on Proot), running **natively** with full `glibc` compatibility instead of Android's default Bionic libraries.

| Before OCA ❌ | After OCA ✅ |
|--------------|-------------|
| Slow Proot containers | **Native ARM64 execution** |
| Bionic libc limitations | **Full glibc compatibility** |
| Manual setup (hours) | **One-command install (2 mins)** |
| Limited AI tools | **4+ AI CLIs pre-configured** |
| No remote access | **SSH server included** |
| Static installation | **Auto-updating ecosystem** |

---

## 🚀 Quick Start

<div align="center">

### Deploying OCA takes under 2 minutes

</div>

1. **Open Termux** (from [F-Droid](https://f-droid.org/packages/com.termux/))
2. **Execute one command:**

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh | bash && source ~/.bashrc
```

3. **Answer the prompts** (Termux:API, Termux:Boot, AI CLIs)
4. **Done!** 🎉

<div align="center">

**That's it. You now have a full AI server on your phone.**

</div>

---

## ⚡ Features

<div align="center">

| <g-emoji class="g-emoji" alias="iphone">📱</g-emoji> Native Execution | <g-emoji class="g-emoji" alias="cloud">☁️</g-emoji> Full Node.js v24 |
|:---:|:---:|
| OpenClaw runs bare-metal in Termux | glibc-patched Node.js v24.14.0 |
| No Proot overhead | Official linux-arm64 binaries |
| 100% ARM64 optimized | Bypasses Android linker restrictions |

| <g-emoji class="g-emoji" alias="robot">🤖</g-emoji> AI CLI Tools | <g-emoji class="g-emoji" alias="llama">🦙</g-emoji> Local LLM |
|:---:|:---:|
| Qwen Code, Claude Code, Gemini, Codex | node-llama-cpp + Ollama support |
| Zero-config setup | Run models locally (experimental) |
| Cloud API routing | GGUF model support |

| <g-emoji class="g-emoji" alias="globe_with_meridians">🌐</g-emoji> Remote Access | <g-emoji class="g-emoji" alias="shield">🛡️</g-emoji> Safe Root |
|:---:|:---:|
| SSH server on port 8022 | `oca-root` wrapper for rooted devices |
| Remote terminal access | Selective root commands |
| 24/7 headless operation | No system compromise |

| <g-emoji class="g-emoji" alias="arrows_counterclockwise">🔄</g-emoji> Auto-Updates |
|:---:|
| One-command updates via `oca --update` |
| Automatic security patches |
| Rolling release model |

</div>

---

## 🦙 Local LLM

<div align="center">

### Run AI models directly on your phone!

</div>

OCA now supports **local LLM inference** via `node-llama-cpp` and `Ollama`. Your phone can run GGUF models natively!

<details>
<summary><b>⚠️ Important Constraints (click to expand)</b></summary>

| Constraint | Requirement | Reality Check |
|------------|-------------|---------------|
| **RAM** | 2-4GB free | Phone RAM is shared with Android |
| **Storage** | 4-70GB+ | Model files are large |
| **Speed** | CPU-only | No GPU offloading on Android |
| **Use Case** | Testing/Experimentation | Cloud APIs for production |

</details>

### Quick Start

```bash
# Option 1: node-llama-cpp (Recommended)
npm install -g node-llama-cpp --ignore-scripts

# Option 2: Ollama (Full Server)
curl -fsSL https://ollama.com/install.sh | sh
```

### Model Recommendations

| Model | Size | RAM Needed | Speed | Best For |
|-------|------|------------|-------|----------|
| **TinyLlama 1.1B** | ~670MB | 2GB | ⚡⚡⚡ | Testing |
| **Phi-3 Mini** | ~2.3GB | 4GB | ⚡⚡ | Light tasks |
| **Llama 3.2 1B** | ~670MB | 2GB | ⚡⚡⚡ | Mobile-friendly |
| **Mistral 7B** | ~4.1GB | 8GB | ⚡ | Advanced only |

> 📖 **[Read Full Local LLM Guide](docs/local-llm.mdx)** for detailed setup, troubleshooting, and cloud comparison.

---

## 🏗 Project Architecture

<div align="center">

![OCA Architecture](docs/images/architecture.png)

</div>

### How OCA Works

```
┌─────────────────────────────────────────────────────────┐
│              Android Device (Termux)                    │
│                         │                               │
│                         ▼                               │
│              ┌──────────────────┐                       │
│              │  glibc-runner    │                       │
│              │  (ld.so wrapper) │                       │
│              └────────┬─────────┘                       │
│                       │                                 │
│                       ▼                                 │
│              ┌──────────────────┐                       │
│              │  Node.js v24     │                       │
│              │  linux-arm64     │                       │
│              └────────┬─────────┘                       │
│                       │                                 │
│         ┌─────────────┴──────────────┐                 │
│         ▼                            ▼                 │
│  ┌──────────────┐           ┌──────────────┐          │
│  │ OpenClaw     │           │  Local LLM   │          │
│  │ Gateway      │           │  (Optional)  │          │
│  │              │           │              │          │
│  │ • AI CLIs    │           │ • llama.cpp  │          │
│  │ • SSH        │           │ • Ollama     │          │
│  │ • clawdhub   │           │ • GGUF       │          │
│  └──────────────┘           └──────────────┘          │
└─────────────────────────────────────────────────────────┘
```

### Technical Highlights

1. **Pacman `glibc-runner`**: Injects `ld-linux-aarch64.so.1` to bypass Android's restricted linker
2. **Path Rewriting**: UNIX paths (`/tmp`, `/bin/sh`) dynamically mapped to Termux prefixes
3. **JS Runtime Shims**: `glibc-compat.js` polyfills `os.cpus()` and `os.networkInterfaces()` for V8

---

## 📖 Documentation

<div align="center">

### Everything you need to run OCA like a pro

</div>

| 📚 Guide | Description |
|----------|-------------|
| [🚀 Quick Start](docs/quickstart.mdx) | Get running in 5 minutes |
| [🔧 Installation](docs/installation.mdx) | Full 8-step installer breakdown |
| [🤖 AI CLI Tools](docs/ai-cli-tools.mdx) | Qwen, Claude, Gemini, Codex setup |
| [🦙 Local LLM](docs/local-llm.mdx) | **NEW!** Run models locally |
| [⚙️ Configuration](docs/configuration.mdx) | Manage settings and preferences |
| [🔐 SSH Setup](docs/ssh-guide.mdx) | Remote access configuration |
| [🔧 Troubleshooting](docs/troubleshooting.mdx) | Common errors and fixes |
| [👻 Phantom Process Killer](docs/phantom-process-killer.mdx) | Android 12+ fix |

> 📑 **Browse all docs:** [`docs/`](docs/)

---

## 🛑 Important: Android 12+ Users

If you see `[Process completed (signal 9)]`, Android's Phantom Process Killer has terminated Termux.

**Fix it in 30 seconds:**

```bash
adb shell settings put global development_settings_enabled 1
adb shell settings put global max_phantom_processes 64
```

📖 **[Read Full Fix Guide](docs/disable-phantom-process-killer.mdx)**

---

## 🎯 What's New in v10.03.2026

<div align="center">

### 🦙 Local LLM Edition

</div>

| Feature | Description |
|---------|-------------|
| **node-llama-cpp** | Prebuilt binary support with `--ignore-scripts` |
| **Ollama Integration** | Full server with model management |
| **Model Guide** | Recommendations for RAM/Storage constraints |
| **Cloud vs Local** | Comparison table for decision making |

📦 **[View Release Notes](https://github.com/PsProsen-Dev/OpenClaw-On-Android/releases/tag/v10.03.2026)**

---

## 🤝 Community

<div align="center">

**Join the discussion!** Ask questions, share your Android setup, or request features.

[💬 GitHub Discussions](https://github.com/PsProsen-Dev/OpenClaw-On-Android/discussions)
&ensp;•&ensp;
[🐛 Report an Issue](https://github.com/PsProsen-Dev/OpenClaw-On-Android/issues)

</div>

---

## 🙏 Credits & License

<div align="center">

**Built with ⚡ by [PsProsen-Dev](https://github.com/PsProsen-Dev)**

Using _Jarvis (RTX⚡) / OpenClaw Authored Architecture_

<br/>

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg)](https://github.com/PsProsen-Dev)

</div>

---

<div align="center">

### 🚀 Ready to transform your Android phone?

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/OpenClaw-On-Android/master/bootstrap.sh | bash
```

**Your phone is now an AI server.** ⚡

</div>
