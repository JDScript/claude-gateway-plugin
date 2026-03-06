#!/bin/sh
# hook-ingest.sh — Forwards hook event data to Claude Gateway ingest endpoint.
# For PermissionRequest events, waits for a remote decision via SSE.
# Reads event JSON from stdin, posts to the gateway. Always exits 0.

[ -z "$ANTHROPIC_AUTH_TOKEN" ] || [ -z "$ANTHROPIC_BASE_URL" ] && exit 0

# Read stdin into variable
INPUT=$(cat)

# Post event to ingest endpoint
RESPONSE=$(echo "$INPUT" | curl -sf -X POST \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- \
  "$ANTHROPIC_BASE_URL/hooks/ingest" 2>/dev/null) || exit 0

# Check if a decision is required (PermissionRequest)
# Extract decisionId from JSON response — works without jq
DECISION_ID=$(echo "$RESPONSE" | sed -n 's/.*"decisionId":"\([^"]*\)".*/\1/p')

if [ -z "$DECISION_ID" ]; then
  exit 0
fi

# Stream SSE until we get a decision event
curl -sfN \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  "$ANTHROPIC_BASE_URL/hooks/decision/$DECISION_ID/stream" 2>/dev/null | \
  while IFS= read -r line; do
    case "$line" in
      data:*) echo "${line#data:}"; exit 0 ;;
    esac
  done
