#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

GATEWAY_CONTAINER="${GATEWAY_CONTAINER:-reshapr-gateway-01}"
GATEWAY_ENV="$(docker inspect "$GATEWAY_CONTAINER" --format '{{range .Config.Env}}{{println .}}{{end}}')"

missing=0
for var in \
  QUARKUS_GRPC_CLIENTS__EXPOSITION_DISCOVERY__MAX_INBOUND_MESSAGE_SIZE \
  QUARKUS_GRPC_CLIENTS__EXPOSITION_DISCOVERY__FLOW_CONTROL_WINDOW \
  RESHAPR_GATEWAY_SCRIPTING_MAX_TOOL_CALLS \
  RESHAPR_GATEWAY_BACKEND_HTTP_DEFAULT_TIMEOUT; do
  if line="$(printf '%s\n' "$GATEWAY_ENV" | grep -E "^${var}=")"; then
    echo "$line"
  else
    echo "MISSING on $GATEWAY_CONTAINER: $var (see artifacts/gateway-env.example)" >&2
    missing=1
  fi
done

exit "$missing"
