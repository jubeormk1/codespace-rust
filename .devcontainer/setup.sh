#!/usr/bin/env bash
# postCreateCommand: runs once after the Codespace container is created.
# All heavy tooling is pre-installed in the image; this script is intentionally
# lightweight so Codespace creation completes quickly.
set -euo pipefail

log() { echo "==> $*"; }

# Ensure cargo env is on PATH for this script
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

log "Rust toolchain:"
rustup show active-toolchain 2>/dev/null || rustup show

log "Installed cargo tools:"
for tool in rustfmt clippy cargo-watch cargo-expand flip-link espflash espup; do
    printf "  %-16s %s\n" "$tool" "$(command -v "$tool" >/dev/null 2>&1 && echo 'ok' || echo 'NOT FOUND')"
done

log "ESP32 environment:"
if [ -f "$HOME/export-esp.sh" ]; then
    echo "  export-esp.sh: ok"
else
    echo "  WARNING: ~/export-esp.sh not found (espup may not have completed)"
fi

log "Setup verification complete — happy embedded hacking!"

