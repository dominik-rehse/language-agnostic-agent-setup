#!/bin/bash
# Project install for the language-agnostic-agent-setup plugin.
#
# Idempotent. Safe to re-run. Installs into the current working directory by
# default; pass the target as the first non-flag argument.
#
# Target flags (orthogonal to mode flags):
#   --claude    Install Claude Code project-local rules (.claude/rules/*.md)
#   --cursor    Install Cursor project-local rules (.cursor/rules/*.mdc)
#   --both      Install both. Default if no flag is given.
#
# Mode flags:
#   (default)   Write each file only if it doesn't already exist. Safe; never
#               clobbers operator edits. Initial install is what this is for.
#   --check     Dry-run. Report files that are absent or differ from upstream.
#               No writes. Exits 0 iff every file is byte-identical to upstream
#               (i.e. running --force would be a no-op). Use from CI to detect
#               rule drift.
#   --force     Overwrite every file, even if it already exists. Use after
#               --check confirms the only drift is upstream-side updates the
#               operator wants to pick up. Destructive if you've customised
#               rules locally — run --check first.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_DIR=""
WANT_CLAUDE=0
WANT_CURSOR=0
MODE="install"
DRIFT=0

for arg in "$@"; do
    case "$arg" in
        --claude) WANT_CLAUDE=1 ;;
        --cursor) WANT_CURSOR=1 ;;
        --both)   WANT_CLAUDE=1; WANT_CURSOR=1 ;;
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
            sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
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

if [ "$WANT_CLAUDE" -eq 0 ] && [ "$WANT_CURSOR" -eq 0 ]; then
    WANT_CLAUDE=1
    WANT_CURSOR=1
fi

TARGET_DIR="${TARGET_DIR:-${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$PWD}}}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

case "$MODE" in
    install) echo "language-agnostic-agent-setup: installing into $TARGET_DIR" ;;
    check)   echo "language-agnostic-agent-setup: checking $TARGET_DIR (read-only)" ;;
    force)   echo "language-agnostic-agent-setup: force-overwriting in $TARGET_DIR" ;;
esac

# Emit a Claude-flavoured rule: strip the leading YAML frontmatter (Cursor-only
# metadata) and any blank lines immediately following it.
emit_claude_rule() {
    local src="$1" dst="$2"
    awk '
        BEGIN { in_fm = 0; past_fm = 0; emitting = 0 }
        NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
        in_fm && /^---[[:space:]]*$/ { in_fm = 0; past_fm = 1; next }
        in_fm { next }
        past_fm && !emitting && /^[[:space:]]*$/ { next }
        { emitting = 1; print }
    ' "$src" > "$dst"
}

# Materialise the upstream form of `dst` into a tempfile so the caller can
# diff against it or rename it into place. Output path is stdout.
materialise_upstream() {
    local src="$1" mode="$2"
    local tmp
    tmp=$(mktemp)
    case "$mode" in
        claude) emit_claude_rule "$src" "$tmp" ;;
        cursor) cp "$src" "$tmp" ;;
    esac
    printf '%s\n' "$tmp"
}

install_rule() {
    local src="$1" dst="$2" mode="$3"
    case "$MODE" in
        install)
            if [ -e "$dst" ]; then
                echo "  skip   $dst (exists)"
                return
            fi
            mkdir -p "$(dirname "$dst")"
            case "$mode" in
                claude) emit_claude_rule "$src" "$dst" ;;
                cursor) cp "$src" "$dst" ;;
            esac
            echo "  write  $dst"
            ;;
        check)
            local upstream
            upstream=$(materialise_upstream "$src" "$mode")
            if [ ! -e "$dst" ]; then
                echo "  miss   $dst"
                DRIFT=1
            elif cmp -s "$dst" "$upstream"; then
                echo "  ok     $dst"
            else
                echo "  drift  $dst"
                diff -u "$dst" "$upstream" | sed 's/^/         /' || true
                DRIFT=1
            fi
            rm -f "$upstream"
            ;;
        force)
            mkdir -p "$(dirname "$dst")"
            local upstream
            upstream=$(materialise_upstream "$src" "$mode")
            if [ -e "$dst" ] && cmp -s "$dst" "$upstream"; then
                echo "  ok     $dst"
                rm -f "$upstream"
                return
            fi
            mv "$upstream" "$dst"
            echo "  write  $dst"
            ;;
    esac
}

if [ "$WANT_CLAUDE" -eq 1 ]; then
    mkdir -p "$TARGET_DIR/.claude/rules"
    for f in "$SOURCE_DIR/rules"/*.md; do
        [ -f "$f" ] || continue
        install_rule "$f" "$TARGET_DIR/.claude/rules/$(basename "$f")" claude
    done
fi

if [ "$WANT_CURSOR" -eq 1 ]; then
    mkdir -p "$TARGET_DIR/.cursor/rules"
    for f in "$SOURCE_DIR/rules"/*.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f" .md).mdc"
        install_rule "$f" "$TARGET_DIR/.cursor/rules/$name" cursor
    done
fi

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
