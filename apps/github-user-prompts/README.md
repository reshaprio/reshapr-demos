# GitHub User Prompts MCP App

Prompt launcher for GitHub user prompts. It sends the selected prompt text to the MCP host so the LLM can interpret it and decide how to use the available tools.

Run from the repository root:

```sh
npm run start:github-user-prompts
```

Build from the repository root:

```sh
npm --workspace @reshapr-demos/github-user-prompts run build
```

Attach the local app resource to reShapr:

```sh
reshapr attach -f apps/github-user-prompts/resources/app.local.yaml
```

## Remote App Resource

Use `resources/app.remote.example.yaml` when the MCP app is available from a public URL, for example after deploying it or exposing your local server through ngrok.

Edit the `remoteContent` value first:

```yaml
remoteContent: https://your-public-app-url.example.com/mcp-app.html
```

Then attach the remote resource manifest:

```sh
reshapr attach -f apps/github-user-prompts/resources/app.remote.example.yaml
```
