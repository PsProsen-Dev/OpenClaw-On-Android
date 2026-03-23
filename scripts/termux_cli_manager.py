#!/usr/bin/env python3
"""
OCA Termux CLI Manager

Focused manager/fixer for Gemini CLI and Qwen Code on Termux/Android.
It follows OCA's safe strategy:
  - ensure system ripgrep is installed
  - install CLI packages with --ignore-scripts
  - create stable wrappers that force execution through OCA's glibc Node.js
  - provide logging + lightweight verification helpers
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


HOME = Path.home()
CONFIG_DIR = HOME / ".termux_cli_manager"
LOG_FILE = CONFIG_DIR / "manager.log"
CONFIG_FILE = CONFIG_DIR / "config.json"
PREFIX = Path(os.environ.get("PREFIX", "/data/data/com.termux/files/usr"))
GLOBAL_NODE_MODULES = PREFIX / "lib" / "node_modules"
NODE_BIN = HOME / ".oca" / "node" / "bin" / "node"


@dataclass(frozen=True)
class ToolSpec:
    key: str
    package: str
    command: str
    entrypoint: Path


TOOLS = {
    "gemini": ToolSpec(
        key="gemini",
        package="@google/gemini-cli",
        command="gemini",
        entrypoint=GLOBAL_NODE_MODULES / "@google" / "gemini-cli" / "bin" / "gemini",
    ),
    "qwen": ToolSpec(
        key="qwen",
        package="@qwen-code/qwen-code",
        command="qwen",
        entrypoint=GLOBAL_NODE_MODULES / "@qwen-code" / "qwen-code" / "dist" / "index.js",
    ),
}


def ensure_dirs() -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    if not CONFIG_FILE.exists():
        CONFIG_FILE.write_text(json.dumps({"version": 1, "managed_tools": []}, indent=2) + "\n")


def log(message: str) -> None:
    ensure_dirs()
    with LOG_FILE.open("a", encoding="utf-8") as fh:
        fh.write(message.rstrip() + "\n")
    print(message)


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    log(f"$ {' '.join(cmd)}")
    return subprocess.run(cmd, text=True, check=check, capture_output=True)


def stream(cmd: list[str], check: bool = True) -> int:
    log(f"$ {' '.join(cmd)}")
    proc = subprocess.run(cmd, text=True, check=False)
    if check and proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, cmd)
    return proc.returncode


def update_config(tool: str) -> None:
    ensure_dirs()
    data = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    managed = set(data.get("managed_tools", []))
    managed.add(tool)
    data["managed_tools"] = sorted(managed)
    CONFIG_FILE.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def ensure_ripgrep() -> None:
    if shutil.which("rg"):
        log("[OK] ripgrep already installed")
        return
    stream(["pkg", "install", "-y", "ripgrep"])
    if not shutil.which("rg"):
        raise RuntimeError("ripgrep install completed but rg command is still missing")
    log("[OK] ripgrep installed")


def install_tool(spec: ToolSpec) -> None:
    stream(
        [
            "npm",
            "install",
            "-g",
            spec.package,
            "--ignore-scripts",
            "--no-audit",
            "--no-fund",
            "--loglevel=error",
        ]
    )
    update_config(spec.key)
    log(f"[OK] installed {spec.package}")


def update_tool(spec: ToolSpec) -> None:
    stream(
        [
            "npm",
            "update",
            "-g",
            spec.package,
            "--ignore-scripts",
            "--no-audit",
            "--no-fund",
            "--loglevel=error",
        ]
    )
    log(f"[OK] updated {spec.package}")


def uninstall_tool(spec: ToolSpec) -> None:
    stream(["npm", "uninstall", "-g", spec.package], check=False)
    wrapper = PREFIX / "bin" / spec.command
    if wrapper.exists() or wrapper.is_symlink():
        wrapper.unlink()
    log(f"[OK] removed {spec.package} and wrapper")


def write_wrapper(spec: ToolSpec) -> None:
    if not NODE_BIN.exists():
        raise RuntimeError(f"OCA Node.js wrapper missing at {NODE_BIN}")
    if not spec.entrypoint.exists():
        raise RuntimeError(f"Entrypoint missing for {spec.package}: {spec.entrypoint}")

    wrapper_path = PREFIX / "bin" / spec.command
    wrapper_path.parent.mkdir(parents=True, exist_ok=True)
    wrapper = f"""#!/data/data/com.termux/files/usr/bin/bash
set -e
export PATH="{PREFIX}/bin:$PATH"
if command -v rg >/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="${{RIPGREP_CONFIG_PATH:-}}"
fi
  exec "{NODE_BIN}" {"--no-warnings=DEP0040" if spec.key == "gemini" else ""} "{spec.entrypoint}" "$@"
