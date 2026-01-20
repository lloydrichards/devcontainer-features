#!/usr/bin/env bash

set -e

# Test script for hello-world feature
echo "Testing hello-world feature installation..."

# Test if the feature was installed
if command -v hello-world &> /dev/null; then
    echo "✅ hello-world command is available"
else
    echo "❌ hello-world command not found"
    exit 1
fi

# Test basic functionality
echo "Testing basic functionality..."
hello-world

echo "✅ All tests passed!"