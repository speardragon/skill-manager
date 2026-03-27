#!/bin/bash
# skill-manager: Stop hook
# Finalizes session and computes chain statistics

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/storage.sh"

if ! is_enabled; then
  exit 0
fi

SESSION_ID=""
if [ -f "${TMP_DIR}/current_session" ]; then
  SESSION_ID=$(cat "${TMP_DIR}/current_session")
fi

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

WEEK=$(get_week)
TODAY=$(get_date)

finalize_session "$SESSION_ID"

# Compute chain pattern and update weekly chains
python3 -c "
import json, os, sys

session_file = os.path.join('${SESSIONS_DIR}', '${TODAY}_${SESSION_ID}.json')
if not os.path.exists(session_file):
    sys.exit(0)

with open(session_file) as f:
    data = json.load(f)

chain = data.get('chain', [])
min_len = int('${SKILL_MANAGER_MIN_CHAIN_LENGTH:-2}')

if len(chain) >= min_len:
    pattern = ' \u2192 '.join(item['skill'] for item in chain)
    total_dur = sum(item.get('duration_ms', 0) for item in chain)
    print(json.dumps({'pattern': pattern, 'duration_ms': total_dur}))
" 2>/dev/null | while IFS= read -r LINE; do
  PATTERN=$(extract_json_field "$LINE" "pattern")
  DUR=$(extract_json_field "$LINE" "duration_ms")
  if [ -n "$PATTERN" ]; then
    update_weekly_chains "$WEEK" "$PATTERN" "$DUR"
    log_debug "session-stop: chain=${PATTERN}"
  fi
done

rm -f "${TMP_DIR}/current_session" "${TMP_DIR}/current_invocation.json"

log_debug "session-stop: finalized session=${SESSION_ID}"
exit 0
