#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

require_reshapr

PETSTORE_MCP_URL="${RESHAPR_MCP_URL}/mcp/reshapr/swagger-petstore-openapi-3-0-1-0-27-default"

wait_for_petstore_skill() {
  local deadline=$((SECONDS + 15))
  while (( SECONDS < deadline )); do
    if curl -fsS "${PETSTORE_MCP_URL}" \
      -X POST \
      -H 'Accept: application/json, text/event-stream' \
      -H 'Content-Type: application/json' \
      -H 'MCP-Protocol-Version: 2026-07-28' \
      -d '{"jsonrpc":"2.0","id":1,"method":"skills/list","params":{}}' 2>/dev/null \
      | grep -q '"petstore-adoption-desk"'; then
      return 0
    fi
    sleep 1
  done
  echo "Timed out waiting for petstore-adoption-desk on ${PETSTORE_MCP_URL}; running inspector anyway." >&2
}

clear

p "Demo #10 Petstore - serve a Skill over MCP with reShapr"
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
pei "reshapr import -u https://petstore3.swagger.io/api/v3/openapi.json --backendEndpoint https://petstore3.swagger.io/api/v3"
echo
p "The Petstore API is now an MCP server. Tools say what the API can do. A Skill says how your team wants it used."
echo
pei "show_file ./demos/10-petstore-skills/skills/petstore-adoption-desk/SKILL.md"
wait
echo
pei "show_file ./demos/10-petstore-skills/resources/skills.remote.yaml"
p "The skill is served from a Git tag of this repository, so no file server is needed."
wait
echo
pei "reshapr attach -f ./demos/10-petstore-skills/resources/skills.remote.yaml"
wait_for_petstore_skill
echo
p "Now check that the Skill is discoverable and conformant (SEP-2640) with the MCP Inspector."
echo
pei "npx -y @modelcontextprotocol/inspector@latest --cli ${PETSTORE_MCP_URL} --transport http --method skills/list --verify"
echo
p "🎉 The Skill is served next to the tools. Point Claude (or any MCP client that supports skills) at ${PETSTORE_MCP_URL}"
p "ℹ️ To edit the skill and see your changes without a commit or tag, use skills.local.yaml (see the README)."
