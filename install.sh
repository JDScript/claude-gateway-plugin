#!/bin/sh
set -e

echo "Claude Gateway Plugin Installation"
echo "===================================="
echo ""
echo "Run these commands in Claude Code:"
echo ""
echo "  /plugin marketplace add JDScript/claude-code-marketplace"
echo "  /plugin install claude-gateway"
echo ""
echo "Then set these environment variables in your shell profile:"
echo ""
echo "  export ANTHROPIC_AUTH_TOKEN=<your-api-key>"
echo "  export ANTHROPIC_BASE_URL=<your-gateway-url>/api"
echo ""
echo "Restart Claude Code to activate the plugin."
