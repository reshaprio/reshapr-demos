#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

pei "echo \"Demo #7 - Open-Meteo OpenAPI with MCP app\""
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
p "This demo assumes Demo #2 has already imported the Open-Meteo OpenAPI service."
p "The MCP app resource attaches a Weather Forecast Dashboard to that service."
echo
pei "reshapr service list"
echo
p "Start the Open-Meteo MCP app server in another terminal before attaching the resource:"
p "npm run start:open-meteo"
wait
echo
p "Now let's attach the Open-Meteo MCP app resource."
echo
pei "show_file ./apps/open-meteo/resources/app.local.yaml"
wait
echo
pei "reshapr attach -f ./apps/open-meteo/resources/app.local.yaml"
echo
p "Check the service list again after attaching the app resource."
echo
pei "reshapr service list"
echo
p "Open the Weather Forecast Dashboard from your MCP client or Postman Agent Mode."
