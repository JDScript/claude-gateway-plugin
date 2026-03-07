#!/bin/sh
# sync-hooks.sh — Pulls hook rules from Claude Gateway and writes hooks.json.
# Runs on SessionStart and SessionEnd. Always exits 0.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_FILE="$PLUGIN_DIR/hooks/hooks.json"

# 1. Check required env vars
[ -z "$ANTHROPIC_AUTH_TOKEN" ] && exit 0
[ -z "$ANTHROPIC_BASE_URL" ] && exit 0

# 2. Derive gateway base URL (strip trailing /api if present)
GATEWAY_URL=$(echo "$ANTHROPIC_BASE_URL" | sed 's|/api$||')

# 3. Fetch user's hook rules
RESPONSE=$(curl -sf \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  "$GATEWAY_URL/api/hooks/my-rules" 2>/dev/null) || exit 0

# 4. Validate response is JSON
echo "$RESPONSE" | grep -q '"hooks"' || exit 0

# 5. Skip write if nothing changed
CURRENT=$(cat "$HOOKS_FILE" 2>/dev/null || echo "")
[ "$RESPONSE" = "$CURRENT" ] && exit 0

# 6. Write updated hooks
echo "$RESPONSE" > "$HOOKS_FILE"
echo '{"systemMessage":"Claude Gateway: Hook rules updated. Restart Claude Code to apply."}'
