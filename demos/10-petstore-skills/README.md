# Demo 10: Petstore Skills over MCP

Serves a Skill next to the Petstore tools through reShapr. Requires reShapr 1.2.0 or later (the `Skills` artifact kind).

The Skill, `petstore-adoption-desk`, encodes a team procedure (find available pets, apply the desk rules, ask for confirmation, place one order) with two reference files. It is an example, not a Petstore feature.

## Run

Start reShapr locally (Demo 01), then start the Skill file server in a separate terminal:

```sh
npm run start:petstore-skills
```

Run the demo:

```sh
./demos/10-petstore-skills/demo.sh
```

Or use the npm alias from the repository root:

```sh
npm run demo:10
```

## Files

- `skills/petstore-adoption-desk/`: the Skill (`SKILL.md` and `references/`).
- `resources/skills.local.yaml`: attaches the Skill from the local file server (`host.docker.internal:3040`, because the gateway runs in Docker).
- `resources/skills.remote.yaml`: attaches the same Skill from a Git tag URL, with no file server.

## Notes

- Tool names are generated as `<method>_<path>` (for example `get_pet_findbystatus`), so the Skill uses those names.
- If you edit a Skill file, run `reshapr attach` again to refresh the cached digests.
