#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

: "${GITHUB_TOKEN:?export GITHUB_TOKEN first}"

OWNER="${OWNER:-microsoft}"
REPO="${REPO:-vscode}"
PR_COUNT="${PR_COUNT:-10}"
REVIEW_COUNT="${REVIEW_COUNT:-5}"
FILE_COUNT="${FILE_COUNT:-10}"
OFFICIAL_MCP_URL="${OFFICIAL_MCP_URL:-https://api.githubcopilot.com/mcp/x/pull_requests/readonly}"
RESHAPR_MCP_URL="${RESHAPR_MCP_URL:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API/1.1.4}"
RESHAPR_MCP_URL_FILTER_JSON="${RESHAPR_MCP_URL_FILTER_JSON:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+JSON/1.1.4}"
RESHAPR_MCP_URL_FILTER_TOON="${RESHAPR_MCP_URL_FILTER_TOON:-http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+TOON/1.1.4}"
WORKDIR="${WORKDIR:-/tmp/reshapr-github-mcp-benchmark}"
MCP_PROTOCOL_VERSION="2025-06-18"

mkdir -p "$WORKDIR/official" "$WORKDIR/reshapr" "$WORKDIR/reshapr-filter-json" "$WORKDIR/reshapr-filter-toon"
METRICS="$WORKDIR/curl-metrics.tsv"
: > "$METRICS"

mcp_post() {
  local side="$1"
  local phase="$2"
  local url="$3"
  local payload="$4"
  local body_file="$5"
  local header_file="$6"
  shift 6

  local stats
  stats="$(
    curl -sS --fail-with-body \
      --retry 3 \
      --retry-delay 2 \
      --retry-all-errors \
      -D "$header_file" \
      -o "$body_file" \
      -w "%{time_total}\t%{size_download}" \
      -X POST "$url" \
      -H "Accept: application/json, text/event-stream" \
      -H "Content-Type: application/json" \
      "$@" \
      --data "$payload"
  )"

  printf "%s\t%s\t%s\n" "$side" "$phase" "$stats" >> "$METRICS"
}

session_id_from_headers() {
  awk 'tolower($0) ~ /^mcp-session-id:/ { sub(/^[^:]+:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' "$1"
}

jsonrpc_message() {
  local body_file="$1"
  if grep -q '^data:' "$body_file"; then
    sed -n 's/^data:[[:space:]]*//p' "$body_file" \
    | jq -sc 'map(select(.id != null)) | .[-1]'
  else
    jq '.' "$body_file"
  fi
}

tool_payload() {
  local body_file="$1"
  jsonrpc_message "$body_file" \
  | jq -r '
      .result
      | if has("structuredContent") then (.structuredContent | @json)
        elif has("structured_content") then (.structured_content | @json)
        elif has("content") then ([.content[]? | select(.type == "text") | .text] | join("\n"))
        else @json
        end
    '
}

extract_pr_numbers() {
  local payload_file="$1"
  local out_file="$2"
  local all_file="${out_file}.all"

  if jq -e '.' "$payload_file" >/dev/null 2>&1; then
    jq -r '.. | objects | (.number? // .pullNumber? // .pull_request_number? // empty)' "$payload_file" \
      > "$all_file"
  else
    grep -Eo '#[0-9]+' "$payload_file" | tr -d '#' > "$all_file" || true
  fi

  awk 'NF && !seen[$0]++' "$all_file" | head -n "$PR_COUNT" > "$out_file"
}

metric_value() {
  local side="$1"
  local field="$2"
  case "$field" in
    tool_calls)
      awk -F '\t' -v side="$side" '$1 == side && $2 ~ /^tool:/ { n++ } END { print n + 0 }' "$METRICS"
      ;;
    roundtrips)
      awk -F '\t' -v side="$side" '$1 == side { n++ } END { print n + 0 }' "$METRICS"
      ;;
    latency_ms)
      awk -F '\t' -v side="$side" '$1 == side && $2 ~ /^tool:/ { sum += $3 * 1000 } END { printf "%.0f", sum }' "$METRICS"
      ;;
    bytes)
      awk -F '\t' -v side="$side" '$1 == side && $2 ~ /^tool:/ { sum += $4 } END { printf "%.0f", sum }' "$METRICS"
      ;;
  esac
}

print_summary_row() {
  local side="$1"
  local label="$2"
  local tool_calls roundtrips latency_ms bytes tokens
  tool_calls="$(metric_value "$side" tool_calls)"
  roundtrips="$(metric_value "$side" roundtrips)"
  latency_ms="$(metric_value "$side" latency_ms)"
  bytes="$(metric_value "$side" bytes)"
  tokens=$(( (bytes + 3) / 4 ))

  printf "| %s | %s | %s | %s | %s | %s |\n" "$label" "$tool_calls" "$roundtrips" "$latency_ms" "$bytes" "$tokens"
}

