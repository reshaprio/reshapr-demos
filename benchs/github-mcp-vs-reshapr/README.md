# reShapr vs GitHub's official MCP Server!

## 31 Tool Calls Become 1 Predictable Agent Action

This benchmark answers a practical agent question and serves as the real-world demonstration of the concepts introduced in our previous posts, [From Context Overload to Context Control](https://reshapr.io/blog/from-context-overload-to-context-control)! and [From API Sprawl to Agent Actions](https://reshapr.io/blog/from-api-sprawl-to-agent-actions). By providing a **fair comparison** between the official GitHub MCP tools and reShapr, we illustrate how these theoretical benefits translate into **measurable performance gains**.

> If an AI agent needs recent pull request velocity for `microsoft/vscode`, the public GitHub repository for Visual Studio Code, should it drive the official GitHub MCP pull-request tools directly, or should it call **one purpose-built reShapr MCP action**?

## Repository Layout

This directory is a portable benchmark package extracted from the blog post. The README keeps the commands inline for copy/paste, and the same commands/artifacts are also available as local files.

```text
benchs/
  README.md
  artifacts/
    gateway-env.example
    github-velocity-custom-tools.yaml
    github-velocity-custom-tools-filter-json.yaml
    github-velocity-custom-tools-filter-toon.yaml
    filter-json.yaml
    filter-toon.yaml
  payloads/
    reshapr-get-repo-velocity-metrics.json
    reshapr-source-backend-calls-example.json
  prompts/
    chatgpt-github-pr-velocity.txt
  scripts/
    00-env.sh
    01-start-reshapr.sh
    02-check-gateway-env.sh
    03-login.sh
    04-create-secret.sh
    05-import-base-service.sh
    06-attach-custom-tool.sh
    07-expose-base-service.sh
    08-create-filtered-services.sh
    09-confirm-tools-list.sh
    run-github-mcp-benchmark.sh
    show-results.sh
```

Recommended flow:

```bash
export GITHUB_TOKEN="REPLACE_WITH_YOUR_GITHUB_TOKEN"
source scripts/00-env.sh
scripts/01-start-reshapr.sh
scripts/02-check-gateway-env.sh
scripts/03-login.sh
scripts/04-create-secret.sh
scripts/05-import-base-service.sh
scripts/06-attach-custom-tool.sh
scripts/07-expose-base-service.sh
scripts/08-create-filtered-services.sh
scripts/09-confirm-tools-list.sh
scripts/run-github-mcp-benchmark.sh
scripts/show-results.sh
```

## The Use Case

The test is **intentionally narrow and reproducible**. The agent starts with a simple goal: understand recent pull request velocity in `microsoft/vscode`. To answer it properly, it needs the 10 most recently updated pull requests, the details for each pull request, up to 5 review touchpoints, and up to 10 changed file paths per pull request.

That is a realistic workflow for **release tracking**, engineering management, **review triage**, and **agentic codebase analysis**. It is also exactly the kind of workflow where generic tools create agent overhead: list the pull requests, then loop over each pull request to fetch details, reviews, and files.

The official GitHub MCP path exposes good primitive tools. reShapr turns the same API surface into **one higher-level MCP action**.

That matters beyond speed. reShapr makes repeated agent workflows **predictable, reliable, and reproducible**. The model can still reason and decide, but the workflow boundary becomes stable: **one named action, one input schema, one output shape, one measurable execution path**.

## The Result

Latest measured live run against `microsoft/vscode`, using the same 10 pull requests for the official MCP and reShapr custom-action comparison:

| Metric | Official GitHub MCP | reShapr MCP | Reduction |
| --- | ---: | ---: | ---: |
| Agent tool calls | 31 | **1** | **96.8% fewer** |
| MCP HTTP roundtrips | 34 | **4** | **88.2% fewer** |
| Tool-call latency | 28,081 ms | **2,082 ms** | **92.6% lower** |
| Response bytes read by the agent | 267,824 | **7,401** | **97.2% smaller** |
| Estimated token load (*) | 66,956 | **1,851** | **97.2% fewer** |


Then reShapr applies a **second, independent optimization** at the **output boundary**. The same custom action was called through two `ToolsOutputFilters` artifacts on a matched reShapr run: first with JSON retain/patch rules, then with the same filter plus `convertToToon: true`.

The official GitHub MCP baseline does not expose an equivalent output-filter artifact in this test, so the **fair comparison** is: official primitive workflow versus reShapr custom action, then reShapr custom action versus reShapr custom action with output filtering.

| reShapr variant | Agent tool calls | MCP HTTP roundtrips | Tool-call latency ms | Tool-call response bytes | Estimated tokens (*) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Custom action | 1 | 4 | 2,082 | 7,401 | 1,851 |
| Custom action + output filter | 1 | 4 | 1,755 | 7,090 | 1,773 |
| **Custom action + output filter + TOON** | **1** | **4** | **1,475** | **6,482** | **1,621** |


That is a smaller win than the **31-to-1 action design**, but it is still useful: another **12.4% response-byte reduction** from the custom action to filtered TOON output, on top of the main **97.2% reduction** versus the official GitHub MCP loop.

The key point is **fairness**: reShapr does not pretend GitHub has less data. The reShapr action still performs the source GitHub operations needed to produce the answer. The win is that the agent sees **one semantic tool call, one compact response, and one stable task-shaped contract**.

## Methodology

The most natural way to run this use case is through **ChatGPT or another MCP-capable conversational agent**. A user would normally ask for the **outcome**, not for the individual API calls:

File version: [prompts/chatgpt-github-pr-velocity.txt](prompts/chatgpt-github-pr-velocity.txt).

```text
Using the available GitHub MCP tools, analyze recent pull request velocity for the public repository microsoft/vscode.

Use the 10 most recently updated pull requests. For each pull request, collect the pull request details, up to 5 review touchpoints, and up to 10 changed file paths.

Return a compact summary with pull request id, title, creator, state, creation and merge timestamps, review touchpoints, and changed paths.
```

That is the typical agent experience: **one natural-language request becomes a multi-step MCP tool plan**. The model has to decide how to list pull requests, how to fan out over the selected pull requests, and how to gather the details, reviews, and changed files before it can synthesize an answer.

With reShapr, the conversational agent can call **one task-shaped action**:

Payload file: [payloads/reshapr-get-repo-velocity-metrics.json](payloads/reshapr-get-repo-velocity-metrics.json).

```json
{
  "name": "get_repo_velocity_metrics",
  "arguments": {
    "owner": "microsoft",
    "name": "vscode",
    "prCount": 10,
    "reviewCount": 5,
    "fileCount": 10
  }
}
```

For the benchmark, we did not want the measurement to depend on **model behavior**. Different models, prompts, retry policies, or agent runtimes can make slightly different planning choices. One run may call tools in a different order. Another may inspect extra fields, retry a tool call, or stop early after a transient error.

So the benchmark separates the **user experience** from the **measurement method**. The LLM prompt describes the real agent task. The curl-based benchmark measures the underlying MCP workflow directly. It sends the same MCP requests over Streamable HTTP, records each HTTP roundtrip, captures each `tools/call` response body, and calculates latency, bytes, and estimated token load from the collected responses.

This gives us a **technical, predictable, and reproducible** way to measure the benchmark without letting model behavior distort the numbers. The expected LLM-agent result should be at least directionally the same: the official GitHub MCP path needs a **multi-call loop**, while the reShapr path exposes **one task-shaped action**. The curl benchmark makes that difference **explicit and auditable**.

## Why This Benchmark

Agents are bad at **unnecessary loops**. Every extra tool call adds protocol overhead, latency, logs, error states, retry decisions, and context the model may need to read. Pull request velocity is a clean benchmark because the naive workflow naturally becomes **`1 + 3N` tool calls**: one call to list pull requests, then three follow-up calls for every pull request to fetch details, reviews, and changed files.

For 10 pull requests, this is:

```text
1 list call + (10 PRs * 3 follow-up calls) = 31 agent-facing MCP tool calls
```

With reShapr, the agent calls:

```text
get_repo_velocity_metrics(owner: "microsoft", name: "vscode", prCount: 10, reviewCount: 5, fileCount: 10)
```

The action returns **only what the use case needs**: pull request id, title, creator, state, creation and merge timestamps, review touchpoints, and changed paths.

That is the demonstration: not "can MCP call GitHub?", but **"can we shape an API into the tool an agent actually wanted?"**

## The Bigger Issue: Predictable Agents

LLM-driven agents are powerful because they can adapt, but that flexibility becomes a liability when the **same business workflow is rediscovered on every run**. One run may call tools in a different order. Another may skip a follow-up call. Another may over-fetch data, hit a transient error, or spend context on fields the task never needed.

reShapr does not make the model deterministic. It makes the **agent workflow boundary predictable**.

With the primitive-tool path, the agent is responsible for planning and executing the full loop:

```text
list pull requests -> for each pull request -> get details -> get reviews -> get files -> shape the result
```

With reShapr, that loop becomes a reusable MCP action:

```text
get_repo_velocity_metrics
```

The operational benefits are concrete. The **tool-call count** becomes predictable, **latency and payload size** become measurable, the **output shape** stays stable, and **failures** are localized to one action. Most importantly, **the same workflow** can be reproduced by humans, tests, and agents.

This is a big deal for agent adoption. Teams do not only need agents that can improvise. They need agent capabilities that can be **audited, benchmarked, documented, and run again with confidence**.

## What Is Being Compared

Both paths use Streamable HTTP MCP, not stdio.

The **official GitHub MCP path** uses the remote endpoint `https://api.githubcopilot.com/mcp/x/pull_requests/readonly` with the `X-MCP-Toolsets: pull_requests` header. The agent receives useful primitive tools, mainly `list_pull_requests` and `pull_request_read`, but it must still run the full loop itself: list pull requests, then call details, reviews, and files for each pull request.

The **reShapr path** starts from the same GitHub source of truth. It imports the full official GitHub REST OpenAPI YAML file by URL, exposes GitHub REST operations through reShapr MCP, attaches one custom tool that orchestrates the pull request workflow, and can attach `ToolsOutputFilters` artifacts to trim or TOON-encode the custom action output. The result is a compact task-specific payload rather than a pile of primitive tool responses.

Official GitHub OpenAPI URL used by reShapr:

```text
https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.yaml
```

The OpenAPI file is not copied into this article. reShapr imports it directly from that URL.

## Requirements

Install or have available:

- `curl`
- `jq`
- `docker`
- the `reshapr` CLI
- a GitHub token exported as `GITHUB_TOKEN`

Set the benchmark variables:

Script version: [scripts/00-env.sh](scripts/00-env.sh).

```bash
export TOKEN="REPLACE_WITH_YOUR_GITHUB_TOKEN"
export GITHUB_TOKEN="$TOKEN"

export OWNER="microsoft"
export REPO="vscode"
export PR_COUNT="10"
export REVIEW_COUNT="5"
export FILE_COUNT="10"

export GITHUB_OPENAPI_URL="https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.yaml"
export OFFICIAL_MCP_URL="https://api.githubcopilot.com/mcp/x/pull_requests/readonly"
export WORKDIR="/tmp/reshapr-github-mcp-benchmark"

mkdir -p "$WORKDIR"

export GITHUB_SERVICE_NAME="GitHub v3 REST API"
export GITHUB_SERVICE_FILTER_JSON_NAME="GitHub v3 REST API Filter JSON"
export GITHUB_SERVICE_FILTER_TOON_NAME="GitHub v3 REST API Filter TOON"
export GITHUB_SERVICE_VERSION="1.1.4"

printf 'GitHub OpenAPI service: %s %s\n' "$GITHUB_SERVICE_NAME" "$GITHUB_SERVICE_VERSION"
printf 'GitHub OpenAPI URL: %s\n' "$GITHUB_OPENAPI_URL"
```

## Start reShapr

Start reShapr locally. The benchmark used the nightly local stack because it imports the **full GitHub OpenAPI YAML** and runs a custom action that performs **31 backend tool calls**.

Script version: [scripts/01-start-reshapr.sh](scripts/01-start-reshapr.sh).

```bash
reshapr run --release nightly
```

For the full GitHub OpenAPI YAML, the gateway needs a **larger exposition-discovery gRPC message size**. For this 10-PR custom action, it also needs a **script tool-call budget above 31**. The benchmark used these gateway environment variables:

File version: [artifacts/gateway-env.example](artifacts/gateway-env.example).

```text
QUARKUS_GRPC_CLIENTS__EXPOSITION_DISCOVERY__MAX_INBOUND_MESSAGE_SIZE=33554432
QUARKUS_GRPC_CLIENTS__EXPOSITION_DISCOVERY__FLOW_CONTROL_WINDOW=33554432
RESHAPR_GATEWAY_SCRIPTING_MAX_TOOL_CALLS=50
```

You can verify them on the running gateway:

Script version: [scripts/02-check-gateway-env.sh](scripts/02-check-gateway-env.sh).

```bash
docker inspect reshapr-gateway-01 \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
| grep -E 'EXPOSITION_DISCOVERY|SCRIPTING_MAX_TOOL_CALLS'
```

In another terminal, authenticate the CLI if needed:

Script version: [scripts/03-login.sh](scripts/03-login.sh).

```bash
reshapr login -u admin -p password -s http://localhost:5555
```

Create a backend secret from your GitHub token:

Script version: [scripts/04-create-secret.sh](scripts/04-create-secret.sh).

```bash
SECRET_NAME="github-rest-backend-$(date +%Y%m%d%H%M%S)"

SECRET_ID="$(
  reshapr secret create "$SECRET_NAME" \
    --backend \
    --token "$GITHUB_TOKEN" \
    --description "Read-only GitHub token for the GitHub MCP benchmark" \
    --output json \
  | jq -r '.id'
)"

echo "$SECRET_ID"
```

Import the full official GitHub OpenAPI YAML by URL. This imports the whole API description; it does not copy the OpenAPI file into the project.

Script version: [scripts/05-import-base-service.sh](scripts/05-import-base-service.sh).

```bash
reshapr import \
  --url "$GITHUB_OPENAPI_URL" \
  --serviceName "$GITHUB_SERVICE_NAME" \
  --serviceVersion "$GITHUB_SERVICE_VERSION" \
  --output json \
| tee "$WORKDIR/import-base.json"
```

Create the reShapr custom MCP action:

Artifact files: [artifacts/github-velocity-custom-tools.yaml](artifacts/github-velocity-custom-tools.yaml), [artifacts/github-velocity-custom-tools-filter-json.yaml](artifacts/github-velocity-custom-tools-filter-json.yaml), and [artifacts/github-velocity-custom-tools-filter-toon.yaml](artifacts/github-velocity-custom-tools-filter-toon.yaml).

```bash
cat > "$WORKDIR/github-velocity-custom-tools.yaml" <<YAML
apiVersion: reshapr.io/v1alpha1
kind: CustomTools
service:
  name: $GITHUB_SERVICE_NAME
  version: "$GITHUB_SERVICE_VERSION"
customTools:
  get_repo_velocity_metrics:
    description: Fetch recent pull requests, review touchpoints, and changed file paths as one compact repository velocity action.
    input:
      type: object
      properties:
        owner:
          type: string
          description: GitHub organization or repository owner.
        name:
          type: string
          description: GitHub repository name.
        prCount:
          type: number
          description: Number of recent pull requests to inspect.
          default: 10
        reviewCount:
          type: number
          description: Maximum reviews to inspect per pull request.
          default: 5
        fileCount:
          type: number
          description: Maximum changed files to inspect per pull request.
          default: 10
      required:
        - owner
        - name
    tools:
      - tool: get_repos_owner_repo_pulls
      - tool: get_repos_owner_repo_pulls_pull_number
      - tool: get_repos_owner_repo_pulls_pull_number_reviews
      - tool: get_repos_owner_repo_pulls_pull_number_files
    script: |
      function asInt(value, fallback, min, max) {
        const parsed = Number(value);
        if (!Number.isFinite(parsed)) { return fallback; }
        return Math.max(min, Math.min(max, Math.floor(parsed)));
      }

      function requireOk(result, label) {
        if (!result || !result.ok) {
          rs.fail(label + ' failed', result ? result.error || result.content : null);
        }
        return result.content;
      }

      function loginOf(user) {
        return user && user.login ? user.login : null;
      }

      function compactReview(review) {
        return {
          reviewer: loginOf(review.user),
          state: review.state || null,
          submitted_at: review.submitted_at || null
        };
      }

      function compactPath(file) {
        return file.filename || file.path || null;
      }

      const owner = input.owner;
      const repo = input.name;
      const prCount = asInt(input.prCount, 10, 1, 25);
      const reviewCount = asInt(input.reviewCount, 5, 1, 25);
      const fileCount = asInt(input.fileCount, 10, 1, 50);

      const list = requireOk(rs.callTool('get_repos_owner_repo_pulls', {
        owner: owner,
        repo: repo,
        state: 'all',
        sort: 'updated',
        direction: 'desc',
        per_page: prCount
      }), 'list pull requests');

      const selected = Array.isArray(list) ? list.slice(0, prCount) : [];
      const jobs = [];

      for (let i = 0; i < selected.length; i++) {
        const number = selected[i].number;
        jobs.push({
          index: i,
          type: 'detail',
          promise: rs.callToolAsync('get_repos_owner_repo_pulls_pull_number', {
            owner: owner,
            repo: repo,
            pull_number: number
          })
        });
        jobs.push({
          index: i,
          type: 'reviews',
          promise: rs.callToolAsync('get_repos_owner_repo_pulls_pull_number_reviews', {
            owner: owner,
            repo: repo,
            pull_number: number,
            per_page: reviewCount
          })
        });
        jobs.push({
          index: i,
          type: 'files',
          promise: rs.callToolAsync('get_repos_owner_repo_pulls_pull_number_files', {
            owner: owner,
            repo: repo,
            pull_number: number,
            per_page: fileCount
          })
        });
      }

      const jobResults = rs.awaitPromises(jobs.map(function (job) { return job.promise; }));
      const expanded = selected.map(function (pull) {
        return { list: pull, detail: null, reviews: [], files: [] };
      });

      for (let i = 0; i < jobs.length; i++) {
        const job = jobs[i];
        const number = selected[job.index].number;
        const content = requireOk(jobResults[i], job.type + ' for #' + number);
        expanded[job.index][job.type] = content;
      }

      const metrics = [];

      for (let i = 0; i < expanded.length; i++) {
        const item = expanded[i];
        const detail = item.detail || item.list;
        const reviews = item.reviews;
        const files = item.files;
        const number = item.list.number;

        metrics.push({
          pr_id: detail.number || number,
          title: detail.title || item.list.title || null,
          creator: loginOf(detail.user || item.list.user),
          state: detail.state || item.list.state || null,
          created_at: detail.created_at || item.list.created_at || null,
          merged_at: detail.merged_at || item.list.merged_at || null,
          review_touchpoints: Array.isArray(reviews) ? reviews.slice(0, reviewCount).map(compactReview) : [],
          changed_paths: Array.isArray(files) ? files.slice(0, fileCount).map(compactPath).filter(Boolean) : []
        });
      }

      return {
        owner: owner,
        repo: repo,
        requested_prs: prCount,
        inspected_prs: metrics.length,
        source_backend_calls: 1 + (3 * metrics.length),
        metrics: metrics
      };
YAML
```

Attach the custom action:

Script version: [scripts/06-attach-custom-tool.sh](scripts/06-attach-custom-tool.sh).

```bash
reshapr attach \
  --file "$WORKDIR/github-velocity-custom-tools.yaml" \
  --output json
```

Expose the base service after the custom action is attached:

Script version: [scripts/07-expose-base-service.sh](scripts/07-expose-base-service.sh).

```bash
SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-base.json")"

CONFIG_ID="$(
  reshapr config create "github velocity benchmark base" \
    --serviceId "$SERVICE_ID" \
    --backendEndpoint "https://api.github.com" \
    --backendSecret "$SECRET_ID" \
    --output json \
  | tee "$WORKDIR/config-base.json" \
  | jq -r '.id // .configurationPlan.id'
)"

reshapr expo create \
  --configuration "$CONFIG_ID" \
  --gateway-group "1" \
  --output json \
| tee "$WORKDIR/expo-base.json"

export RESHAPR_MCP_URL="http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API/1.1.4"
```

Create the JSON output filter artifact. This keeps **only the `metrics` array** and removes two timestamp fields from the first three metrics:

Artifact file: [artifacts/filter-json.yaml](artifacts/filter-json.yaml).

```bash
cat > "$WORKDIR/filter-json.yaml" <<YAML
apiVersion: reshapr.io/v1alpha1
kind: ToolsOutputFilters
service:
  name: GitHub v3 REST API Filter JSON
  version: "1.1.4"
filters:
  get_repo_velocity_metrics:
    jsonRetain:
      - /metrics
    jsonPatches:
      - op: remove
        path: /metrics/0/created_at
      - op: remove
        path: /metrics/0/merged_at
      - op: remove
        path: /metrics/1/created_at
      - op: remove
        path: /metrics/1/merged_at
      - op: remove
        path: /metrics/2/created_at
      - op: remove
        path: /metrics/2/merged_at
YAML
```

Create the same filter with TOON conversion enabled:

Artifact file: [artifacts/filter-toon.yaml](artifacts/filter-toon.yaml).

```bash
cat > "$WORKDIR/filter-toon.yaml" <<YAML
apiVersion: reshapr.io/v1alpha1
kind: ToolsOutputFilters
service:
  name: GitHub v3 REST API Filter TOON
  version: "1.1.4"
filters:
  get_repo_velocity_metrics:
    jsonRetain:
      - /metrics
    jsonPatches:
      - op: remove
        path: /metrics/0/created_at
      - op: remove
        path: /metrics/0/merged_at
      - op: remove
        path: /metrics/1/created_at
      - op: remove
        path: /metrics/1/merged_at
      - op: remove
        path: /metrics/2/created_at
      - op: remove
        path: /metrics/2/merged_at
    convertToToon: true
YAML
```

Create the filtered services. Each service imports the same full official GitHub OpenAPI YAML, attaches the same custom action under that service name, then attaches the corresponding **output filter before exposure**:

Script version: [scripts/08-create-filtered-services.sh](scripts/08-create-filtered-services.sh).

```bash
sed "s/^  name: GitHub v3 REST API$/  name: GitHub v3 REST API Filter JSON/" \
  "$WORKDIR/github-velocity-custom-tools.yaml" \
  > "$WORKDIR/github-velocity-custom-tools-filter-json.yaml"

sed "s/^  name: GitHub v3 REST API$/  name: GitHub v3 REST API Filter TOON/" \
  "$WORKDIR/github-velocity-custom-tools.yaml" \
  > "$WORKDIR/github-velocity-custom-tools-filter-toon.yaml"

reshapr import \
  --url "$GITHUB_OPENAPI_URL" \
  --serviceName "$GITHUB_SERVICE_FILTER_JSON_NAME" \
  --serviceVersion "$GITHUB_SERVICE_VERSION" \
  --output json \
| tee "$WORKDIR/import-filter-json.json"

reshapr import \
  --url "$GITHUB_OPENAPI_URL" \
  --serviceName "$GITHUB_SERVICE_FILTER_TOON_NAME" \
  --serviceVersion "$GITHUB_SERVICE_VERSION" \
  --output json \
| tee "$WORKDIR/import-filter-toon.json"

reshapr attach --file "$WORKDIR/github-velocity-custom-tools-filter-json.yaml" --output json
reshapr attach --file "$WORKDIR/filter-json.yaml" --output json

FILTER_JSON_SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-filter-json.json")"
FILTER_JSON_CONFIG_ID="$(
  reshapr config create "github velocity benchmark filter json" \
    --serviceId "$FILTER_JSON_SERVICE_ID" \
    --backendEndpoint "https://api.github.com" \
    --backendSecret "$SECRET_ID" \
    --output json \
  | tee "$WORKDIR/config-filter-json.json" \
  | jq -r '.id // .configurationPlan.id'
)"
reshapr expo create --configuration "$FILTER_JSON_CONFIG_ID" --gateway-group "1" --output json

reshapr attach --file "$WORKDIR/github-velocity-custom-tools-filter-toon.yaml" --output json
reshapr attach --file "$WORKDIR/filter-toon.yaml" --output json

FILTER_TOON_SERVICE_ID="$(jq -r '.service.id // .id' "$WORKDIR/import-filter-toon.json")"
FILTER_TOON_CONFIG_ID="$(
  reshapr config create "github velocity benchmark filter toon" \
    --serviceId "$FILTER_TOON_SERVICE_ID" \
    --backendEndpoint "https://api.github.com" \
    --backendSecret "$SECRET_ID" \
    --output json \
  | tee "$WORKDIR/config-filter-toon.json" \
  | jq -r '.id // .configurationPlan.id'
)"
reshapr expo create --configuration "$FILTER_TOON_CONFIG_ID" --gateway-group "1" --output json

export RESHAPR_MCP_URL_FILTER_JSON="http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+JSON/1.1.4"
export RESHAPR_MCP_URL_FILTER_TOON="http://localhost:7777/mcp/reshapr/GitHub+v3+REST+API+Filter+TOON/1.1.4"
```

Confirm the reShapr MCP endpoint exposes the custom action:

Script version: [scripts/09-confirm-tools-list.sh](scripts/09-confirm-tools-list.sh).

```bash
curl -sS \
  -X POST "$RESHAPR_MCP_URL" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  --data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": {
        "name": "curl-check",
        "version": "1.0.0"
      }
    }
  }' \
  -D "$WORKDIR/reshapr-init.headers" \
  -o "$WORKDIR/reshapr-init.body"

RESHAPR_SESSION_ID="$(
  awk 'tolower($0) ~ /^mcp-session-id:/ { sub(/^[^:]+:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' \
    "$WORKDIR/reshapr-init.headers"
)"

curl -sS \
  -X POST "$RESHAPR_MCP_URL" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -H "Mcp-Session-Id: $RESHAPR_SESSION_ID" \
  --data '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' \
  -o /dev/null

curl -sS \
  -X POST "$RESHAPR_MCP_URL" \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  -H "MCP-Protocol-Version: 2025-06-18" \
  -H "Mcp-Session-Id: $RESHAPR_SESSION_ID" \
  --data '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  -o "$WORKDIR/reshapr-tools.body"

if grep -q '^data:' "$WORKDIR/reshapr-tools.body"; then
  sed -n 's/^data:[[:space:]]*//p' "$WORKDIR/reshapr-tools.body" \
  | jq -r '.result.tools[].name'
else
  jq -r '.result.tools[].name' "$WORKDIR/reshapr-tools.body"
fi
```

Expected output includes:

```text
get_repo_velocity_metrics
```

## Curl-Only Benchmark Script

This script uses `curl` for every HTTP request and `curl -w` for latency and byte metrics. It saves every request body, response body, response header file, and a raw metrics table under `$WORKDIR`. It also retries transient HTTP and network failures so a temporary GitHub edge error does not invalidate the whole run.

Script version: [scripts/run-github-mcp-benchmark.sh](scripts/run-github-mcp-benchmark.sh).

```bash
cat > "$WORKDIR/run-github-mcp-benchmark.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

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
SH

chmod +x "$WORKDIR/run-github-mcp-benchmark.sh"
```

Run it:

```bash
"$WORKDIR/run-github-mcp-benchmark.sh"
```

The raw curl metrics and payload inspection commands are also available in [scripts/show-results.sh](scripts/show-results.sh).

The raw curl metrics file is:

```bash
cat "$WORKDIR/curl-metrics.tsv"
```

The reShapr shaped payload is:

```bash
jq '.' "$WORKDIR/reshapr/velocity.payload"
jq '.' "$WORKDIR/reshapr-filter-json/velocity.payload"
head -n 40 "$WORKDIR/reshapr-filter-toon/velocity.payload"
```

The official MCP response bodies are in:

```bash
find "$WORKDIR/official" -type f | sort
```

The reShapr MCP response bodies are in:

```bash
find "$WORKDIR/reshapr" "$WORKDIR/reshapr-filter-json" "$WORKDIR/reshapr-filter-toon" -type f | sort
```

## How To Read The Numbers

The benchmark separates two things:

1. MCP protocol roundtrips: every Streamable HTTP exchange, including initialization and `tools/list`.
2. Agent tool calls: only `tools/call` requests, because those are the calls an agent has to plan, issue, observe, and recover from.

(*) For bytes and token estimate, the table counts only tool-call response bodies. That is the content the agent must consume to continue its work. The token estimate is intentionally simple: response bytes divided by four. The script uses `(bytes + 3) / 4` to round that byte-based estimate up to the nearest whole token. It is not a tokenizer-specific claim, but it is a useful size proxy.

For the output-filter comparison, make sure the three reShapr variants inspect the same pull request IDs. `microsoft/vscode` is active enough that the "recently updated" set can change between runs. The published output-filter numbers below use one matched run where all reShapr variants inspected the same 10 pull requests:

```text
325138,325045,325180,325168,325173,325170,325175,322952,325163,325165
```

The reShapr payload includes this field:

Payload file: [payloads/reshapr-source-backend-calls-example.json](payloads/reshapr-source-backend-calls-example.json).

```json
{
  "source_backend_calls": 31
}
```

That field is important. It proves reShapr is not hiding the source work. It is consolidating the workflow at the MCP boundary and shaping the result before the agent sees it.

## Why reShapr Wins Here

The official GitHub MCP path gives the agent general-purpose pull-request tools. That is useful, but the agent still has to plan and drive the workflow one step at a time.

reShapr lets an API owner or platform team expose a use-case-level action:

```text
get_repo_velocity_metrics
```

That action is better for agents because it has **one clear intent**, **one compact input schema**, **one response shape**, and **one failure surface**. It also gives the API owner one place to encode pagination, fan-out, filtering, and field selection instead of asking every agent to rediscover that orchestration pattern at runtime.

This is the real reShapr advantage: it turns **existing APIs into agent-native tools** without asking every agent to rediscover the same orchestration loop.

For this use case, the difference is not subtle. **31 agent tool calls become 1**. **34 MCP HTTP roundtrips become 4**. **267.8 KB** of official MCP tool responses becomes **7.4 KB**, and roughly **67.0K estimated tokens** becomes **1.9K**. When the use case can safely drop fields, **output filters and TOON** can reduce the already compact custom output further.

That is the kind of improvement that changes **how reliable an agent workflow feels in practice**.

## What This Demonstrates

This benchmark does not argue that primitive MCP tools are bad. They are necessary. It shows that primitive tools are often **not the right final interface for agents**.

The best agent-facing interface is usually **not the raw API**. It is a **domain action shaped around the task**:

```text
Repository velocity, not pull request plumbing.
```

reShapr provides the **missing layer**. It can import the **official API description**, expose it as **MCP over Streamable HTTP**, compose existing operations into a **custom tool**, reduce the payload to the **fields the task needs**, and keep the full flow **reproducible with curl**.

That is why the reShapr approach is superior in this benchmark: it keeps the **GitHub source of truth**, removes **avoidable agent overhead**, and turns a fragile multi-step agent loop into a **predictable workflow that can be reproduced, measured, and trusted**.
