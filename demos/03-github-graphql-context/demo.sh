#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #3 - GitHub GraphQL API and Context Control\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
pei "reshapr service list"
echo
pei "./scripts/download-github-schema.sh"
echo
pei "reshapr import -f ./resources/github/schema.docs.graphql --sn \"GitHub GraphQL\" --sv ${GITHUB_GRAPHQL_SERVICE_VERSION} --be https://api.github.com/graphql"
echo
pei "reshapr service list"
echo
p "Now we have the GitHub schema imported into reShapr and can use it with your MCP client app."
echo
wait
p "But let's check the number of characters in the tools list response for the GitHub GraphQL service!"
echo
pei "curl ${RESHAPR_MCP_URL}/mcp/reshapr/GitHub+GraphQL/${GITHUB_GRAPHQL_SERVICE_VERSION} -H 'Content-type: application/json' -X POST -d '{\"jsonrpc\": \"2.0\", \"method\": \"tools/list\", \"params\": {}}' -s | wc -c"
p "That's a lot of tools! Because the GitHub GraphQL schema is huge and reShapr generates a tool for"
p "each query, mutation, and subscription in the schema. But we don't need all of those tools for our"
p "MCP client app, we just need the 'user' query to get information about GitHub users."
echo
p "So let's import the schema again but this time with an input/output filter to just get the 'user' query and its related types!"
echo
pei "reshapr import -f ./resources/github/schema.docs.graphql --sn \"GitHub GraphQL\" --sv ${GITHUB_GRAPHQL_SERVICE_VERSION} --be https://api.github.com/graphql --io '[\"user\"]'"
echo
p "Now we have the GitHub schema imported into reShapr but just the '[\"user\"]' query we need."
echo
p "Let's check using your MCP client app."
echo
wait
p "And check the number of characters in the tools list response for the GitHub GraphQL service again!"
echo
pe "curl ${RESHAPR_MCP_URL}/mcp/reshapr/GitHub+GraphQL/${GITHUB_GRAPHQL_SERVICE_VERSION} -H 'Content-type: application/json' -X POST -d '{\"jsonrpc\": \"2.0\", \"method\": \"tools/list\", \"params\": {}}' -s | wc -c"
p "That's much better! Now we have a much smaller set of tools that are relevant to our MCP client app,"
p "but still many related types we don't need."
echo
p "But we can improve further! So, now, let's import the schema again but this time with a 'CustomTools'"
p "to fine tune the context windows!"
echo
wait
pei "show_file ./resources/github/custom-tools.yaml"
echo
pei "reshapr attach -f ./resources/github/custom-tools.yaml"
echo
p "Let's check using your MCP client app."
echo
wait
p "And check the number of characters in the tools list response for the GitHub GraphQL service again!"
echo
pe "curl ${RESHAPR_MCP_URL}/mcp/reshapr/GitHub+GraphQL/${GITHUB_GRAPHQL_SERVICE_VERSION} -H 'Content-type: application/json' -X POST -d '{\"jsonrpc\": \"2.0\", \"method\": \"tools/list\", \"params\": {}}' -s | wc -c"
echo
p "🎉 Now we have a very small set of tools that are relevant to our MCP client app and the context-"
p "windows are much more manageable for the LLM to work with! We can always adjust the 'CustomTools'"
p "file to add or remove tools as needed for our app!"
