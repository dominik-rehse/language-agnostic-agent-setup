# language-agnostic-agent-setup

Baseline rules for Claude Code: minimal-change principle, Conventional Commits,
documentation conventions, and Context7 MCP guidance for library lookups.

## Install

```text
/plugin marketplace add dominik-rehse/language-agnostic-agent-setup
/plugin install language-agnostic-agent-setup@language-agnostic-agent-setup
```

That's it — there is **no per-project setup**. A `SessionStart` hook injects the
rules in `rules/` into the session context live from the plugin, so the rules are
active from the first session and a plugin update applies on the next session.
Nothing is vendored into the project, so nothing goes stale.

(Legacy installs that vendored these rules into `.claude/rules/*.md` still work —
the hook skips any rule already present there to avoid double-loading. Delete the
vendored copy to switch that rule to live injection.)

## Skills

- `/language-agnostic-agent-setup:code-simplifier` — review the whole codebase
  and apply clarity and consistency simplifications while preserving behaviour.
  Pass a path to scope the pass to a subtree. Best run on a capable model, since
  it reasons across the entire repository.

## Upgrades

```text
/plugin marketplace update language-agnostic-agent-setup
/plugin update language-agnostic-agent-setup@language-agnostic-agent-setup
```

Start a new session afterwards; the rules load fresh from the updated plugin. The
plugin is versioned — bump `version` in `plugin.json` to ship a release.
