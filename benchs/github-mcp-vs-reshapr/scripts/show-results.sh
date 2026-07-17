#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-env.sh
source "$SCRIPT_DIR/00-env.sh"

echo "Raw curl metrics:"
cat "$WORKDIR/curl-metrics.tsv"

echo
echo "reShapr shaped payload:"
jq '.' "$WORKDIR/reshapr/velocity.payload"

echo
echo "reShapr JSON-filtered payload:"
jq '.' "$WORKDIR/reshapr-filter-json/velocity.payload"

echo
echo "reShapr TOON payload sample:"
head -n 40 "$WORKDIR/reshapr-filter-toon/velocity.payload"

echo
echo "Official MCP response files:"
find "$WORKDIR/official" -type f | sort

echo
echo "reShapr MCP response files:"
find "$WORKDIR/reshapr" "$WORKDIR/reshapr-filter-json" "$WORKDIR/reshapr-filter-toon" -type f | sort
