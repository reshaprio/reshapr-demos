#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_MAGIC_OPTS="-d"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Legacy combined demo - install reShapr and run locally, Open-Meteo app\""
p "npm install -g @reshapr/reshapr-cli"
pe "reshapr status"
pe "reshapr run"
pe "reshapr status"
pe "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
pe "reshapr service list"
pe "code ./resources/open-meteo/openapi.yml"
pe "reshapr import -f ./resources/open-meteo/openapi.yml --backendEndpoint https://api.open-meteo.com"
pei "echo \"Now we have the OpenAPI spec imported into reShapr and can use it with my MCP client app\""
pe "code ./apps/open-meteo/resources/app.local.yaml"
pe "npm run start:open-meteo &"
pe "reshapr attach -f ./apps/open-meteo/resources/app.local.yaml"
pei "echo \"Now we attached my MCP app into reShapr and service 'Open-Meteo APIs' and can use it with my MCP client app\""
