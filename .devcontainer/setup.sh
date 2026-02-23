#!/usr/bin/env bash
# postCreateCommand: runs once after the Codespace container is created.
# Uses pre-built binaries (cargo-binstall) to avoid source compilation and OOM.
set -euo pipefail

log() { echo "==> $*"; }
ensure_in_profile() {
    local line=$1 file=$2
    grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

## ── Rustup ────────────────────────────────────────────────────────────────────
log "Installing rustup..."
if [ ! -f "$HOME/.cargo/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"

## ── Rust toolchains, components, and embedded targets ────────────────────────
log "Configuring Rust toolchains..."
rustup install nightly
rustup component add rustfmt clippy
rustup component add rustfmt clippy --toolchain nightly
rustup toolchain install stable --component rust-src

log "Adding embedded Rust targets..."
rustup target add riscv32imac-unknown-none-elf  # esp32c6
rustup target add riscv32imc-unknown-none-elf   # esp32-c2/c3

## ── cargo-binstall (pre-built binary installer — no source compilation) ───────
log "Installing cargo-binstall..."
if ! command -v cargo-binstall >/dev/null 2>&1; then
    curl -L --proto '=https' --tlsv1.2 -sSf \
        https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
        | bash
fi

## ── Cargo tools via binstall (downloads pre-built binaries, not source) ──────
log "Installing cargo tools..."
cargo-binstall -y \
    cargo-expand \
    cargo-edit \
    cargo-watch \
    flip-link \
    espflash \
    espup

## ── ESP32 Xtensa toolchain (ESP32 / S2 / S3) ─────────────────────────────────
log "Installing ESP32 Xtensa toolchain (this downloads ~400 MB)..."
espup install

## ── Shell profile configuration ───────────────────────────────────────────────
log "Configuring shell profiles..."
ensure_in_profile '. "$HOME/.cargo/env"' "$HOME/.bashrc"
ensure_in_profile '. "$HOME/.cargo/env"' "$HOME/.profile"
if [ -f "$HOME/export-esp.sh" ]; then
    ensure_in_profile '. "$HOME/export-esp.sh"' "$HOME/.bashrc"
    ensure_in_profile '. "$HOME/export-esp.sh"' "$HOME/.profile"
else
    log "WARNING: ~/export-esp.sh not found after espup install"
fi

## ── oh-my-zsh ─────────────────────────────────────────────────────────────────
log "Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi
ensure_in_profile '. "$HOME/.cargo/env"' "$HOME/.zshrc"
if [ -f "$HOME/export-esp.sh" ]; then
    ensure_in_profile '. "$HOME/export-esp.sh"' "$HOME/.zshrc"
fi

log "Setup complete!"

