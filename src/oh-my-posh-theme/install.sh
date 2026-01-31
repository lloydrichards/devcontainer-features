#!/usr/bin/env bash

set -euo pipefail

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SOURCE_DEFAULT="$FEATURE_DIR/theme.toml"

THEME_PATH="${THEME_PATH:-}"
THEME_DIR="/usr/local/share/oh-my-posh"
THEME_FILE_NAME="theme.toml"
INSTALL_DIR="/usr/local/bin"
INIT_SNIPPET_PATH="/etc/profile.d/oh-my-posh.zsh"

ZSHRC_SYSTEM="/etc/zshrc"
ZSHRC_SYSTEM_ALT="/etc/zsh/zshrc"

OH_MY_POSH_THEME="${THEME_DIR%/}/${THEME_FILE_NAME}"

install_deps() {
    if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
        if ! command -v apt-get >/dev/null 2>&1; then
            error "apt-get not found. Please install curl, ca-certificates, and unzip."
            exit 1
        fi
        apt-get update -y
        apt-get install -y --no-install-recommends curl ca-certificates unzip
        rm -rf /var/lib/apt/lists/*
    fi
}

install_oh_my_posh() {
    curl -fsSL --retry 3 --retry-connrefused https://ohmyposh.dev/install.sh | bash -s -- -d "$INSTALL_DIR"
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        error "oh-my-posh binary not found after install"
        exit 1
    fi
}

install_theme() {
    local theme_source="$THEME_SOURCE_DEFAULT"
    local temp_theme_path=""

    if [ -n "$THEME_PATH" ]; then
        if [[ "$THEME_PATH" =~ ^https?:// ]]; then
            temp_theme_path="$(mktemp)"
            curl -fsSL --retry 3 --retry-connrefused "$THEME_PATH" -o "$temp_theme_path"
            theme_source="$temp_theme_path"
        else
            if [ ! -f "$THEME_PATH" ]; then
                error "Theme file not found: $THEME_PATH"
                exit 1
            fi
            theme_source="$THEME_PATH"
        fi
    fi

    mkdir -p "$THEME_DIR"
    install -m 0644 "$theme_source" "$OH_MY_POSH_THEME"

    if [ -n "$temp_theme_path" ]; then
        rm -f "$temp_theme_path"
    fi
}

write_init_snippet() {
    cat > "$INIT_SNIPPET_PATH" << EOF
# oh-my-posh initialization for zsh
export DEVCONTAINER=1
if [ -n "\$ZSH_VERSION" ]; then
    case "\$-" in
        *i*) eval "\$(oh-my-posh init zsh --config \"$OH_MY_POSH_THEME\")" ;;
    esac
fi
EOF
}

ensure_zshrc_sources_posh() {
    local zshrc_path="$1"

    if [ ! -f "$zshrc_path" ]; then
        touch "$zshrc_path"
    fi

    if ! grep -qF "$INIT_SNIPPET_PATH" "$zshrc_path"; then
        cat >> "$zshrc_path" << EOF

# Load oh-my-posh init if available
if [ -f "$INIT_SNIPPET_PATH" ]; then
    source "$INIT_SNIPPET_PATH"
fi
EOF
    fi
}

install_deps
install_oh_my_posh
install_theme
write_init_snippet

ensure_zshrc_sources_posh "$ZSHRC_SYSTEM"
if [ -f "$ZSHRC_SYSTEM_ALT" ] || [ -d "$(dirname "$ZSHRC_SYSTEM_ALT")" ]; then
    ensure_zshrc_sources_posh "$ZSHRC_SYSTEM_ALT"
fi
