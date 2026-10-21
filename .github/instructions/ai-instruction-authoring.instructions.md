---
applyTo: "{.github/instructions/*.md,.github/prompts/*.md,.github/skills/*.md,**/AGENTS.md,.github/copilot-instructions.md}"
---

# AI Instruction Authoring

- Write AI-only directives, not human-facing tutorials.
- Use short imperative bullets.
- Remove filler, redundant qualifiers, and repeated context.
- Explain rationale only when it changes behavior.
- Check existing instructions before adding rules. Update existing rules instead of duplicating them.
- Use the narrowest practical `applyTo` glob.
- `applyTo` must be a string, never an array.
- Except for `.github/copilot-instructions.md` and `AGENTS.md`, start each instruction file with YAML frontmatter containing `applyTo`.
- Use `##` and `###` headings, backticks for tokens, and fenced blocks only for necessary multi-line examples.
- Avoid bold, italic, conversational prose, and verbose examples.
- Prefer ASCII in instructions, prompts, skills, `AGENTS.md`, `.ps1` files, and `CHANGELOG.md`.
- Use straight quotes, `->`, and ordinary hyphens.
