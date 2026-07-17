#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

CHECK_DIR="$WORKDIR/check-tools"
mkdir -p "$CHECK_DIR"

curl -sS   -X POST "$RESHAPR_MCP_URL"   -H "Accept: application/json, text/event-stream"   -H "Content-Type: application/json"   --data '{
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
  }'   -D "$CHECK_DIR/reshapr-init.headers"   -o "$CHECK_DIR/reshapr-init.body"

RESHAPR_SESSION_ID="$(
  awk 'tolower($0) ~ /^mcp-session-id:/ { sub(/^[^:]+:[[:space:]]*/, ""); sub(/$/, ""); print; exit }'     "$CHECK_DIR/reshapr-init.headers"
)"

curl -sS   -X POST "$RESHAPR_MCP_URL"   -H "Accept: application/json, text/event-stream"   -H "Content-Type: application/json"   -H "MCP-Protocol-Version: 2025-06-18"   -H "Mcp-Session-Id: $RESHAPR_SESSION_ID"   --data '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'   -o /dev/null

curl -sS   -X POST "$RESHAPR_MCP_URL"   -H "Accept: application/json, text/event-stream"   -H "Content-Type: application/json"   -H "MCP-Protocol-Version: 2025-06-18"   -H "Mcp-Session-Id: $RESHAPR_SESSION_ID"   --data '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'   -o "$CHECK_DIR/reshapr-tools.body"

if grep -q '^data:' "$CHECK_DIR/reshapr-tools.body"; then
  sed -n 's/^data:[[:space:]]*//p' "$CHECK_DIR/reshapr-tools.body"   | jq -r '.result.tools[].name'
else
  jq -r '.result.tools[].name' "$CHECK_DIR/reshapr-tools.body"
fi
