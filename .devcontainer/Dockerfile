FROM mcr.microsoft.com/devcontainers/base:debian-12

# ── System packages ────────────────────────────────────────────────────────────
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        gnupg2 \
        jq \
        libssl-dev \
        libudev-dev \
        openssl \
        pkg-config \
        sudo \
        vim \
        zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── User-level setup (runs as the non-root vscode user) ───────────────────────
USER vscode
ENV HOME=/home/vscode \
    PATH="/home/vscode/.cargo/bin:$PATH"

# Rust: stable + nightly toolchains, common components, and embedded targets
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path \
    && . ~/.cargo/env \
    && rustup install nightly \
    && rustup component add rustfmt clippy \
    && rustup component add rustfmt clippy --toolchain nightly \
    && rustup toolchain install stable --component rust-src \
    && rustup target add \
        riscv32imac-unknown-none-elf \
        riscv32imc-unknown-none-elf

# cargo-binstall: downloads pre-built binaries instead of compiling from source
RUN curl -L --proto '=https' --tlsv1.2 -sSf \
        https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
        | bash

# Cargo tools via binstall (pre-built binaries → seconds, not minutes)
RUN cargo-binstall -y \
        cargo-expand \
        cargo-edit \
        cargo-watch \
        flip-link \
        espflash \
        espup

# ESP32 Xtensa toolchain (ESP32 / S2 / S3); RISC-V (C3/C6) uses stable above
RUN espup install \
    && echo '. "$HOME/export-esp.sh"' >> ~/.bashrc \
    && echo '. "$HOME/export-esp.sh"' >> ~/.profile

# oh-my-zsh — non-interactive git clone, then wire up cargo + esp envs in .zshrc
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && echo '. "$HOME/.cargo/env"' >> ~/.zshrc \
    && echo '. "$HOME/export-esp.sh"' >> ~/.zshrc
