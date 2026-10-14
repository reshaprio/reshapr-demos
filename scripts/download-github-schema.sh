#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${ROOT}/resources/github/schema.docs.graphql"

# Pinned to the last github/docs snapshot (2026-10-01) that reShapr 1.0.0 can import.
# Newer schemas fail with "value too long for type character varying(255)":
# https://github.com/reshaprio/reshapr/issues/559 - switch back to
# https://docs.github.com/public/fpt/schema.docs.graphql once it is fixed.
GITHUB_DOCS_SCHEMA_REF="f572b79089f2de09cfbb7335a993de1fca0c485c"

curl -fL "https://raw.githubusercontent.com/github/docs/${GITHUB_DOCS_SCHEMA_REF}/src/graphql/data/fpt/schema.docs.graphql" -o "${TARGET}"
echo "Downloaded GitHub GraphQL schema to ${TARGET}"
