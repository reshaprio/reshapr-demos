#!/usr/bin/env bash

if [ -n "${BASH_VERSION:-}" ]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  SCRIPT_PATH="${(%):-%x}"
else
  printf 'Unsupported shell: source this file from Bash or zsh.\n' >&2
  return 1 2>/dev/null || exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)" || {
  printf 'Unable to resolve the benchmark directory.\n' >&2
  return 1 2>/dev/null || exit 1
}
export BENCH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -n "${TOKEN:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
  export GITHUB_TOKEN="$TOKEN"
fi

export OWNER="${OWNER:-microsoft}"
export REPO="${REPO:-vscode}"
export PR_COUNT="${PR_COUNT:-10}"
export REVIEW_COUNT="${REVIEW_COUNT:-5}"
export FILE_COUNT="${FILE_COUNT:-10}"

export GITHUB_OPENAPI_URL="${GITHUB_OPENAPI_URL:-https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.yaml}"
export OFFICIAL_MCP_URL="${OFFICIAL_MCP_URL:-https://api.githubcopilot.com/mcp/x/pull_requests/readonly}"
export WORKDIR="${WORKDIR:-/tmp/reshapr-github-mcp-benchmark}"

export GITHUB_SERVICE_NAME="${GITHUB_SERVICE_NAME:-GitHub v3 REST API}"
export GITHUB_SERVICE_FILTER_JSON_NAME="${GITHUB_SERVICE_FILTER_JSON_NAME:-GitHub v3 REST API Filter JSON}"
export GITHUB_SERVICE_FILTER_TOON_NAME="${GITHUB_SERVICE_FILTER_TOON_NAME:-GitHub v3 REST API Filter TOON}"
export GITHUB_SERVICE_VERSION="${GITHUB_SERVICE_VERSION:-1.1.4}"
if [ -z "${GITHUB_INCLUDED_OPERATIONS_JSON:-}" ]; then
  export GITHUB_INCLUDED_OPERATIONS_JSON='["get_repo_velocity_metrics","GET /repos/{owner}/{repo}/pulls","GET /repos/{owner}/{repo}/pulls/{pull_number}","GET /repos/{owner}/{repo}/pulls/{pull_number}/reviews","GET /repos/{owner}/{repo}/pulls/{pull_number}/files"]'
fi
if [ -z "${GITHUB_EXPECTED_MCP_TOOLS_JSON:-}" ]; then
  export GITHUB_EXPECTED_MCP_TOOLS_JSON='["get_repo_velocity_metrics","get_repos_owner_repo_pulls","get_repos_owner_repo_pulls_pull_number","get_repos_owner_repo_pulls_pull_number_reviews","get_repos_owner_repo_pulls_pull_number_files"]'
fi

export RESHAPR_MCP_URL="${RESHAPR_MCP_URL:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API/1.1.4}"
export RESHAPR_MCP_URL_FILTER_JSON="${RESHAPR_MCP_URL_FILTER_JSON:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+JSON/1.1.4}"
export RESHAPR_MCP_URL_FILTER_TOON="${RESHAPR_MCP_URL_FILTER_TOON:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+TOON/1.1.4}"

mkdir -p "$WORKDIR"

for env_file in "$WORKDIR/secret.env" "$WORKDIR/base-service.env" "$WORKDIR/filtered-services.env"; do
  if [ -f "$env_file" ]; then
    # shellcheck source=/dev/null
    source "$env_file"
  fi
done

printf 'GitHub OpenAPI service: %s %s
' "$GITHUB_SERVICE_NAME" "$GITHUB_SERVICE_VERSION"
printf 'GitHub OpenAPI URL: %s
' "$GITHUB_OPENAPI_URL"
printf 'Benchmark workdir: %s
' "$WORKDIR"
