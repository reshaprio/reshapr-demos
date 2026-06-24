#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

KEYCLOAK_CONTAINER="${RESHAPR_KEYCLOAK_CONTAINER:-reshapr-keycloak-dev}"
KEYCLOAK_HOST_PORT="${KEYCLOAK_HOST_PORT:-8888}"
KEYCLOAK_REALM_URL="http://localhost:${KEYCLOAK_HOST_PORT}/realms/3rdparty"
KEYCLOAK_LOG_DIR="${TMPDIR:-/tmp}"
KEYCLOAK_LOG="${KEYCLOAK_LOG_DIR%/}/reshapr-demo09-keycloak.log"
KEYCLOAK_WAIT_SECONDS="${RESHAPR_KEYCLOAK_WAIT_SECONDS:-180}"
RESHAPR_HEALTH_URL="${RESHAPR_URL%/}/q/health/ready"

require_reshapr() {
  if ! command -v reshapr >/dev/null 2>&1; then
    echo "reShapr CLI is not installed." >&2
    echo "Run the prerequisite demo first:" >&2
    echo "  ./demos/00-install-cli/demo.sh" >&2
    exit 1
  fi

  if ! curl -fsS "${RESHAPR_HEALTH_URL}" >/dev/null 2>&1; then
    echo "reShapr is not reachable at ${RESHAPR_URL}." >&2
    echo "Start the local stack first, then rerun this demo." >&2
    echo "If you missed the prerequisites, run:" >&2
    echo "  ./demos/00-install-cli/demo.sh" >&2
    echo "  ./demos/01-run-local/demo.sh" >&2
    exit 1
  fi
}

keycloak_container_state() {
  docker inspect -f '{{.State.Status}}' "${KEYCLOAK_CONTAINER}" 2>/dev/null || true
}

keycloak_container_health() {
  docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${KEYCLOAK_CONTAINER}" 2>/dev/null || true
}

print_keycloak_log_tail() {
  echo "Startup log: ${KEYCLOAK_LOG}" >&2
  tail -50 "${KEYCLOAK_LOG}" >&2 || true
}

wait_for_keycloak() {
  local deadline=$((SECONDS + KEYCLOAK_WAIT_SECONDS))
  local state=""
  local health=""

  echo "Waiting for Keycloak Docker container and realm readiness..."
  while (( SECONDS < deadline )); do
    state="$(keycloak_container_state)"
    health="$(keycloak_container_health)"

    if [[ "${state}" == "exited" || "${state}" == "dead" ]]; then
      echo "Keycloak container ${KEYCLOAK_CONTAINER} stopped before becoming ready." >&2
      print_keycloak_log_tail
      exit 1
    fi

    if [[ "${state}" == "running" && ( "${health}" == "healthy" || "${health}" == "running" ) ]] && curl -fsS "${KEYCLOAK_REALM_URL}" >/dev/null 2>&1; then
      echo ""
      echo "Keycloak Docker container is ready (${health}) and realm 3rdparty is reachable."
      return 0
    fi

    if ! jobs -pr | grep -qx "${KEYCLOAK_START_PID}"; then
      echo ""
      echo "Keycloak startup script exited before readiness checks passed." >&2
      print_keycloak_log_tail
      exit 1
    fi

    printf '.'
    sleep 2
  done

  echo ""
  echo "Timed out waiting for Keycloak after ${KEYCLOAK_WAIT_SECONDS}s." >&2
  echo "Container state: ${state:-not-created}; health: ${health:-unknown}" >&2
  print_keycloak_log_tail
  exit 1
}

require_keycloak_ready() {
  local state
  local health

  state="$(keycloak_container_state)"
  health="$(keycloak_container_health)"

  if [[ "${state}" != "running" || ( "${health}" != "healthy" && "${health}" != "running" ) ]] || ! curl -fsS "${KEYCLOAK_REALM_URL}" >/dev/null 2>&1; then
    echo "Keycloak is not ready at ${KEYCLOAK_REALM_URL}." >&2
    echo "Container state: ${state:-not-created}; health: ${health:-unknown}" >&2
    print_keycloak_log_tail
    exit 1
  fi
}

