# Demo 10: Petstore Skills over MCP

Serves a Skill next to the Petstore tools through reShapr. Requires reShapr 1.2.0 or later (the `Skills` artifact kind). Tested with reShapr 1.2.1.

The blog post [Skills over MCP in reShapr 1.2](https://reshapr.io/blog/reshapr-skills-over-mcp/) explains the feature and what an agent does with this Skill.

The Skill, `petstore-adoption-desk`, encodes a team procedure (find available pets, apply the desk rules, ask for confirmation, place one order) with two reference files. It is an example, not a Petstore feature.

## Run

Start reShapr locally (Demo 01), then run the demo. It pauses between steps: press Enter to continue.

```sh
./demos/10-petstore-skills/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:10
```

The demo attaches the Skill from the Git tag `skills-demo-1.2.0` of this repository, so no file server is needed.

## Edit and iterate on the Skill

To change the Skill and see your edits without a commit or a tag, serve it from your machine:

1. Delete the Skills artifact you attached before (`reshapr artifact list -s <serviceId>`, then `reshapr artifact delete <id>`), so the Service has one manifest for this Skill.
2. Start the file server in a separate terminal: `npm run start:petstore-skills`.
3. Attach `resources/skills.local.yaml`: `reshapr attach -f ./demos/10-petstore-skills/resources/skills.local.yaml`.
4. After each edit to a Skill file, wait up to 30 seconds: the runtime caches skill files for 30 seconds by default, then fetches them again. If you change the manifest (for example to add a file), run `reshapr attach` again with the same file name.

## Files

- `skills/petstore-adoption-desk/`: the Skill (`SKILL.md` and `references/`).
- `resources/skills.remote.yaml`: attaches the Skill from the `skills-demo-1.2.0` Git tag URL, with no file server. Used by the demo.
- `resources/skills.local.yaml`: attaches the Skill from the local file server (`host.docker.internal:3040`, because the reShapr runtime runs in a container). Use it to iterate. `host.docker.internal` is the Docker name for your machine: with another engine, change it to the name that engine gives the host, for example `host.containers.internal` with Podman, or `host.container.internal` with apple/container, which needs a one-time `sudo` DNS setup ([apple/container host integration](https://github.com/apple/container/blob/main/docs/host-integration.md)).

## Notes

- Tool names are generated as `<method>_<path>` (for example `get_pet_findbystatus`), so the Skill uses those names.
- The Skill and its data are examples.
