#!/usr/bin/env bash
# Agent24 Save Hook
# Triggers on Claude Code "Stop" event. Every N human messages,
# blocks the stop and asks the AI to save important context to memory.
#
# Install: added to ~/.claude/settings.json by install.sh
# Based on MemPalace's save hook pattern (idempotent, no infinite loops)

set -euo pipefail

# Check python3 is available
if ! command -v python3 &>/dev/null; then
    echo '{"decision": "allow"}' >&2
    echo "WARNING: python3 not found — Agent24 auto-save disabled" >&2
    echo '{"decision": "allow"}'
    exit 0
fi

SAVE_INTERVAL="${AGENT24_SAVE_INTERVAL:-15}"
STATE_DIR="${HOME}/.claude/hook_state"
STATE_FILE="${STATE_DIR}/agent24_save.json"

mkdir -p "$STATE_DIR"

# Read input from Claude Code and pass ALL processing to a single Python
# script via stdin. No shell variable interpolation into Python code.
INPUT=$(cat)

echo "$INPUT" | SAVE_INTERVAL="$SAVE_INTERVAL" STATE_FILE="$STATE_FILE" \
python3 -c '
import json, sys, os, tempfile

save_interval = int(os.environ["SAVE_INTERVAL"])
state_file = os.environ["STATE_FILE"]

try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    print(json.dumps({"decision": "allow"}))
    sys.exit(0)

session_id = str(data.get("session_id", "unknown"))
stop_hook_active = data.get("stop_hook_active", False)
transcript_path = str(data.get("transcript_path", ""))

# Re-entry guard: if we already blocked, allow the stop
if stop_hook_active:
    print(json.dumps({"decision": "allow"}))
    sys.exit(0)

# Count human messages in transcript
msg_count = 0
if transcript_path and os.path.isfile(transcript_path):
    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    msg = json.loads(line.strip())
                    if msg.get("role") == "human":
                        msg_count += 1
                except (json.JSONDecodeError, ValueError):
                    pass
    except (OSError, PermissionError):
        pass

# Read last saved count
last_saved = 0
if os.path.isfile(state_file):
    try:
        with open(state_file) as f:
            state = json.load(f)
        last_saved = state.get(session_id, 0)
    except (json.JSONDecodeError, ValueError, OSError):
        pass

messages_since_save = msg_count - last_saved

if messages_since_save >= save_interval:
    # Atomic state update: write to temp file then rename
    state = {}
    if os.path.isfile(state_file):
        try:
            with open(state_file) as f:
                state = json.load(f)
        except (json.JSONDecodeError, ValueError, OSError):
            pass
    state[session_id] = msg_count
    tmp_fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(state_file))
    try:
        with os.fdopen(tmp_fd, "w") as f:
            json.dump(state, f)
        os.replace(tmp_path, state_file)
    except OSError:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass

    print(json.dumps({
        "decision": "block",
        "reason": "AUTO-SAVE checkpoint (Agent24). Before stopping, please save important context from this session:\n\n1. Key decisions made\n2. Important discoveries or insights\n3. Strategy outcomes (what worked, what failed)\n4. Any context that would be lost after this session\n\nWrite to memory files in ~/.claude/memory/ or .claude/memory/ using the standard front-matter format (name/description/type/created/valid_from/importance). Then update MEMORY.md index.\n\nAfter saving, you may stop."
    }))
else:
    print(json.dumps({"decision": "allow"}))
'
