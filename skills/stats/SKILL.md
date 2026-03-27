---
name: stats
effort: medium
description: "스킬 사용 통계 대시보드를 생성하고 브라우저에서 연다. 트리거: skill stats, 스킬 통계, 사용량 대시보드, skill analytics"
allowed-tools: Bash(open *)
---

# 스킬 사용 통계 대시보드

## 동작

아래 명령을 순서대로 실행한다.

**1단계: render.py로 HTML 생성**

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/render.py" stats
```

성공하면 `/tmp/skill-manager-dashboard.html` 경로가 출력된다.

특정 주를 보려면:
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/render.py" stats --week 2026-W12
```

**2단계: 브라우저에서 열기**

```bash
open /tmp/skill-manager-dashboard.html
```

## 데이터가 없을 때

render.py가 정상 실행되더라도 데이터가 없으면 HTML 내에 "아직 수집된 데이터가 없습니다." 화면이 표시된다. 별도 안내 불필요.

## 오류 처리

- `python3` 명령 실패 → `~/.claude/plugins/skill-manager/weekly/` 경로에 파일이 있는지 확인 후 안내
- `${CLAUDE_PLUGIN_ROOT}` 미설정 → 절대 경로로 직접 지정하여 재시도
