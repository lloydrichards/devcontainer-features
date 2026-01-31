#!/usr/bin/env bash

set -e

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SOURCE="$FEATURE_DIR/theme.toml"
THEME_DIR="/usr/local/share/oh-my-posh"
THEME_DEST=""
INIT_SNIPPET_PATH="/etc/profile.d/oh-my-posh.zsh"
ZSHRC_SYSTEM="/etc/zsh/zshrc"

if [ -n "${THEMEPATH:-}" ]; then
    THEME_SOURCE="$THEMEPATH"
fi

ensure_packages() {
    if command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
        return
    fi

    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates unzip
    rm -rf /var/lib/apt/lists/*
}

install_oh_my_posh() {
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin
    command -v oh-my-posh >/dev/null 2>&1 || { echo "oh-my-posh binary not found after install" >&2; exit 1; }
}

install_theme() {
    local theme_basename

    mkdir -p "$THEME_DIR"

    theme_basename="$(basename "$THEME_SOURCE")"
    if [[ "$theme_basename" != *.json && "$theme_basename" != *.toml && "$theme_basename" != *.yaml && "$theme_basename" != *.yml ]]; then
        theme_basename="theme.toml"
    fi

    THEME_DEST="$THEME_DIR/$theme_basename"

    case "$THEME_SOURCE" in
        http://*|https://*)
            curl -fsSL "$THEME_SOURCE" -o "$THEME_DEST"
            ;;
        *)
            cp "$THEME_SOURCE" "$THEME_DEST"
            ;;
    esac
}

write_init_snippet() {
    cat > "$INIT_SNIPPET_PATH" << EOF
export DEVCONTAINER=1
if [ -n "\$ZSH_VERSION" ]; then
    case "\$-" in
        *i*) eval "\$(oh-my-posh init zsh --config $THEME_DEST)" ;;
    esac
fi
EOF
}

update_zshrcs() {
    if [ ! -f "$ZSHRC_SYSTEM" ]; then
        touch "$ZSHRC_SYSTEM"
    fi

    if ! grep -q "oh-my-posh.zsh" "$ZSHRC_SYSTEM"; then
        cat >> "$ZSHRC_SYSTEM" << 'EOF'

if [ -f /etc/profile.d/oh-my-posh.zsh ]; then
    source /etc/profile.d/oh-my-posh.zsh
fi
EOF
    fi
}

main() {
    ensure_packages
    install_oh_my_posh
    install_theme
    write_init_snippet
    update_zshrcs
}

main
