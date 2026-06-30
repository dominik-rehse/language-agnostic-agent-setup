# Handoff: evaluate & test `language-agnostic-agent-setup`

**For the agent picking this up.** Evaluate this plugin and test it, applying the
lessons from the recent `stdd` v0.2 evaluation and rebuild (see
`~/repos/EVAL-FINDINGS.md` and `~/repos/stdd`). The owner's standing preferences:
**Claude Code only**, **reference don't restate** (dedup; canonical home +
pointers), and **conscious versioning**. Ground every claim in primary evidence
(files, transcripts, git history). A well-evidenced "this isn't earning its keep"
is a valid finding.

## What this plugin is

A setup plugin that vendors agent-agnostic baseline rules into a project:
`/language-agnostic-agent-setup:setup` runs `scripts/install.sh`, copying
`rules/*.md` (`core.md`, `dependency-docs.md`, `docs.md`, `git-commits.md`) into
`.claude/rules/`. It also ships two skills (`setup`, `code-simplifier`). Unlike
its bun-ts sibling it installs **no hooks, no test gate, no tooling** — just
prose rules. Notably its `install.sh` already has **`--check` (read-only drift
detection) and `--force`** modes, which the bun-ts plugin lacks.

Evidence base: this repo; the consuming repos (`~/repos/{agent,email-to-file,
capital-provider-db}`); transcripts under
`~/.claude/projects/-home-dominik-repos-language-agnostic-agent-setup`.

## Composition with stdd (the integration angle)

Assess — don't assume. This plugin has **no hooks, no test gate, and no testing
rules**, so it has essentially no mechanical surface to collide with stdd (the
opposite of bun-ts). Its rules are methodology-neutral and mostly *complement*
stdd: `docs.md`'s "refer instead of repeating" aligns with stdd's spec
self-containment; `core.md`'s "smallest change" / "ask 1–3 questions" compose
with the TDD loop. The one near-overlap to evaluate: `core.md`'s "When fixing
bugs, run the required tests one final time before declaring victory" is *weaker*
than stdd's new test-first bug-fix rule — decide whether to defer to stdd when
present, or leave it (it's harmless baseline advice). **Recommendation to verify:
this plugin likely needs no code change for stdd integration** — confirm that and
say so plainly rather than inventing one.

## What to evaluate

1. **CC-native residue.** Git history shows Cursor support was dropped
   (`d7cd6c8 refactor: drop Cursor support`), but a stale **untracked
   `.cursor/rules/` directory** still sits in the working tree (not shipped — not
   in `git ls-files` — but a local leftover). Confirm and clean. Grep all rules
   for any remaining cross-agent phrasing.

2. **`code-simplifier` skill vs the built-in `/simplify`.** Claude Code ships a
   `/simplify` command. Evaluate whether this skill duplicates, diverges from, or
   conflicts with it — and whether it earns its place or should defer to the
   built-in (a reference-don't-restate question at the tooling level).

3. **Update mechanism & versioning.** Unversioned, no SessionStart hook — so like
   bun-ts, updates only land by re-running setup. But this plugin *does* have
   `--check`/`--force`. Evaluate: is `--check` actually wired into any CI as the
   "rules in sync" guard its help text advertises? Is the drift workflow
   documented for users? Should it be versioned, given there's no hook to
   self-heal? (This is the same decision stdd faced; the answer may differ
   because these are pure prose rules.)

4. **Dedup / reference-don't-restate.** Cross-check the four rules against each
   other, against the bun-ts plugin's rules, and against stdd's rules now
   co-resident in `.claude/rules/` — for overlap or contradiction. `docs.md`'s
   DRY stance is the principle to hold the *plugins themselves* to: are any
   concepts restated across plugins that should live in one canonical file?

5. **Intended vs observed use.** Mine the 6 transcripts and the consuming repos:
   are these baseline rules actually shaping behaviour, or are they inert context
   that never changes an outcome? `git-commits.md` (Conventional Commits) is the
   most checkable — do the consuming repos' commit histories actually follow it?
   `dependency-docs.md` mandates Context7 MCP — was it ever used?

6. **`.claude/settings.local.json` in the repo.** The plugin repo contains
   `.claude/settings.local.json` (not tracked). Confirm it's dev-only and not
   accidentally shipped/needed, and that nothing in the plugin depends on it.

## Deliverable

A findings report: TL;DR, then per-area findings with file/line/transcript
evidence, then prioritized recommendations split into (a) changes to this plugin
and (b) how it composes with stdd and `bun-typescript-agent-setup`. Be willing to
conclude "no integration change needed here." Flag thin evidence. Slash commands
are user-invoked.
