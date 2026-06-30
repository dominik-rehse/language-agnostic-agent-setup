#!/bin/bash
# Project install for the language-agnostic-agent-setup plugin.
#
# Idempotent. Safe to re-run. Installs Claude Code project-local rules into
# .claude/rules/*.md in the current working directory by default; pass the
# target directory as the first non-flag argument.
#
# Mode flags:
#   (default)   Write each file only if it doesn't already exist. Safe; never
#               clobbers operator edits. Initial install is what this is for.
#   --check     Dry-run. Report files that are absent or differ from upstream.
#               No writes. Exits 0 iff every file is byte-identical to upstream
#               (i.e. running --force would be a no-op). Run before --force to
#               preview what it would change.
#   --force     Overwrite every file, even if it already exists. Use after
#               --check confirms the only drift is upstream-side updates the
#               operator wants to pick up. Destructive if you've customised
#               rules locally — run --check first.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_DIR=""
MODE="install"
DRIFT=0

for arg in "$@"; do
    case "$arg" in
        --check)
            if [ "$MODE" != "install" ]; then
                echo "language-agnostic-agent-setup install: --check and --force are mutually exclusive" >&2
                exit 1
            fi
            MODE="check"
            ;;
        --force)
            if [ "$MODE" != "install" ]; then
                echo "language-agnostic-agent-setup install: --check and --force are mutually exclusive" >&2
                exit 1
            fi
            MODE="force"
            ;;
        --help|-h)
            sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        --*)
            echo "language-agnostic-agent-setup install: unknown flag: $arg" >&2
            exit 1
            ;;
        *)
            TARGET_DIR="$arg"
            ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-${CLAUDE_PROJECT_DIR:-$PWD}}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

case "$MODE" in
    install) echo "language-agnostic-agent-setup: installing into $TARGET_DIR" ;;
    check)   echo "language-agnostic-agent-setup: checking $TARGET_DIR (read-only)" ;;
    force)   echo "language-agnostic-agent-setup: force-overwriting in $TARGET_DIR" ;;
esac

install_rule() {
    local src="$1" dst="$2"
    case "$MODE" in
        install)
            if [ -e "$dst" ]; then
                echo "  skip   $dst (exists)"
                return
            fi
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            echo "  write  $dst"
            ;;
        check)
            if [ ! -e "$dst" ]; then
                echo "  miss   $dst"
                DRIFT=1
            elif cmp -s "$dst" "$src"; then
                echo "  ok     $dst"
            else
                echo "  drift  $dst"
                diff -u "$dst" "$src" | sed 's/^/         /' || true
                DRIFT=1
            fi
            ;;
        force)
            mkdir -p "$(dirname "$dst")"
            if [ -e "$dst" ] && cmp -s "$dst" "$src"; then
                echo "  ok     $dst"
                return
            fi
            cp "$src" "$dst"
            echo "  write  $dst"
            ;;
    esac
}

mkdir -p "$TARGET_DIR/.claude/rules"
for f in "$SOURCE_DIR/rules"/*.md; do
    [ -f "$f" ] || continue
    install_rule "$f" "$TARGET_DIR/.claude/rules/$(basename "$f")"
done

case "$MODE" in
    install) echo "language-agnostic-agent-setup: installed." ;;
    force)   echo "language-agnostic-agent-setup: installed (force)." ;;
    check)
        if [ "$DRIFT" -eq 0 ]; then
            echo "language-agnostic-agent-setup: in sync with upstream."
            exit 0
        else
            echo "language-agnostic-agent-setup: drift detected. Run --force to overwrite." >&2
            exit 1
        fi
        ;;
esac
