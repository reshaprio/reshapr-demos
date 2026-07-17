#!/usr/bin/env bash
set -euo pipefail

RESHAPR_SERVER="${RESHAPR_SERVER:-http://localhost:5555}"
RESHAPR_USER="${RESHAPR_USER:-admin}"
RESHAPR_PASSWORD="${RESHAPR_PASSWORD:-password}"

reshapr login -u "$RESHAPR_USER" -p "$RESHAPR_PASSWORD" -s "$RESHAPR_SERVER"
