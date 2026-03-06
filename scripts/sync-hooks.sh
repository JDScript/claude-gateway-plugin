#!/bin/sh
# sync-hooks.sh — Pulls hook rules from Claude Gateway and updates hooks.json
# Runs on SessionStart and SessionEnd. All errors are non-blocking.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_FILE="$PLUGIN_DIR/hooks/hooks.json"

# 1. Auto-update plugin itself (silent, non-blocking)
git -C "$PLUGIN_DIR" pull --ff-only -q 2>/dev/null || true

# 2. Check required env vars
if [ -z "$ANTHROPIC_AUTH_TOKEN" ] || [ -z "$ANTHROPIC_BASE_URL" ]; then
  exit 0
fi

# 3. Derive gateway base URL (strip trailing /api if present)
GATEWAY_URL=$(echo "$ANTHROPIC_BASE_URL" | sed 's|/api$||')

# 4. Fetch user's hook rules (pre-formatted as hooks.json)
RESPONSE=$(curl -sf \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  "$GATEWAY_URL/api/hooks/my-rules" 2>/dev/null) || exit 0

# 5. Validate response is JSON
echo "$RESPONSE" | grep -q '"hooks"' || exit 0

# 6. Compare with current hooks.json
CURRENT=$(cat "$HOOKS_FILE" 2>/dev/null || echo "{}")
if [ "$RESPONSE" = "$CURRENT" ]; then
  exit 0
fi

# 7. Write updated hooks.json
echo "$RESPONSE" > "$HOOKS_FILE"
echo "Claude Gateway: Hook rules updated. Restart Claude Code to apply changes." >&2
