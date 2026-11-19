#!/usr/bin/env bash
set -euo pipefail

KEYCLOAK_CONTAINER="${RESHAPR_KEYCLOAK_CONTAINER:-reshapr-keycloak-dev}"

if command -v reshapr >/dev/null 2>&1; then
  reshapr stop
else
  echo "reShapr CLI is not installed; skipping 'reshapr stop'." >&2
fi

if command -v docker >/dev/null 2>&1 && docker inspect "${KEYCLOAK_CONTAINER}" >/dev/null 2>&1; then
  echo "Removing Keycloak container (${KEYCLOAK_CONTAINER})..."
  docker rm -f "${KEYCLOAK_CONTAINER}" >/dev/null
fi
