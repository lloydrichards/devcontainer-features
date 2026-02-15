#!/usr/bin/env bash
set -e

# Detect correct user (default to 'node' or 'vscode' if available)
TARGET_USER="node"
if id -u vscode >/dev/null 2>&1; then TARGET_USER="vscode"; fi
if id -u root >/dev/null 2>&1; then TARGET_USER="root"; fi

# Store feature root directory
FEATURE_DIR=$(pwd)

# 1. Install rulesync globally
if command -v npm &> /dev/null; then
    npm install -g rulesync
else
    # Fallback if npm is missing
    curl -fsSL https://github.com/dyoshikawa/rulesync/releases/latest/download/install.sh | RULESYNC_HOME=/usr/local bash
fi

# 2. Setup Global Config (Persist in image, not volume)
GLOBAL_DIR="/usr/local/share/rulesync-global"
mkdir -p "$GLOBAL_DIR/.rulesync/rules"

# Initialize configs in global dir
cd "$GLOBAL_DIR"
# Initialize without failing if already initialized
rulesync init || true

# 3. Create rulesync configuration file
# Use default values if variables are empty (these are passed from devcontainer-feature.json options)
TARGETS="${TARGETS:-opencode}"
FEATURES="${FEATURES:-rules,subagents,skills}"
# CONFIG_PATH is not used for file location (we enforce standard location), but maybe we should respect it?
# For now, let's stick to standard locations for predictability.

cat > "$GLOBAL_DIR/rulesync.jsonc" <<EOF
{
  "targets": [$(echo "\"$TARGETS\"" | sed 's/,/","/g')],
  "features": [$(echo "\"$FEATURES\"" | sed 's/,/","/g')]
}
EOF

# 4. Create rulesync rules directory and overview.md file
cat > "$GLOBAL_DIR/.rulesync/rules/overview.md" <<EOF
---
root: true
---

# The Project Overview

...
EOF

# Copy bundled subagents to the global rulesync directory
# These will be picked up by 'rulesync generate' and persisted to user home by rulesync-init
if [ -d "$FEATURE_DIR/context/subagents" ]; then
    mkdir -p "$GLOBAL_DIR/.rulesync/subagents"
    echo "Copying subagents from $FEATURE_DIR/context/subagents to $GLOBAL_DIR/.rulesync/subagents"
    cp -r "$FEATURE_DIR/context/subagents/"* "$GLOBAL_DIR/.rulesync/subagents/"
fi

# Copy bundled commands to the global rulesync directory
if [ -d "$FEATURE_DIR/context/commands" ]; then
    mkdir -p "$GLOBAL_DIR/.rulesync/commands"
    echo "Copying commands from $FEATURE_DIR/context/commands to $GLOBAL_DIR/.rulesync/commands"
    cp -r "$FEATURE_DIR/context/commands/"* "$GLOBAL_DIR/.rulesync/commands/"
fi

# Copy bundled skills to the global rulesync directory
if [ -d "$FEATURE_DIR/context/skills" ]; then
    mkdir -p "$GLOBAL_DIR/.rulesync/skills"
    echo "Copying skills from $FEATURE_DIR/context/skills to $GLOBAL_DIR/.rulesync/skills"
    cp -r "$FEATURE_DIR/context/skills/"* "$GLOBAL_DIR/.rulesync/skills/"
fi

# 5. Generate rulesync rules in global dir
rulesync generate
# Ensure readable by all users
chmod -R a+rx "$GLOBAL_DIR"

# 6. Setup Auto-Copy (Ensure persistence in user home volume)
# We create a script that will be triggered by postCreateCommand in devcontainer-feature.json
INIT_SCRIPT="/usr/local/bin/rulesync-init"
cat > "$INIT_SCRIPT" <<EOF
#!/bin/bash
# Install to ~/.rulesync (standard location for local rulesync config)
RULESYNC_DIR="\$HOME/.rulesync"
OPENCODE_CONFIG_DIR="\$HOME/.config/opencode"

if [ ! -d "\$RULESYNC_DIR" ]; then
    echo "Initializing local rulesync configuration in \$RULESYNC_DIR..."
    mkdir -p "\$RULESYNC_DIR"
    # Copy contents of GLOBAL_DIR (which includes .rulesync folder and rulesync.jsonc)
    cp -r "$GLOBAL_DIR/." "\$RULESYNC_DIR/"
    
    # Run generate to ensure tools (like opencode) pick up the new config
    # This generates output to ~/.rulesync/.opencode/agent etc.
    if command -v rulesync &> /dev/null; then
        cd "\$RULESYNC_DIR" && rulesync generate
        
        # Symlink generated OpenCode config to standard location
        mkdir -p "\$OPENCODE_CONFIG_DIR"
        
        # Symlink agent directory if it exists and target doesn't
        if [ -d "\$RULESYNC_DIR/.opencode/agent" ] && [ ! -e "\$OPENCODE_CONFIG_DIR/agent" ]; then
            ln -s "\$RULESYNC_DIR/.opencode/agent" "\$OPENCODE_CONFIG_DIR/agent"
            echo "Symlinked OpenCode agent directory"
        fi
        
        # Symlink skill directory if it exists and target doesn't
        if [ -d "\$RULESYNC_DIR/.opencode/skill" ] && [ ! -e "\$OPENCODE_CONFIG_DIR/skill" ]; then
            ln -s "\$RULESYNC_DIR/.opencode/skill" "\$OPENCODE_CONFIG_DIR/skill"
            echo "Symlinked OpenCode skill directory"
        fi
    fi
fi
EOF
chmod +x "$INIT_SCRIPT"

echo "Rulesync setup complete."
