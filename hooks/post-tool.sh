#!/bin/bash
# skill-manager: PostToolUse hook (fires on SUCCESS only)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/storage.sh"

if ! is_enabled; then
  exit 0
fi

ensure_dirs

INPUT=$(read_stdin)
SKILL_NAME=$(extract_json_field "$INPUT" "tool_input.skill")

if [ -z "$SKILL_NAME" ]; then
  exit 0
fi

# Calculate duration
END_MS=$(get_epoch_ms)
DURATION_MS=0
if [ -f "${TMP_DIR}/current_invocation.json" ]; then
  START_MS=$(extract_json_field "$(cat "${TMP_DIR}/current_invocation.json")" "start_ms")
  if [ -n "$START_MS" ] && [ "$START_MS" != "0" ]; then
    DURATION_MS=$((END_MS - START_MS))
  fi
  rm -f "${TMP_DIR}/current_invocation.json"
fi

WEEK=$(get_week)

# Get or create session
SESSION_ID=""
if [ -f "${TMP_DIR}/current_session" ]; then
  SESSION_ID=$(cat "${TMP_DIR}/current_session")
else
  SESSION_ID=$(generate_uuid)
  echo "$SESSION_ID" > "${TMP_DIR}/current_session"
  init_session_file "$SESSION_ID"
fi

log_debug "post-tool: skill=${SKILL_NAME} success=true duration=${DURATION_MS}ms"

append_to_chain "$SESSION_ID" "$SKILL_NAME" "true" "$DURATION_MS" "0"
update_weekly "$WEEK" "$SKILL_NAME" "true" "$DURATION_MS" "0"

exit 0