print_reduction_row() {
  local label="$1"
  local field="$2"
  local official reshapr reduction ratio
  official="$(metric_value official "$field")"
  reshapr="$(metric_value reshapr "$field")"
  reduction="$(awk -v a="$official" -v b="$reshapr" 'BEGIN { if (a == 0) print "n/a"; else printf "%.1f%%", (1 - (b / a)) * 100 }')"
  ratio="$(awk -v a="$official" -v b="$reshapr" 'BEGIN { if (b == 0) print "n/a"; else printf "%.1fx", a / b }')"
  printf "| %s | %s | %s | %s | %s |\n" "$label" "$official" "$reshapr" "$reduction" "$ratio"
}

official_base_headers=(
  -H "Authorization: Bearer $GITHUB_TOKEN"
  -H "X-MCP-Readonly: true"
  -H "X-MCP-Toolsets: pull_requests"
)

init_payload="$(
  jq -nc --arg version "$MCP_PROTOCOL_VERSION" '{
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
      protocolVersion: $version,
      capabilities: {},
      clientInfo: { name: "curl-github-mcp-benchmark", version: "1.0.0" }
    }
  }'
)"

mcp_post official protocol:initialize "$OFFICIAL_MCP_URL" "$init_payload" \
  "$WORKDIR/official/01-initialize.body" "$WORKDIR/official/01-initialize.headers" \
  "${official_base_headers[@]}"

OFFICIAL_SESSION_ID="$(session_id_from_headers "$WORKDIR/official/01-initialize.headers")"
test -n "$OFFICIAL_SESSION_ID"

official_session_headers=(
  "${official_base_headers[@]}"
  -H "MCP-Protocol-Version: $MCP_PROTOCOL_VERSION"
  -H "Mcp-Session-Id: $OFFICIAL_SESSION_ID"
)

mcp_post official protocol:initialized "$OFFICIAL_MCP_URL" \
  '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' \
  "$WORKDIR/official/02-initialized.body" "$WORKDIR/official/02-initialized.headers" \
  "${official_session_headers[@]}"

mcp_post official protocol:tools_list "$OFFICIAL_MCP_URL" \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  "$WORKDIR/official/03-tools-list.body" "$WORKDIR/official/03-tools-list.headers" \
  "${official_session_headers[@]}"

list_payload="$(
  jq -nc \
    --arg owner "$OWNER" \
    --arg repo "$REPO" \
    --argjson perPage "$PR_COUNT" \
    '{
      jsonrpc: "2.0",
      id: 3,
      method: "tools/call",
      params: {
        name: "list_pull_requests",
        arguments: {
          owner: $owner,
          repo: $repo,
          state: "all",
          sort: "updated",
          direction: "desc",
          perPage: $perPage
        }
      }
    }'
)"

mcp_post official tool:list_pull_requests "$OFFICIAL_MCP_URL" "$list_payload" \
  "$WORKDIR/official/04-list-pulls.body" "$WORKDIR/official/04-list-pulls.headers" \
  "${official_session_headers[@]}"

tool_payload "$WORKDIR/official/04-list-pulls.body" > "$WORKDIR/official/list-pulls.payload"
extract_pr_numbers "$WORKDIR/official/list-pulls.payload" "$WORKDIR/official/pr-numbers.txt"

FOUND_PR_COUNT="$(wc -l < "$WORKDIR/official/pr-numbers.txt" | tr -d ' ')"
if [ "$FOUND_PR_COUNT" -lt "$PR_COUNT" ]; then
  echo "Expected $PR_COUNT pull request numbers, got $FOUND_PR_COUNT" >&2
  exit 1
fi

