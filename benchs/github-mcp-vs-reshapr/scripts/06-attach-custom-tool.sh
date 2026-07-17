#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

reshapr attach   --file "$BENCH_DIR/artifacts/github-velocity-custom-tools.yaml"   --output json
