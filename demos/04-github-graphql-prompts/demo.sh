#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #4 - GitHub GraphQL API and Context Control with Prompts\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
pei "reshapr service list"
echo
p "The GitHub GraphQL schema was already imported with a CustomTool 'get_user_with_latest_followers'."
p "Check our previous demo on YouTube if you missed it!"
echo
wait
p "Now let's attach some prompts!"
echo
pei "show_file ./resources/github/prompts.yaml"
echo
pei "reshapr attach -f ./resources/github/prompts.yaml"
echo
p "Let's check using your MCP client, let us kiro-cli today 🎉"
