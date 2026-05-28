#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #5 - GitHub GraphQL API and Context Control with MCP app\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
pei "reshapr service list"
echo
p "The GitHub GraphQL schema was already imported with a CustomTool 'get_user_with_latest_followers'."
p "Check our previous demo on YouTube if you missed it!"
echo
p "Start the MCP app server in another terminal before attaching the resource:"
p "npm run start:github-user"
wait
echo
p "Now let's attach the MCP app resources!"
echo
pei "show_file ./apps/github-user/resources/app.local.yaml"
wait
echo
pei "reshapr attach -f ./apps/github-user/resources/app.local.yaml"
echo
p "Let's check using your MCP client app from Postman 🎉"
