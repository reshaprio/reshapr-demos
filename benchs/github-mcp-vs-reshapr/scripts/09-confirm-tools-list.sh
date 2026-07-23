#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

CHECK_DIR="$WORKDIR/check-tools"
mkdir -p "$CHECK_DIR"

printf '%s\n' "$GITHUB_EXPECTED_MCP_TOOLS_JSON" \
  | jq -r '.[]' \
  | sort -u \
  > "$CHECK_DIR/expected-tools.txt"

check_tool_set() {
  local label="$1"
  local mcp_url="$2"
  local session_id
  local response_json="$CHECK_DIR/$label-tools.json"

  curl --fail-with-body -sS \
    -X POST "$mcp_url" \
    -H "Accept: application/json, text/event-stream" \
    -H "Content-Type: application/json" \
    --data '{
      "jsonrpc": "2.0",
      "id": 1,
      "method": "initialize",
      "params": {
        "protocolVersion": "2025-06-18",
        "capabilities": {},
        "clientInfo": {
          "name": "curl-check",
          "version": "1.0.0"
        }
      }
    }' \
    -D "$CHECK_DIR/$label-init.headers" \
    -o "$CHECK_DIR/$label-init.body"

  session_id="$(
    awk 'tolower($0) ~ /^mcp-session-id:/ { sub(/^[^:]+:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' \
      "$CHECK_DIR/$label-init.headers"
  )"
  : "${session_id:?MCP initialize response did not include a session ID for $label}"

  curl --fail-with-body -sS \
    -X POST "$mcp_url" \
    -H "Accept: application/json, text/event-stream" \
    -H "Content-Type: application/json" \
    -H "MCP-Protocol-Version: 2025-06-18" \
    -H "Mcp-Session-Id: $session_id" \
    --data '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' \
    -o /dev/null

  curl --fail-with-body -sS \
    -X POST "$mcp_url" \
    -H "Accept: application/json, text/event-stream" \
    -H "Content-Type: application/json" \
    -H "MCP-Protocol-Version: 2025-06-18" \
    -H "Mcp-Session-Id: $session_id" \
    --data '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    -o "$CHECK_DIR/$label-tools.body"

  if grep -q '^data:' "$CHECK_DIR/$label-tools.body"; then
    sed -n 's/^data:[[:space:]]*//p' "$CHECK_DIR/$label-tools.body" > "$response_json"
  else
    cp "$CHECK_DIR/$label-tools.body" "$response_json"
  fi

  jq -r '.result.tools[].name' "$response_json" \
    | sort -u \
    > "$CHECK_DIR/$label-actual-tools.txt"

  if ! diff -u "$CHECK_DIR/expected-tools.txt" "$CHECK_DIR/$label-actual-tools.txt"; then
    printf 'Unexpected MCP tool set for %s.\n' "$label" >&2
    return 1
  fi

  printf '%s: verified %s required MCP tools\n' \
    "$label" \
    "$(wc -l < "$CHECK_DIR/$label-actual-tools.txt" | tr -d ' ')"
}

check_tool_set "base" "$RESHAPR_MCP_URL"
check_tool_set "filter-json" "$RESHAPR_MCP_URL_FILTER_JSON"
check_tool_set "filter-toon" "$RESHAPR_MCP_URL_FILTER_TOON"
