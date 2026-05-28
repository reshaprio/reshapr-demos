# reShapr Demos

Demo scripts and MCP app examples for showing how reShapr can expose APIs as MCP servers, reduce context size, attach prompts, and attach MCP app resources.

## Repository Layout

- `demos/` contains the shell-driven demo flows. Each demo directory has a canonical `demo.sh` entrypoint.
- `apps/` contains MCP app examples managed by npm workspaces.
- `resources/` contains shared OpenAPI, GraphQL, custom tool, and prompt resources.
- `scripts/` contains repository-maintained helper scripts.
- `tools/` contains external tools used by the demos, currently `demo-magic`.
- `config/` contains shared TypeScript and Vite config for the MCP apps.

## Watch the Demos

If you want to see the demos in action before running them in your own environment, they are available on the reShapr YouTube channel:

https://www.youtube.com/@reShaprio

## Prerequisites

- Node.js 22
- npm
- Docker, for running reShapr locally
- reShapr CLI, installed by demo 00

Optional:

- `bat`, for nicer YAML/schema display during demos. The scripts fall back to `cat`.

## Install

Install all MCP app dependencies from the repository root:

```sh
npm install
```

## Run a Demo

Each demo can be run directly:

```sh
./demos/05-github-mcp-app/demo.sh
```

You can also use root npm aliases:

```sh
npm run demo:05
```

Use direct `demo.sh` execution when presenting or editing a demo. Use npm aliases when following commands from the root README.

## Demos

| Demo | Direct command | npm alias |
| --- | --- | --- |
| 00 Install CLI | `./demos/00-install-cli/demo.sh` | `npm run demo:00` |
| 01 Run local reShapr | `./demos/01-run-local/demo.sh` | `npm run demo:01` |
| 02 Import Open-Meteo OpenAPI | `./demos/02-open-meteo-openapi/demo.sh` | `npm run demo:02` |
| 03 GitHub GraphQL context control | `./demos/03-github-graphql-context/demo.sh` | `npm run demo:03` |
| 04 GitHub GraphQL prompts | `./demos/04-github-graphql-prompts/demo.sh` | `npm run demo:04` |
| 05 GitHub MCP app resource | `./demos/05-github-mcp-app/demo.sh` | `npm run demo:05` |
| 06 GitHub MCP app prompts | `./demos/06-github-mcp-app-prompts/demo.sh` | `npm run demo:06` |
| 07 Open-Meteo MCP app resource after Demo 02 | `./demos/07-open-meteo-mcpapp/demo.sh` | `npm run demo:07` |

## MCP Apps

Start one MCP app server at a time:

```sh
npm run start:open-meteo
npm run start:github-user
npm run start:github-user-prompts
```

Each app serves `dist/mcp-app.html` on `http://localhost:3030` by default. Override the port with `PORT`.

Build all apps:

```sh
npm run build
```

## Shared Resources

- `resources/open-meteo/openapi.yml`
- `resources/github/schema.docs.graphql`
- `resources/github/custom-tools.yaml`
- `resources/github/prompts.yaml`

Refresh the GitHub GraphQL schema with:

```sh
./scripts/download-github-schema.sh
```
