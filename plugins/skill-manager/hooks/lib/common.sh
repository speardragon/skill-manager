#!/bin/bash
# skill-manager: shared utilities

read_stdin() {
  local data=""
  while IFS= read -r line; do
    data="${data}${line}"
  done
  echo "$data"
}

extract_json_field() {
  local json="$1"
  local field="$2"
  python3 -c "
import json, sys
try:
    d = json.loads(sys.argv[1])
    keys = sys.argv[2].split('.')
    val = d
    for k in keys:
        if isinstance(val, dict):
            val = val.get(k, '')
        else:
            val = ''
            break
    print(val if val is not None else '')
except:
    print('')
" "$json" "$field" 2>/dev/null
}

generate_uuid() {
  if command -v uuidgen &>/dev/null; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null
  fi
}

get_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

get_epoch_ms() {
  python3 -c "import time; print(int(time.time()*1000))" 2>/dev/null
}

get_date() {
  date -u +"%Y-%m-%d"
}

get_week() {
  python3 -c "from datetime import datetime; print(datetime.utcnow().strftime('%G-W%V'))" 2>/dev/null
}

log_debug() {
  if [ "${SKILL_MANAGER_DEBUG:-false}" = "true" ]; then
    echo "[skill-manager] $*" >&2
  fi
}
