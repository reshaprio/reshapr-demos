# Demo 09: Open-Meteo OpenAPI Keycloak Elicitation

Run from this directory:

```sh
./demo.sh
```

Run from the repository root:

```sh
./demos/09-open-meteo-openapi-keycloak-elicitation/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:09
```

Prerequisites:

- Demo 00, to install the reShapr CLI.
- Demo 01, to start the local reShapr stack.
- Docker, to start the local Keycloak container.

This demo copies the local Keycloak helper and `3rdparty` realm import from the
reShapr project. The helper starts Keycloak on `http://localhost:8888`, and the
demo stops if the local reShapr stack is not reachable before login.
