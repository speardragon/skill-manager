---
name: chains
effort: medium
description: "스킬 체인 패턴을 시각화하고 워크플로 병목을 분석한다. 트리거: skill chains, 체인 분석, workflow chains, 워크플로 패턴"
allowed-tools: Bash(open *)
---

# 스킬 체인 분석

## 동작

아래 명령을 순서대로 실행한다.

**1단계: render.py로 HTML 생성**

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/render.py" chains
```

성공하면 `/tmp/skill-manager-chains.html` 경로가 출력된다.

특정 주를 보려면:
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/render.py" chains --week 2026-W12
```

**2단계: 브라우저에서 열기**

```bash
open /tmp/skill-manager-chains.html
```

## 데이터가 없을 때

render.py가 정상 실행되더라도 체인 데이터가 없으면 HTML 내에 안내 화면이 표시된다. 별도 안내 불필요.

## 오류 처리

- `python3` 명령 실패 → `~/.claude/plugins/skill-manager/weekly/` 경로에 파일이 있는지 확인 후 안내
- `${CLAUDE_PLUGIN_ROOT}` 미설정 → 절대 경로로 직접 지정하여 재시도
