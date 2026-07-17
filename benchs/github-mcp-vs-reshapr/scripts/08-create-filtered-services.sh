#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

: "${SECRET_ID:?Run scripts/04-create-secret.sh first, or export SECRET_ID}"

reshapr import   --url "$GITHUB_OPENAPI_URL"   --serviceName "$GITHUB_SERVICE_FILTER_JSON_NAME"   --serviceVersion "$GITHUB_SERVICE_VERSION"   --output json | tee "$WORKDIR/import-filter-json.json"

reshapr import   --url "$GITHUB_OPENAPI_URL"   --serviceName "$GITHUB_SERVICE_FILTER_TOON_NAME"   --serviceVersion "$GITHUB_SERVICE_VERSION"   --output json | tee "$WORKDIR/import-filter-toon.json"

reshapr attach --file "$BENCH_DIR/artifacts/github-velocity-custom-tools-filter-json.yaml" --output json
reshapr attach --file "$BENCH_DIR/artifacts/filter-json.yaml" --output json

FILTER_JSON_SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-filter-json.json")"
FILTER_JSON_CONFIG_ID="$(
  reshapr config create "github velocity benchmark filter json"     --serviceId "$FILTER_JSON_SERVICE_ID"     --backendEndpoint "https://api.github.com"     --backendSecret "$SECRET_ID"     --output json   | tee "$WORKDIR/config-filter-json.json"   | jq -r '.id // .configurationPlan.id'
)"
reshapr expo create --configuration "$FILTER_JSON_CONFIG_ID" --gateway-group "1" --output json

reshapr attach --file "$BENCH_DIR/artifacts/github-velocity-custom-tools-filter-toon.yaml" --output json
reshapr attach --file "$BENCH_DIR/artifacts/filter-toon.yaml" --output json

FILTER_TOON_SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-filter-toon.json")"
FILTER_TOON_CONFIG_ID="$(
  reshapr config create "github velocity benchmark filter toon"     --serviceId "$FILTER_TOON_SERVICE_ID"     --backendEndpoint "https://api.github.com"     --backendSecret "$SECRET_ID"     --output json   | tee "$WORKDIR/config-filter-toon.json"   | jq -r '.id // .configurationPlan.id'
)"
reshapr expo create --configuration "$FILTER_TOON_CONFIG_ID" --gateway-group "1" --output json

{
  printf 'export FILTER_JSON_SERVICE_ID=%q
' "$FILTER_JSON_SERVICE_ID"
  printf 'export FILTER_JSON_CONFIG_ID=%q
' "$FILTER_JSON_CONFIG_ID"
  printf 'export FILTER_TOON_SERVICE_ID=%q
' "$FILTER_TOON_SERVICE_ID"
  printf 'export FILTER_TOON_CONFIG_ID=%q
' "$FILTER_TOON_CONFIG_ID"
  printf 'export RESHAPR_MCP_URL_FILTER_JSON=%q
' "$RESHAPR_MCP_URL_FILTER_JSON"
  printf 'export RESHAPR_MCP_URL_FILTER_TOON=%q
' "$RESHAPR_MCP_URL_FILTER_TOON"
} > "$WORKDIR/filtered-services.env"

printf 'JSON filter MCP URL: %s
' "$RESHAPR_MCP_URL_FILTER_JSON"
printf 'TOON filter MCP URL: %s
' "$RESHAPR_MCP_URL_FILTER_TOON"
