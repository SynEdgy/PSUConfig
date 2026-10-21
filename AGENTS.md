# Agent Instructions

Authoritative guidance for AI agents working in this repository lives in:

- [`.github/copilot-instructions.md`](.github/copilot-instructions.md) — repo-wide overview, build/test/deploy commands, architecture.
- [`.github/instructions/`](.github/instructions/) — scoped instruction files (each declares its own `applyTo` glob):
  - `public-functions.instructions.md` — `source/Public/*.ps1`
  - `private-functions.instructions.md` — `source/Private/*.ps1`
  - `data-access.instructions.md` — `synedgy.PSSqlite` CRUD usage in `source/{Public,Private}/**/*.ps1`
  - `universal-scripts.instructions.md` — `source/.universal/*.ps1`
  - `sqlite-config.instructions.md` — `source/config/*.PSSqliteConfig.y*ml`
  - `test-writing.instructions.md` — `tests/**/*.Tests.ps1`
  - `ai-instruction-authoring.instructions.md` — rules for editing the files above
- [`.github/skills/validate-changes/SKILL.md`](.github/skills/validate-changes/SKILL.md) — how to validate a change: pick the right test scope, stream `./build.ps1` output safely, and read NUnit XML in `output/testResults/`.
- [`.github/agents/psuconfig-maintainer.md`](.github/agents/psuconfig-maintainer.md) — user-invocable maintainer agent for safe, repo-aware changes across functions, `.universal` wiring, SQLite schema, and tests.

Read `.github/copilot-instructions.md` first, then load any scoped file whose `applyTo` matches the files you are about to change. Run the `validate-changes` skill before reporting a task complete. Do not duplicate guidance here; update the source files instead.
