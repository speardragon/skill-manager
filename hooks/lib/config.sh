#!/bin/bash
# skill-manager: configuration

SKILL_MANAGER_HOME="${HOME}/.claude/plugins/skill-manager"
SESSIONS_DIR="${SKILL_MANAGER_HOME}/sessions"
WEEKLY_DIR="${SKILL_MANAGER_HOME}/weekly"
TMP_DIR="/tmp/skill-manager"

ensure_dirs() {
  mkdir -p "$SESSIONS_DIR" "$WEEKLY_DIR" "$TMP_DIR"
}

# Load settings.env if available
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "${CLAUDE_PLUGIN_ROOT}/config/settings.env" ]; then
  source "${CLAUDE_PLUGIN_ROOT}/config/settings.env"
fi

# Check if tracking is enabled
is_enabled() {
  [ "${SKILL_MANAGER_ENABLED:-true}" = "true" ]
}
