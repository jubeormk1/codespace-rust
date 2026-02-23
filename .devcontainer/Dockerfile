FROM mcr.microsoft.com/devcontainers/base:debian-12

# Install system dependencies during image build for better caching
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        expect \
        git \
        gnupg2 \
        jq \
        libssl-dev \
        openssl \
        pkg-config \
        sudo \
        vim \
        zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
