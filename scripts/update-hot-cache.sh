#!/usr/bin/env bash
# Regenerate wiki/hot.md from the current session transcript.
# Invoked by the Stop hook. Must exit 0 even on failure so we don't break the session.
#
# Uses $CLAUDE_PROJECT_DIR (set by Claude Code for hooks) so the script is
# portable across clones. Falls back to $PWD if not set.

set -u
VAULT="${CLAUDE_PROJECT_DIR:-$PWD}"
HOT="$VAULT/wiki/hot.md"

# Claude Code passes hook input as JSON on stdin. Read it.
HOOK_INPUT="$(cat 2>/dev/null || true)"

# Extract transcript path. Try jq first, fall back to grep.
TRANSCRIPT_PATH=""
if command -v jq >/dev/null 2>&1; then
  TRANSCRIPT_PATH="$(printf '%s' "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
fi
if [[ -z "$TRANSCRIPT_PATH" ]]; then
  TRANSCRIPT_PATH="$(printf '%s' "$HOOK_INPUT" | grep -oE '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]+"' | sed 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || true)"
fi

# If no transcript or no vault, bail quietly.
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" || ! -f "$HOT" ]]; then
  exit 0
fi

PREVIOUS="$(cat "$HOT" 2>/dev/null || true)"
TODAY="$(date +%Y-%m-%d)"

PROMPT="You are rewriting wiki/hot.md - a short-term memory cache for this LLM wiki.

Input:
- Session transcript: $TRANSCRIPT_PATH (read it)
- Previous hot.md contents (below between <<< >>>)

Task: produce the NEW hot.md content. Keep it under 400 lines. Preserve the frontmatter exactly, but update date_modified to $TODAY. Three sections:

1. '## Last session' - 5-10 bullets. What was worked on, what was decided, what changed in wiki/ or raw/.
2. '## Recent decisions' - carry forward from previous hot.md, prune items older than ~3 sessions, add any new decisions from this session.
3. '## Open threads' - unresolved questions, WIP items, things to come back to.

Output ONLY the new file contents starting with '---' frontmatter. No commentary, no markdown code fence.

Previous hot.md:
<<<
$PREVIOUS
>>>"

# Fire-and-forget in background with a hard timeout so the hook never blocks shutdown.
(
  NEW_CONTENT="$(timeout 90 claude -p "$PROMPT" --output-format text 2>/dev/null || true)"
  if [[ -n "$NEW_CONTENT" && "$NEW_CONTENT" == ---* ]]; then
    printf '%s\n' "$NEW_CONTENT" > "$HOT"
  fi
) &

exit 0
