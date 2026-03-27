# skill-manager

Claude Code 스킬 워크플로 효율성 분석 플러그인.

## 기능

| 커맨드                  | 설명                                 |
| ----------------------- | ------------------------------------ |
| `/skill-manager:stats`  | 사용 통계 대시보드 (브라우저)        |
| `/skill-manager:chains` | 스킬 체인 패턴 시각화 (브라우저)     |
| `/skill-manager:health` | 스킬 건강 진단 리포트 (터미널)       |
| `/skill-manager:share`  | 리포트 내보내기/공유 (HTML/마크다운) |

## 설치

```bash
/plugin marketplace add speardragon/skill-manager
/plugin install skill-manager
```

## 데이터 수집

훅(PreToolUse, PostToolUse, Stop)을 통해 스킬 호출을 자동 추적한다.

**수집 항목:** 스킬 이름, 성공/실패, 소요시간, 체인 패턴
**미수집 항목:** 프롬프트, 코드 내용, 파일 경로

## 저장 위치

```
~/.claude/plugins/skill-manager/
├── sessions/      # 세션별 기록
│   └── 2026-03-25_uuid.json
└── monthly/       # 월간 집계
    └── 2026-03.json
```

## 설정

`config/settings.env`:

```bash
SKILL_MANAGER_ENABLED=true        # 추적 on/off
SKILL_MANAGER_MIN_CHAIN_LENGTH=2  # 최소 체인 길이
SKILL_MANAGER_RETENTION_DAYS=90   # 데이터 보관 기간
```

## 요구사항

- macOS/Linux
- Python 3
- Bash
