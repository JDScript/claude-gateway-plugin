#!/bin/sh
# hook-ingest.sh — Forwards hook event data to Claude Gateway ingest endpoint.
# For PermissionRequest events, waits for a remote decision via long polling.
# Reconnects automatically on 202 (still pending). Exits 0 on any terminal state
# so Claude Code can handle the result natively.

[ -z "$ANTHROPIC_AUTH_TOKEN" ] || [ -z "$ANTHROPIC_BASE_URL" ] && exit 0

# Post event directly from stdin — avoids echo/printf mangling \n in JSON strings
RESPONSE=$(curl -sf -X POST \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- \
  "$ANTHROPIC_BASE_URL/hooks/ingest" 2>/dev/null) || exit 0

# Check if a decision is required (PermissionRequest)
REQUEST_ID=$(printf '%s' "$RESPONSE" | sed -n 's/.*"requestId":"\([^"]*\)".*/\1/p')

if [ -z "$REQUEST_ID" ]; then
  exit 0
fi

# Wait for decision via long polling.
# Server holds connection up to 60s, returns:
#   200 — decision ready (print and exit)
#   202 — still pending (re-poll immediately)
#   408 — timed out (exit 0, Claude Code handles natively)
#   other — error (exit 0 clean)
while true; do
  TMPFILE=$(mktemp)
  HTTP=$(curl -s --max-time 65 \
    -o "$TMPFILE" \
    -w "%{http_code}" \
    -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
    "$ANTHROPIC_BASE_URL/hooks/decision/$REQUEST_ID" 2>/dev/null)
  case "$HTTP" in
    200) cat "$TMPFILE"; rm -f "$TMPFILE"; exit 0 ;;
    202) rm -f "$TMPFILE" ;;            # still pending, loop immediately
    *)   rm -f "$TMPFILE"; exit 0 ;;   # 408 timeout or error — exit clean
  esac
done
