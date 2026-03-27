#!/usr/bin/env python3
"""
skill-manager render.py
Usage: python3 render.py <stats|chains> [--month YYYY-MM]
Reads monthly data, injects into HTML template, writes to /tmp/
"""

import json
import os
import re
import sys
import argparse
from datetime import datetime, timedelta

SKILL_MANAGER_HOME = os.path.expanduser("~/.claude/plugins/skill-manager")
WEEKLY_DIR = os.path.join(SKILL_MANAGER_HOME, "weekly")
SESSIONS_DIR = os.path.join(SKILL_MANAGER_HOME, "sessions")

PLUGIN_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILLS_DIR = os.path.join(PLUGIN_ROOT, "skills")

OUTPUT_FILES = {
    "stats":  "/tmp/skill-manager-dashboard.html",
    "chains": "/tmp/skill-manager-chains.html",
}


def load_weekly(week: str) -> dict:
    path = os.path.join(WEEKLY_DIR, f"{week}.json")
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return json.load(f)


def list_available_weeks() -> list:
    """weekly/ 디렉토리에서 사용 가능한 주 목록을 내림차순으로 반환."""
    if not os.path.exists(WEEKLY_DIR):
        return []
    weeks = [
        fn[:-5]  # strip .json
        for fn in os.listdir(WEEKLY_DIR)
        if fn.endswith(".json") and re.match(r"^\d{4}-W\d{2}$", fn[:-5])
    ]
    return sorted(weeks, reverse=True)


def week_to_dates(week: str) -> list:
    """YYYY-Www → 해당 주의 날짜 문자열 목록 (YYYY-MM-DD, 월~일)."""
    d = datetime.strptime(f"{week}-1", "%G-W%V-%u")
    return [(d + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)]


def count_sessions(week: str) -> int:
    if not os.path.exists(SESSIONS_DIR):
        return 0
    dates = set(week_to_dates(week))
    return sum(
        1 for fn in os.listdir(SESSIONS_DIR)
        if fn.endswith(".json") and fn[:10] in dates
    )


def render_stats(week: str) -> str:
    available_weeks = list_available_weeks()
    if not available_weeks:
        available_weeks = [week]

    all_data = {}
    for w in available_weeks:
        d = load_weekly(w)
        if d and d.get("skills"):
            all_data[w] = {
                "week": d.get("week", w),
                "skills": d.get("skills", {}),
                "session_count": count_sessions(w),
            }

    current = week if week in all_data else (available_weeks[0] if all_data else week)
    payload = {
        "current": current,
        "weeks": available_weeks,
        "data": all_data,
    }

    template_path = os.path.join(SKILLS_DIR, "stats", "assets", "stats.html")
    with open(template_path) as f:
        html = f.read()

    html = html.replace("__STATS_DATA__", json.dumps(payload, ensure_ascii=False))
    return html


def render_chains(week: str) -> str:
    available_weeks = list_available_weeks()
    if not available_weeks:
        available_weeks = [week]

    all_data = {}
    for w in available_weeks:
        d = load_weekly(w)
        if d and d.get("chains"):
            all_data[w] = {
                "week": d.get("week", w),
                "chains": d.get("chains", {}),
            }

    current = week if week in all_data else (available_weeks[0] if all_data else week)
    payload = {
        "current": current,
        "weeks": available_weeks,
        "data": all_data,
    }

    template_path = os.path.join(SKILLS_DIR, "chains", "assets", "chains.html")
    with open(template_path) as f:
        html = f.read()

    html = html.replace("__CHAINS_DATA__", json.dumps(payload, ensure_ascii=False))
    return html


def main():
    parser = argparse.ArgumentParser(description="skill-manager HTML renderer")
    parser.add_argument("view", choices=["stats", "chains"])
    parser.add_argument("--week", default=datetime.now().strftime("%G-W%V"))
    args = parser.parse_args()

    if args.view == "stats":
        html = render_stats(args.week)
    else:
        html = render_chains(args.week)

    out_path = OUTPUT_FILES[args.view]
    with open(out_path, "w") as f:
        f.write(html)

    print(out_path)


if __name__ == "__main__":
    main()
