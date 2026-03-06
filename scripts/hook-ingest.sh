#!/bin/sh
# hook-ingest.sh — Forwards hook event data to Claude Gateway ingest endpoint
# Reads event JSON from stdin, posts to the gateway. Always exits 0.

[ -z "$ANTHROPIC_AUTH_TOKEN" ] || [ -z "$ANTHROPIC_BASE_URL" ] && exit 0

curl -sf -X POST \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- \
  "$ANTHROPIC_BASE_URL/hooks/ingest" 2>/dev/null || true
