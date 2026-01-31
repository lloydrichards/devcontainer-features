#!/usr/bin/env bash

set -e

echo "Testing oh-my-posh-theme feature installation..."

if command -v oh-my-posh >/dev/null 2>&1; then
    echo "✅ oh-my-posh binary is available"
else
    echo "❌ oh-my-posh binary not found"
    exit 1
fi

if [ -f /usr/local/share/oh-my-posh/theme.toml ]; then
    echo "✅ theme file is installed"
else
    echo "❌ theme file not found"
    exit 1
fi

if [ -f /etc/profile.d/oh-my-posh.zsh ]; then
    echo "✅ zsh init snippet is installed"
else
    echo "❌ zsh init snippet not found"
    exit 1
fi

echo "✅ All tests passed!"
