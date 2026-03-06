#!/bin/sh
set -e

PLUGIN_DIR="$HOME/.claude/plugins/claude-gateway"
REPO_URL="https://github.com/jdscript/claude-gateway-plugin.git"

if [ -d "$PLUGIN_DIR" ]; then
  echo "Updating existing installation..."
  git -C "$PLUGIN_DIR" pull --ff-only
else
  echo "Installing Claude Gateway plugin..."
  mkdir -p "$HOME/.claude/plugins"
  git clone "$REPO_URL" "$PLUGIN_DIR"
fi

# Ensure hooks.json exists (gitignored, generated from default)
if [ ! -f "$PLUGIN_DIR/hooks/hooks.json" ]; then
  cp "$PLUGIN_DIR/hooks/hooks.default.json" "$PLUGIN_DIR/hooks/hooks.json"
fi

echo ""
echo "Claude Gateway plugin installed at: $PLUGIN_DIR"
echo ""
echo "Make sure these environment variables are set in your shell profile:"
echo "  export ANTHROPIC_AUTH_TOKEN=<your-api-key>"
echo "  export ANTHROPIC_BASE_URL=<your-gateway-url>"
echo ""
echo "Restart Claude Code to activate the plugin."
