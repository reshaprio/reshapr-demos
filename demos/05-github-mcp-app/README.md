# Demo 05: GitHub MCP App

Run this after Demo 03, which imports the GitHub GraphQL service and attaches the `get_user_with_latest_followers` custom tool.

All MCP app servers use port 3030, so stop any other app server before starting this one.

Start the app server in another terminal first:

```sh
npm run start:github-user
```

Run from this directory:

```sh
./demo.sh
```

Run from the repository root:

```sh
./demos/05-github-mcp-app/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:05
```
