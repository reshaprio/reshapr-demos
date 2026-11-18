# Demo 10: Petstore Skills over MCP

Serves a Skill next to the Petstore tools through reShapr. Requires reShapr 1.2.0 or later (the `Skills` artifact kind).

The Skill, `petstore-adoption-desk`, encodes a team procedure (find available pets, apply the desk rules, ask for confirmation, place one order) with two reference files. It is an example, not a Petstore feature.

## Run

Start reShapr locally (Demo 01), then run the demo:

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
4. After each edit to a Skill file, run `reshapr attach` again to refresh the cached digests.

## Files

- `skills/petstore-adoption-desk/`: the Skill (`SKILL.md` and `references/`).
- `resources/skills.remote.yaml`: attaches the Skill from the `skills-demo-1.2.0` Git tag URL, with no file server. Used by the demo.
- `resources/skills.local.yaml`: attaches the Skill from the local file server (`host.docker.internal:3040`, because the gateway runs in Docker). Use it to iterate.

## Notes

- Tool names are generated as `<method>_<path>` (for example `get_pet_findbystatus`), so the Skill uses those names.
- The Skill and its data are examples.
