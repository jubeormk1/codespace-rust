FROM mcr.microsoft.com/devcontainers/base:debian-12

# Install system packages at build time (root, fast, cached by Docker).
# All user-level tooling (Rust, ESP32) is installed in postCreateCommand.
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
