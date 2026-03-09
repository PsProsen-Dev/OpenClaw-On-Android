# OCA 09.03.2026

## Changes

- **Core Rebranding**: Complete transformation from OpenClaw Pocket Server to **OpenClaw on Android (OCA)** (`~/.oca/`).
- **Node.js Upgrade**: Bumped environment to Active LTS **Node.js v24.14.0** for modern feature support.
- **Root Access Integration**: Added `setup-root.sh` providing a safe `oca-root` wrapper with explicitly whitelisted system commands for rooted devices.
- **Termux Automation**: Added first-class support for **Termux:Boot** (`oca-boot.sh`) for auto-start, and **Termux:API** integration.
- **AI CLI Models**: Integrated **Qwen Code CLI** (`@qwen-code/qwen-code@latest`) into the optional installation and update flows.
- **Installer Enhancements**: Added clear `(optional)` and `(optional but highly recommended)` labels to interactive prompts, including SSH server setup.
- **Legacy Migration**: Implemented automatic seamless migration from existing `~/.openclaw-pocket-server` paths to the new `~/.oca/` ecosystem.
- **Uninstaller Safety**: Thoroughly clean up all environment variables, `.bashrc` blocks, and legacy directories in `oca --uninstall`.
- **Date-based Versioning**: Adopted custom `dd.mm.yyyy` versioning format.
