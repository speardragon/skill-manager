#!/bin/bash
# skill-manager: PreToolUse hook
# Records skill invocation start time

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"

if ! is_enabled; then
  exit 0
fi

ensure_dirs

INPUT=$(read_stdin)
SKILL_NAME=$(extract_json_field "$INPUT" "tool_input.skill")
START_MS=$(get_epoch_ms)

log_debug "pre-tool: skill=${SKILL_NAME}"

echo "{\"skill\":\"${SKILL_NAME}\",\"start_ms\":${START_MS}}" > "${TMP_DIR}/current_invocation.json"

exit 0
