#!/usr/bin/env bash

set -e

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SOURCE="$FEATURE_DIR/theme.toml"
THEME_DIR="/usr/local/share/oh-my-posh"
THEME_DEST="$THEME_DIR/theme.toml"
INIT_SNIPPET_PATH="/etc/profile.d/oh-my-posh.zsh"

log "Installing oh-my-posh..."
if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    log "curl or unzip not found; installing"
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates unzip
    rm -rf /var/lib/apt/lists/*
fi
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

if ! command -v oh-my-posh >/dev/null 2>&1; then
    error "oh-my-posh binary not found after install"
    exit 1
fi

log "Copying theme to $THEME_DEST"
mkdir -p "$THEME_DIR"
cp "$THEME_SOURCE" "$THEME_DEST"

log "Writing zsh init snippet"
cat > "$INIT_SNIPPET_PATH" << 'EOF'
# oh-my-posh initialization for zsh
export DEVCONTAINER=1
if [ -n "$ZSH_VERSION" ] && [ -o interactive ]; then
    eval "$(oh-my-posh init zsh --config /usr/local/share/oh-my-posh/theme.toml)"
fi
EOF

log "Installation completed successfully"
