#!/usr/bin/env bash

set -e

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# Get custom greeting from options or use default
GREETING="${_OPTION_GREETING:-Hello, World!}"

log "Installing hello-world feature..."

# Create a simple executable script
cat > /usr/local/bin/hello-world << 'EOF'
#!/usr/bin/env bash
GREETING="${_OPTION_GREETING:-Hello, World!}"
echo "$GREETING"
EOF

# Make it executable
chmod +x /usr/local/bin/hello-world

log "Testing installation..."
if command -v hello-world &> /dev/null; then
    log "✅ hello-world command successfully installed"
    hello-world
else
    error "❌ Failed to install hello-world command"
    exit 1
fi

log "Installation completed successfully!"