#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

reshapr import   --url "$GITHUB_OPENAPI_URL"   --serviceName "$GITHUB_SERVICE_NAME"   --serviceVersion "$GITHUB_SERVICE_VERSION"   --output json | tee "$WORKDIR/import-base.json"

SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-base.json")"
printf 'export SERVICE_ID=%q
' "$SERVICE_ID" > "$WORKDIR/base-service.env"
echo "$SERVICE_ID"
