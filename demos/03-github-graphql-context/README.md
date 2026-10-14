# Demo 03: GitHub GraphQL Context Control

This demo runs `./scripts/download-github-schema.sh`, which overwrites `resources/github/schema.docs.graphql` with a schema pinned to a github/docs commit that reShapr 1.0.0 can import (see [reshaprio/reshapr#559](https://github.com/reshaprio/reshapr/issues/559)).

`demo-prio-2026-07-28.sh` is a variant of the demo that calls the MCP endpoint with the older `GitHub+GraphQL/<version>` URL and request format.

After this demo, run Demos 04, 05 and 06, which build on the GitHub GraphQL service it creates.

Run from this directory:

```sh
./demo.sh
```

Run from the repository root:

```sh
./demos/03-github-graphql-context/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:03
```
