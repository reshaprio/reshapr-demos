#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/../../scripts/lib/demo-env.sh"

clear

p "Demo #0 Setup - install reshapr-cli"
echo
pei "npm install -g @reshapr/reshapr-cli"
echo
pei "reshapr --version"
echo
pei "reshapr help"
echo
p "🎉 Now we have reShapr CLI installed and can run reShapr locally or using https://try.reshapr.io/"
