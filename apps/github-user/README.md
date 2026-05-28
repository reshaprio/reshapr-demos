# GitHub User MCP App

GitHub user profile widget backed by the `get_user_with_latest_followers` custom tool.

Run from the repository root:

```sh
npm run start:github-user
```

Build from the repository root:

```sh
npm --workspace @reshapr-demos/github-user run build
```

Attach the local app resource to reShapr:

```sh
reshapr attach -f apps/github-user/resources/app.local.yaml
```

## Remote App Resource

Use `resources/app.remote.example.yaml` when the MCP app is available from a public URL, for example after deploying it or exposing your local server through ngrok.

Edit the `remoteContent` value first:

```yaml
remoteContent: https://your-public-app-url.example.com/mcp-app.html
```

Then attach the remote resource manifest:

```sh
reshapr attach -f apps/github-user/resources/app.remote.example.yaml
```
