#!/bin/bash
# skill-manager: local JSON storage via Python3

init_session_file() {
  local session_id="$1"
  local session_file="${SESSIONS_DIR}/$(get_date)_${session_id}.json"
  python3 -c "
import json
data = {
    'session_id': '$session_id',
    'started_at': '$(get_timestamp)',
    'ended_at': None,
    'chain': []
}
with open('$session_file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
}

append_to_chain() {
  local session_id="$1"
  local skill_name="$2"
  local success="$3"
  local duration_ms="$4"
  local tokens="${5:-0}"
  local session_file="${SESSIONS_DIR}/$(get_date)_${session_id}.json"

  [ ! -f "$session_file" ] && return 0

  python3 -c "
import json, os
session_file = '$session_file'
tmp_file = session_file + '.tmp'
try:
    with open(session_file) as f:
        data = json.load(f)
    data['chain'].append({
        'skill': '$skill_name',
        'success': '$success' == 'true',
        'duration_ms': int('$duration_ms'),
        'tokens': int('$tokens'),
        'timestamp': '$(get_timestamp)'
    })
    with open(tmp_file, 'w') as f:
        json.dump(data, f, indent=2)
    os.replace(tmp_file, session_file)
except Exception:
    pass
" 2>/dev/null
}

finalize_session() {
  local session_id="$1"
  local session_file="${SESSIONS_DIR}/$(get_date)_${session_id}.json"

  [ ! -f "$session_file" ] && return 0

  python3 -c "
import json, os
session_file = '$session_file'
tmp_file = session_file + '.tmp'
try:
    with open(session_file) as f:
        data = json.load(f)
    data['ended_at'] = '$(get_timestamp)'
    with open(tmp_file, 'w') as f:
        json.dump(data, f, indent=2)
    os.replace(tmp_file, session_file)
except Exception:
    pass
" 2>/dev/null
}

update_weekly() {
  local week="$1"
  local skill_name="$2"
  local success="$3"
  local duration_ms="$4"
  local tokens="${5:-0}"
  local weekly_file="${WEEKLY_DIR}/${week}.json"

  python3 -c "
import json, os

weekly_file = '$weekly_file'
tmp_file = weekly_file + '.tmp'

try:
    if os.path.exists(weekly_file):
        with open(weekly_file) as f:
            data = json.load(f)
    else:
        data = {'week': '$week', 'skills': {}, 'chains': {}}

    skill = '$skill_name'
    if skill not in data['skills']:
        data['skills'][skill] = {
            'usage_count': 0,
            'success_count': 0,
            'total_tokens': 0,
            'total_duration_ms': 0
        }

    s = data['skills'][skill]
    s['usage_count'] += 1
    if '$success' == 'true':
        s['success_count'] += 1
    s['total_tokens'] += int('$tokens')
    s['total_duration_ms'] += int('$duration_ms')

    with open(tmp_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp_file, weekly_file)
except Exception:
    pass
" 2>/dev/null
}

update_weekly_chains() {
  local week="$1"
  local chain_pattern="$2"
  local duration_ms="$3"
  local weekly_file="${WEEKLY_DIR}/${week}.json"

  python3 -c "
import json, os

weekly_file = '$weekly_file'
tmp_file = weekly_file + '.tmp'

try:
    if os.path.exists(weekly_file):
        with open(weekly_file) as f:
            data = json.load(f)
    else:
        data = {'week': '$week', 'skills': {}, 'chains': {}}

    pattern = '$chain_pattern'
    if pattern not in data['chains']:
        data['chains'][pattern] = {'count': 0, 'total_duration_ms': 0}

    c = data['chains'][pattern]
    c['count'] += 1
    c['total_duration_ms'] += int('$duration_ms')

    with open(tmp_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    os.replace(tmp_file, weekly_file)
except Exception:
    pass
" 2>/dev/null
}