require_reshapr

clear

p "Demo #9 Open-Meteo OpenAPI with Keycloak OAuth2 elicitation"
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
p "Start Keycloak locally for the OAuth2 authorization flow."
p "The helper imports realm 3rdparty, configures local-dev users, and leaves the Docker container running."
echo
p "RESHAPR_KEYCLOAK_FOLLOW_LOGS=false ./demos/09-open-meteo-openapi-keycloak-elicitation/start-keycloak-docker.sh > ${KEYCLOAK_LOG} 2>&1 &"
RESHAPR_KEYCLOAK_FOLLOW_LOGS=false "${SCRIPT_DIR}/start-keycloak-docker.sh" >"${KEYCLOAK_LOG}" 2>&1 &
KEYCLOAK_START_PID=$!

wait_for_keycloak
echo "Waiting for the Keycloak setup script to finish local realm configuration..."
if ! builtin wait "${KEYCLOAK_START_PID}"; then
  echo "Keycloak startup failed. Last log lines:" >&2
  tail -50 "${KEYCLOAK_LOG}" >&2 || true
  exit 1
fi

require_keycloak_ready
echo "Keycloak is ready at ${KEYCLOAK_REALM_URL}"
echo
p "Create an OAuth2 elicitation secret for the Open-Meteo backend."
p "The browser authorization endpoint uses localhost, while the backend token endpoint uses host.docker.internal from reShapr containers."
echo
p "reshapr secret create-elicitation open-meteo-auth --oauth2ClientID reshapr-ctrl --oauth2AuthorizationEndpoint http://localhost:8888/realms/3rdparty/protocol/openid-connect/auth --oauth2TokenEndpoint http://host.docker.internal:8888/realms/3rdparty/protocol/openid-connect/token"
OPEN_METEO_AUTH_SECRET_OUTPUT="$(reshapr secret create-elicitation open-meteo-auth --oauth2ClientID reshapr-ctrl --oauth2AuthorizationEndpoint http://localhost:8888/realms/3rdparty/protocol/openid-connect/auth --oauth2TokenEndpoint http://host.docker.internal:8888/realms/3rdparty/protocol/openid-connect/token)"
printf "%s\n" "${OPEN_METEO_AUTH_SECRET_OUTPUT}"
OPEN_METEO_AUTH_SECRET_ID="$(printf "%s\n" "${OPEN_METEO_AUTH_SECRET_OUTPUT}" | sed -nE 's/.*ID: ([[:alnum:]_-]+).*/\1/p' | tail -n 1)"

if [[ -z "${OPEN_METEO_AUTH_SECRET_ID}" ]]; then
  echo "Could not find the generated elicitation secret ID in the create command output." >&2
  exit 1
fi

echo
p "Import the Open-Meteo OpenAPI spec and attach the generated backend secret."
echo
pei "reshapr import -u https://raw.githubusercontent.com/open-meteo/open-meteo/refs/heads/main/openapi/forecast.yml --backendEndpoint https://api.open-meteo.com --backendSecret ${OPEN_METEO_AUTH_SECRET_ID}"
echo
p "Now Open-Meteo is exposed through reShapr with an OAuth2 elicitation backend secret."
echo
pei "reshapr secret list"
pei "reshapr service list"
echo
p "Let's check using your MCP client app and demonstrate the OAuth2 elicitation-based token secret in action 🎉"
echo ""
echo "Keycloak info:"
echo "  Admin console: http://localhost:${KEYCLOAK_HOST_PORT}/admin"
echo "    Login realm: master (default) - user: admin / password: admin"
echo "    Then switch realm (top-left) to '3rdparty' -> Users -> Create user"
echo "  OAuth2 elicitation login: user laurent / password laurent"
echo "    Use these credentials when Keycloak asks you to authorize the Open-Meteo backend secret."
echo ""
echo "  PS: Stop Keycloak when you are done -> docker stop ${KEYCLOAK_CONTAINER}"
echo ""
