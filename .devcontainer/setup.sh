#!/usr/bin/env bash
set -euo pipefail

log() { echo "==> $*"; }
ensure_in_profile() { local line=$1 file=$2; grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"; }

## Install rustup
log "Installing rustup..."
if [ ! -f "$HOME/.cargo/bin/rustup" ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
fi

# Source cargo environment for the rest of this script
. "$HOME/.cargo/env"

## Install Rust toolchains and components
log "Installing Rust toolchains and components..."
rustup install nightly
rustup component add rustfmt clippy
rustup component add rustfmt clippy --toolchain nightly
rustup toolchain install stable --component rust-src

## Install cargo tools
log "Installing cargo tools..."
cargo install cargo-expand
cargo install cargo-edit
cargo install cargo-watch
cargo install espflash

## ESP32 RISC-V targets
log "Adding ESP32 RISC-V targets..."
rustup target add riscv32imac-unknown-none-elf  # esp32c6
rustup target add riscv32imc-unknown-none-elf   # esp32-c2/c3

## Install espup and Xtensa toolchain (ESP32/S2/S3)
log "Installing espup..."
cargo install espup
log "Running espup install (this may take a while)..."
espup install

## Configure ESP environment
if [ -f "$HOME/export-esp.sh" ]; then
    log "Adding export-esp.sh to shell profiles..."
    ensure_in_profile '. "$HOME/export-esp.sh"' "$HOME/.bashrc"
    ensure_in_profile '. "$HOME/export-esp.sh"' "$HOME/.zshrc"
    rustup override set esp || log "WARNING: failed to set esp toolchain override"
else
    log "WARNING: $HOME/export-esp.sh not found after espup install; ESP32 (Xtensa) environment may be incomplete"
fi

## Install oh-my-zsh non-interactively
log "Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

## Ensure cargo/rust env is sourced in zsh profile
ensure_in_profile '. "$HOME/.cargo/env"' "$HOME/.zshrc"

## Set default shell to zsh
log "Setting default shell to zsh..."
sudo chsh -s /usr/bin/zsh "$(whoami)" || log "WARNING: could not set default shell to zsh"

log "Setup complete!"