request_id=4
while read -r pull_number; do
  for method in get get_reviews get_files; do
    if [ "$method" = "get" ]; then
      args="$(
        jq -nc \
          --arg owner "$OWNER" \
          --arg repo "$REPO" \
          --argjson pullNumber "$pull_number" \
          --arg method "$method" \
          '{ method: $method, owner: $owner, repo: $repo, pullNumber: $pullNumber }'
      )"
    elif [ "$method" = "get_reviews" ]; then
      args="$(
        jq -nc \
          --arg owner "$OWNER" \
          --arg repo "$REPO" \
          --argjson pullNumber "$pull_number" \
          --argjson perPage "$REVIEW_COUNT" \
          --arg method "$method" \
          '{ method: $method, owner: $owner, repo: $repo, pullNumber: $pullNumber, perPage: $perPage }'
      )"
    else
      args="$(
        jq -nc \
          --arg owner "$OWNER" \
          --arg repo "$REPO" \
          --argjson pullNumber "$pull_number" \
          --argjson perPage "$FILE_COUNT" \
          --arg method "$method" \
          '{ method: $method, owner: $owner, repo: $repo, pullNumber: $pullNumber, perPage: $perPage }'
      )"
    fi

    call_payload="$(
      jq -nc \
        --argjson id "$request_id" \
        --argjson args "$args" \
        '{
          jsonrpc: "2.0",
          id: $id,
          method: "tools/call",
          params: {
            name: "pull_request_read",
            arguments: $args
          }
        }'
    )"

    mcp_post official "tool:pull_${pull_number}_${method}" "$OFFICIAL_MCP_URL" "$call_payload" \
      "$WORKDIR/official/${request_id}-pull-${pull_number}-${method}.body" \
      "$WORKDIR/official/${request_id}-pull-${pull_number}-${method}.headers" \
      "${official_session_headers[@]}"

    request_id=$((request_id + 1))
  done
done < "$WORKDIR/official/pr-numbers.txt"

run_reshapr_custom() {
  local side="$1"
  local url="$2"
  local dir="$3"

  mcp_post "$side" protocol:initialize "$url" "$init_payload" \
    "$dir/01-initialize.body" "$dir/01-initialize.headers"

  local session_id
  session_id="$(session_id_from_headers "$dir/01-initialize.headers")"
  test -n "$session_id"

  local session_headers=(
    -H "MCP-Protocol-Version: $MCP_PROTOCOL_VERSION"
    -H "Mcp-Session-Id: $session_id"
  )

  mcp_post "$side" protocol:initialized "$url" \
    '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' \
    "$dir/02-initialized.body" "$dir/02-initialized.headers" \
    "${session_headers[@]}"

  mcp_post "$side" protocol:tools_list "$url" \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    "$dir/03-tools-list.body" "$dir/03-tools-list.headers" \
    "${session_headers[@]}"

  local velocity_payload
  velocity_payload="$(
    jq -nc \
      --arg owner "$OWNER" \
      --arg name "$REPO" \
      --argjson prCount "$PR_COUNT" \
      --argjson reviewCount "$REVIEW_COUNT" \
      --argjson fileCount "$FILE_COUNT" \
      '{
        jsonrpc: "2.0",
        id: 3,
        method: "tools/call",
        params: {
          name: "get_repo_velocity_metrics",
          arguments: {
            owner: $owner,
            name: $name,
            prCount: $prCount,
            reviewCount: $reviewCount,
            fileCount: $fileCount
          }
        }
      }'
  )"

  mcp_post "$side" tool:get_repo_velocity_metrics "$url" "$velocity_payload" \
    "$dir/04-velocity.body" "$dir/04-velocity.headers" \
    "${session_headers[@]}"

  tool_payload "$dir/04-velocity.body" > "$dir/velocity.payload"
  if [ "$side" != "reshapr-filter-toon" ]; then
    jq -e --argjson expected "$PR_COUNT" '.metrics | length >= $expected' "$dir/velocity.payload" >/dev/null
  else
    grep -q 'metrics' "$dir/velocity.payload"
  fi
}

run_reshapr_custom reshapr "$RESHAPR_MCP_URL" "$WORKDIR/reshapr"
run_reshapr_custom reshapr-filter-json "$RESHAPR_MCP_URL_FILTER_JSON" "$WORKDIR/reshapr-filter-json"
run_reshapr_custom reshapr-filter-toon "$RESHAPR_MCP_URL_FILTER_TOON" "$WORKDIR/reshapr-filter-toon"

echo
echo "Raw curl metrics:"
echo "side phase seconds response_bytes"
column -t -s $'\t' "$METRICS"

echo
echo "Benchmark summary:"
echo "| MCP path | Agent tool calls | MCP HTTP roundtrips | Tool-call latency ms | Tool-call response bytes | Estimated tokens |"
echo "| --- | ---: | ---: | ---: | ---: | ---: |"
print_summary_row official "Official GitHub MCP pull-request tools"
print_summary_row reshapr "reShapr MCP custom action"
print_summary_row reshapr-filter-json "reShapr MCP custom action + output filter"
print_summary_row reshapr-filter-toon "reShapr MCP custom action + output filter + TOON"

echo
echo "Reduction from official GitHub MCP to reShapr:"
echo "| Metric | Official GitHub MCP | reShapr MCP | Reduction | Ratio |"
echo "| --- | ---: | ---: | ---: | ---: |"
print_reduction_row "Agent tool calls" tool_calls
print_reduction_row "MCP HTTP roundtrips" roundtrips
print_reduction_row "Tool-call latency ms" latency_ms
print_reduction_row "Tool-call response bytes" bytes
