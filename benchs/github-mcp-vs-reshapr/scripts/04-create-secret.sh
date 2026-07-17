#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

: "${GITHUB_TOKEN:?export GITHUB_TOKEN first}"

SECRET_NAME="github-rest-backend-$(date +%Y%m%d%H%M%S)"

SECRET_ID="$(
  reshapr secret create "$SECRET_NAME"     --backend     --token "$GITHUB_TOKEN"     --description "Read-only GitHub token for the GitHub MCP benchmark"     --output json   | jq -r '.id'
)"

printf 'export SECRET_ID=%q
' "$SECRET_ID" > "$WORKDIR/secret.env"
echo "$SECRET_ID"
