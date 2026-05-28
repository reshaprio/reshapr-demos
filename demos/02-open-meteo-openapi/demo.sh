#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

p "Demo #2 Open meteo - import OpenAPI spec and expose it using reShapr"
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
echo
p "ℹ️ default reShapr admin password is 'password' - you can change it by editing the docker-compose file in ~/.reshapr/reshapr/docker-compose-version.yml"
echo
pei "reshapr service list"
echo
pei "reshapr import -u https://raw.githubusercontent.com/open-meteo/open-meteo/refs/heads/main/openapi.yml --backendEndpoint https://api.open-meteo.com"
echo
p "👍 Now you have the OpenAPI spec imported into reShapr and can use the Endpoints above (prefix it using 'http://' here) with your favorite MCP client app, just create a remote MCP server (HTTP Streamable)"
p "ℹ️ You can also import local files into reShapr using the -f option."
echo
pei "reshapr service list"
echo
p "🎉 Yep, Now, Enjoy your new MCP server instantly!"
p "Next, run Demo #7 to attach the Open-Meteo MCP app resource."
