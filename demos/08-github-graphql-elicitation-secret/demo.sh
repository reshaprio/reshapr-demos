#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #8 - GitHub GraphQL API with Token Elicitation Secret\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
p "Let's start with a clean reShapr instance and show that no services are configured yet."
echo
pei "reshapr service list"
echo
p "Now create an elicitation secret for the GitHub token. This stores the Authorization header name,"
p "and the token value will be requested through elicitation when the backend needs it."
echo
p "reshapr secret create-elicitation github -t Authorization -d \"My GitHub Token Elicitation\""
GITHUB_ELICITATION_SECRET_OUTPUT="$(reshapr secret create-elicitation github -t Authorization -d "My GitHub Token Elicitation")"
printf "%s\n" "${GITHUB_ELICITATION_SECRET_OUTPUT}"
GITHUB_ELICITATION_SECRET_ID="$(printf "%s\n" "${GITHUB_ELICITATION_SECRET_OUTPUT}" | sed -nE 's/.*ID: ([[:alnum:]_-]+).*/\1/p' | tail -n 1)"

if [[ -z "${GITHUB_ELICITATION_SECRET_ID}" ]]; then
  echo "Could not find the generated elicitation secret ID in the create command output." >&2
  exit 1
fi

echo
p "Because the GitHub GraphQL schema is huge, reShapr can generate a large tool surface from the full schema."
p "But we don't need all of those tools for our MCP client app, we just need the 'user' query"
p "to get information about GitHub users."
echo
p "So let's import the schema with an input/output filter to just get the 'user' query and its related types!"
p "And using the elicitation secret as the backend secret."
echo
pei "reshapr import -f ./schema.docs.graphql --sn \"GitHub GraphQL\" --sv ${GITHUB_GRAPHQL_SERVICE_VERSION} --be https://api.github.com/graphql --bs ${GITHUB_ELICITATION_SECRET_ID} --io '[\"user\"]'"
echo
p "Now we have the GitHub schema imported into reShapr and exposed through the GitHub backend,"
p "using an elicitation-based token secret."
echo
pei "reshapr secret list"
pei "reshapr service list"
echo
p "Let's check using your MCP client app and demonstrate the elicitation-based token secret in action 🎉"
