#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

docker inspect reshapr-gateway-01   --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -E 'EXPOSITION_DISCOVERY|SCRIPTING_MAX_TOOL_CALLS'
