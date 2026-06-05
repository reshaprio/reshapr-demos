# Demo 08: GitHub GraphQL Elicitation Secret

Run from this directory:

```sh
./demo.sh
```

Run from the repository root:

```sh
./demos/08-github-graphql-elicitation-secret/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:08
```

Remark, if you want to use https (mandatory for Claude) and a URL available from the Internet using ngrok:

1. Update your proxy (gateway) FQDN in the gateway env in your docker compose:

```yaml
gateway-01:
    .../...
    environment:
      # Gateway registers that FQDN with the control plane, and generated MCP endpoints will use it, like:
      # https://RESHAPR_GATEWAY_FQDNS/mcp/{organization}/{service}/{version}
      - RESHAPR_GATEWAY_FQDNS=YOUR-NGROK-URL
```

2. Expose localhost port 7777, using:

```bash
ngrok http 7777 --url YOUR-NGROK-URL
```
