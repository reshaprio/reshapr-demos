#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #6 - GitHub GraphQL API and Context Control with MCP app prompts\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
pei "reshapr service list"
echo
p "This MCP app uses the GitHub GraphQL artifacts and resources attached in the previous demos:"
p "the schema import, the custom tool, the prompts, and the app resource."
p "Let's check it with the 'artifact' command."
echo
pei "reshapr service list -o json | jq -r '.[] | select(.name==\"GitHub GraphQL\" and .version==\"20260410\") | .id' | xargs -I {} reshapr artifact list -s {}"
echo
p "The GitHub GraphQL schema was already imported with a CustomTool 'get_user_with_latest_followers',"
p "and 'prompts' resources. Check our previous demo on YouTube if you missed it!"
echo
p "Start the MCP app prompts server in another terminal before attaching the resource:"
p "npm run start:github-user-prompts"
wait
echo
p "Now let's attach the MCP app resources!"
echo
pei "show_file ./apps/github-user-prompts/resources/app.local.yaml"
wait
echo
pei "reshapr attach -f ./apps/github-user-prompts/resources/app.local.yaml"
echo
p "Let’s check our artifact list again, as we’ve now added the MCP app resource:"
echo
pei "reshapr service list -o json | jq -r '.[] | select(.name==\"GitHub GraphQL\" and .version==\"20260410\") | .id' | xargs -I {} reshapr artifact list -s {}"
echo
p "Let's check using your LLM or Postman Agent Mode 🎉"