"""
    wrapper_path.write_text(wrapper, encoding="utf-8")
    wrapper_path.chmod(0o755)
    log(f"[OK] wrapper refreshed: {wrapper_path}")


def patch_tool(spec: ToolSpec) -> None:
    ensure_ripgrep()
    write_wrapper(spec)
    log(f"[OK] {spec.key} patched for Termux/OCA runtime")


def verify_tool(spec: ToolSpec) -> bool:
    wrapper = PREFIX / "bin" / spec.command
    issues: list[str] = []
    if not shutil.which("rg"):
        issues.append("rg missing")
    if not NODE_BIN.exists():
        issues.append("oca node missing")
    if not spec.entrypoint.exists():
        issues.append(f"entrypoint missing: {spec.entrypoint}")
    if not wrapper.exists():
        issues.append(f"wrapper missing: {wrapper}")
    if issues:
        log(f"[FAIL] {spec.key}: " + "; ".join(issues))
        return False
    log(f"[OK] {spec.key}: wrapper + entrypoint + ripgrep present")
    return True


def interactive() -> int:
    menu = """
1) Install Gemini
2) Update Gemini
3) Uninstall Gemini
4) Install Qwen
5) Update Qwen
6) Uninstall Qwen
7) Patch Gemini
8) Patch Qwen
9) Patch both
10) Ensure ripgrep
11) Verify installations
0) Exit
"""
    print(menu)
    choice = input("Select: ").strip()
    mapping = {
        "1": lambda: (ensure_ripgrep(), install_tool(TOOLS["gemini"]), patch_tool(TOOLS["gemini"])),
        "2": lambda: (update_tool(TOOLS["gemini"]), patch_tool(TOOLS["gemini"])),
        "3": lambda: uninstall_tool(TOOLS["gemini"]),
        "4": lambda: (ensure_ripgrep(), install_tool(TOOLS["qwen"]), patch_tool(TOOLS["qwen"])),
        "5": lambda: (update_tool(TOOLS["qwen"]), patch_tool(TOOLS["qwen"])),
        "6": lambda: uninstall_tool(TOOLS["qwen"]),
        "7": lambda: patch_tool(TOOLS["gemini"]),
        "8": lambda: patch_tool(TOOLS["qwen"]),
        "9": lambda: (patch_tool(TOOLS["gemini"]), patch_tool(TOOLS["qwen"])),
        "10": ensure_ripgrep,
        "11": lambda: verify_tool(TOOLS["gemini"]) and verify_tool(TOOLS["qwen"]),
        "0": lambda: None,
    }
    action = mapping.get(choice)
    if action is None:
        print("Invalid choice")
        return 1
    action()
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Manage Gemini/Qwen on OCA Termux")
    parser.add_argument("--install-gemini", action="store_true")
    parser.add_argument("--update-gemini", action="store_true")
    parser.add_argument("--uninstall-gemini", action="store_true")
    parser.add_argument("--patch-gemini", action="store_true")
    parser.add_argument("--install-qwen", action="store_true")
    parser.add_argument("--update-qwen", action="store_true")
    parser.add_argument("--uninstall-qwen", action="store_true")
    parser.add_argument("--patch-qwen", action="store_true")
    parser.add_argument("--patch-both", action="store_true")
    parser.add_argument("--ensure-rg", action="store_true")
    parser.add_argument("--verify", action="store_true")
    return parser.parse_args()


def main() -> int:
    ensure_dirs()
    args = parse_args()

    if len(sys.argv) == 1:
        return interactive()

    try:
        if args.ensure_rg:
            ensure_ripgrep()

        if args.install_gemini:
            install_tool(TOOLS["gemini"])
        if args.update_gemini:
            update_tool(TOOLS["gemini"])
        if args.uninstall_gemini:
            uninstall_tool(TOOLS["gemini"])
        if args.patch_gemini:
            patch_tool(TOOLS["gemini"])

        if args.install_qwen:
            install_tool(TOOLS["qwen"])
        if args.update_qwen:
            update_tool(TOOLS["qwen"])
        if args.uninstall_qwen:
            uninstall_tool(TOOLS["qwen"])
        if args.patch_qwen:
            patch_tool(TOOLS["qwen"])

        if args.patch_both:
            patch_tool(TOOLS["gemini"])
            patch_tool(TOOLS["qwen"])

        if args.verify:
            gemini_ok = verify_tool(TOOLS["gemini"])
            qwen_ok = verify_tool(TOOLS["qwen"])
            return 0 if gemini_ok and qwen_ok else 1
    except Exception as exc:  # noqa: BLE001
        log(f"[FAIL] {exc}")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
