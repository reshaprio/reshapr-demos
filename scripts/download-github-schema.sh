#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${ROOT}/resources/github/schema.docs.graphql"

curl -L "https://docs.github.com/public/fpt/schema.docs.graphql" -o "${TARGET}"
echo "Downloaded GitHub GraphQL schema to ${TARGET}"
