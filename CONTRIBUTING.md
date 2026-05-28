# Contributing

## Setup

Use Node.js 22, then install from the repository root:

```sh
npm install
```

## Demo Scripts

Every demo should live in its own directory under `demos/` and expose a `demo.sh` entrypoint. Demo scripts should source `scripts/lib/demo-env.sh` so they work whether they are launched from the repository root or from their own directory.

Use shared resources from `resources/` instead of duplicating OpenAPI, GraphQL, custom tool, or prompt files inside demo directories.

## MCP Apps

Add new MCP apps under `apps/<name>/`. Keep app-specific UI and resource manifests there, and reuse the shared configs in `config/`.

Generated folders such as `node_modules/` and `dist/` should not be committed.
