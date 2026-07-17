#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

: "${SECRET_ID:?Run scripts/04-create-secret.sh first, or export SECRET_ID}"
: "${SERVICE_ID:?Run scripts/05-import-base-service.sh first, or export SERVICE_ID}"

CONFIG_ID="$(
  reshapr config create "github velocity benchmark base"     --serviceId "$SERVICE_ID"     --backendEndpoint "https://api.github.com"     --backendSecret "$SECRET_ID"     --output json   | tee "$WORKDIR/config-base.json"   | jq -r '.id // .configurationPlan.id'
)"

reshapr expo create   --configuration "$CONFIG_ID"   --gateway-group "1"   --output json | tee "$WORKDIR/expo-base.json"

{
  printf 'export SERVICE_ID=%q
' "$SERVICE_ID"
  printf 'export CONFIG_ID=%q
' "$CONFIG_ID"
  printf 'export RESHAPR_MCP_URL=%q
' "$RESHAPR_MCP_URL"
} > "$WORKDIR/base-service.env"

printf 'reShapr MCP URL: %s
' "$RESHAPR_MCP_URL"
