FROM mcr.microsoft.com/devcontainers/base:debian-12

WORKDIR /home/

COPY . .

RUN bash ./setup.sh

ENV PATH="/root/.cargo/bin:$PATH"
