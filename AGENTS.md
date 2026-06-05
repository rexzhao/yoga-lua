# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Project-Specific Workflow

These rules capture lessons from the `yoga-lua` implementation so far.

### Milestone checklist

- `MILESTONES.md` is the live project checklist.
- Whenever a feature lands, a Yoga fixture is migrated, an unsupported case becomes supported, or the expected skipped count changes, update `MILESTONES.md` in the same change set.
- Do not mark a checklist item complete just because a demo looks correct. It needs implementation plus relevant tests or an explicit verification note.
- When adding a skipped fixture, also add or update the corresponding "Known skipped cases" item in `MILESTONES.md`.

### Commits and verification

- Keep commits small and intentional: tests/fixtures, implementation, Love2D demo, and docs/checklist updates should be separate when practical.
- Run `lua tests/run.lua` before committing behavior changes.
- Run `.\LOVE\lovec.exe .\examples\love2d --smoke` before committing Love2D visualizer changes.
- Local files `LOVE/` and `run-love2d.bat` are ignored and should not be committed.

### Fixture migration

- Use the ignored local upstream checkout at `.upstream/facebook-yoga/` for Yoga fixture and generated-test source when it exists.
- Local layout fixtures should include `source = { repo = "local", test = "..." }`.
- Migrated Yoga fixtures should include `source.repo`, `source.fixture`, `source.generated`, and `source.test`.
- If a relevant Yoga case cannot run yet, add it with `skip = true` and a specific `unsupportedReason`; do not silently omit important neighboring cases.
- Prefer migrating a small supported Yoga subset each time a layout feature lands instead of batching large unsupported test dumps.

### Love2D visualizer

- Put each visual UI layout in its own file under `examples/love2d/layouts/`.
- Start each Love2D layout file with a Chinese comment describing what the layout demonstrates.
- The selection screen and overlay should remain Yoga-rendered so the demo exercises the same layout path as application UI.
- For targeted visual checks, start a demo by name with `.\LOVE\lovec.exe .\examples\love2d --case <layout-id-or-title>`.
- For screenshot review, save to a temp path with `--screenshot <path>`, inspect the image, and do not commit generated screenshots.
- When a visual issue appears only at certain aspect ratios, treat it as a layout demo problem until proven otherwise, and test the fix with the smoke command.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
