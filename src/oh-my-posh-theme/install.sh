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
ZSHRC_SYSTEM="/etc/zshrc"
ZSHRC_SYSTEM_ALT="/etc/zsh/zshrc"

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
if [ -n "$ZSH_VERSION" ]; then
    case "$-" in
        *i*) eval "$(oh-my-posh init zsh --config /usr/local/share/oh-my-posh/theme.toml)" ;;
    esac
fi
EOF

ensure_zshrc_sources_posh() {
    local zshrc_path="$1"

    if [ ! -f "$zshrc_path" ]; then
        log "Creating $zshrc_path"
        touch "$zshrc_path"
    fi

    if ! grep -q "oh-my-posh.zsh" "$zshrc_path"; then
        log "Ensuring $zshrc_path sources oh-my-posh init"
        cat >> "$zshrc_path" << 'EOF'

# Load oh-my-posh init if available
if [ -f /etc/profile.d/oh-my-posh.zsh ]; then
    source /etc/profile.d/oh-my-posh.zsh
fi
EOF
    fi
}

ensure_zshrc_sources_posh "$ZSHRC_SYSTEM"
if [ -f "$ZSHRC_SYSTEM_ALT" ] || [ -d "$(dirname "$ZSHRC_SYSTEM_ALT")" ]; then
    ensure_zshrc_sources_posh "$ZSHRC_SYSTEM_ALT"
fi

log "Installation completed successfully"
