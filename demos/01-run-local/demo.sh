#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

p "Demo #1 Setup - run reShapr locally with Docker"
echo
pei "reshapr status"
echo
pei "reshapr run"
echo
pei "reshapr status"
echo
p "🎉 Now we have reShapr running locally with Docker; log in and enjoy!"
echo
pei "reshapr login -u admin -p ${RESHAPR_PASSWORD} -s ${RESHAPR_URL}"
