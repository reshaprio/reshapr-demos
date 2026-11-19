#!/usr/bin/env bash

RESHAPR_DEMOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export RESHAPR_DEMOS_ROOT

export RESHAPR_PASSWORD="${RESHAPR_PASSWORD:-password}"
export RESHAPR_URL="${RESHAPR_URL:-http://localhost:5555}"
export RESHAPR_MCP_URL="${RESHAPR_MCP_URL:-http://localhost:7777}"
export GITHUB_GRAPHQL_SERVICE_NAME="${GITHUB_GRAPHQL_SERVICE_NAME:-GitHub GraphQL}"
export GITHUB_GRAPHQL_SERVICE_VERSION="${GITHUB_GRAPHQL_SERVICE_VERSION:-20260410}"
export DEMO_STRICT="${DEMO_STRICT:-true}"

DEMO_MAGIC="${RESHAPR_DEMOS_ROOT}/tools/demo-magic/demo-magic.sh"
DEMO_MAGIC_OPTS="${DEMO_MAGIC_OPTS:--n}"

if [[ ! -f "${DEMO_MAGIC}" ]]; then
  echo "demo-magic.sh is missing at ${DEMO_MAGIC}" >&2
  exit 1
fi

if ! command -v pv >/dev/null 2>&1 && [[ " ${DEMO_MAGIC_OPTS} " != *" -d "* ]]; then
  DEMO_MAGIC_OPTS="${DEMO_MAGIC_OPTS} -d"
  echo "pv is not installed; running with simulated typing disabled (-d)." >&2
fi

cd "${RESHAPR_DEMOS_ROOT}" || exit 1

OPTIND=1
# shellcheck disable=SC1090,SC2086
. "${DEMO_MAGIC}" ${DEMO_MAGIC_OPTS}

# demo-magic's upstream run_cmd restores terminal settings after eval, but the
# final restore command masks failures. Preserve the command exit status so
# demos stop before printing success narration after a failed command.
run_cmd() {
  function handle_cancel() {
    printf ""
  }

  trap handle_cancel SIGINT
  stty -echoctl 2>/dev/null || true
  eval "$@"
  local status=$?
  stty echoctl 2>/dev/null || true
  trap - SIGINT
  return "${status}"
}

if [[ "${DEMO_STRICT}" == "true" ]]; then
  set -e -o pipefail
fi

show_file() {
  if command -v bat >/dev/null 2>&1; then
    bat "$@"
  else
    cat "$@"
  fi
}

require_reshapr_cli() {
  if ! command -v reshapr >/dev/null 2>&1; then
    echo "reShapr CLI is not installed." >&2
    echo "Run the prerequisite demo first:" >&2
    echo "  ./demos/00-install-cli/demo.sh" >&2
    exit 1
  fi
}

require_reshapr() {
  local health_url="${RESHAPR_URL%/}/q/health/ready"
  require_reshapr_cli

  if ! curl -fsS "${health_url}" >/dev/null 2>&1; then
    echo "reShapr is not reachable at ${RESHAPR_URL}." >&2
    echo "Start the local stack first, then rerun this demo." >&2
    echo "If you missed the prerequisites, run:" >&2
    echo "  ./demos/00-install-cli/demo.sh" >&2
    echo "  ./demos/01-run-local/demo.sh" >&2
    exit 1
  fi
}
