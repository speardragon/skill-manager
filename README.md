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
/plugin install skill-manager@skill-manager
```

## 데이터 수집

훅(PreToolUse, PostToolUse, PostToolUseFailure, Stop)을 통해 스킬 호출을 자동 추적한다.

**수집 항목:** 스킬 이름, 성공/실패, 소요시간, 체인 패턴
**미수집 항목:** 프롬프트, 코드 내용, 파일 경로

## 저장 위치

```
~/.claude/plugins/skill-manager/
├── sessions/      # 세션별 기록
│   └── 2026-03-27_uuid.json
└── weekly/        # 주간 집계
    └── 2026-W13.json
```

## 설정

`config/settings.env`:

```bash
SKILL_MANAGER_ENABLED=true        # 추적 on/off
SKILL_MANAGER_MIN_CHAIN_LENGTH=2  # 최소 체인 길이
SKILL_MANAGER_RETENTION_DAYS=90   # 데이터 보관 기간
```

## share 옵션

```
/skill-manager:share                          # 기본: 마크다운 → 클립보드
/skill-manager:share --format html            # HTML 파일 생성
/skill-manager:share --format markdown        # 마크다운 → 클립보드
/skill-manager:share --format image           # PNG 이미지로 저장
/skill-manager:share --output ./report.html   # 특정 경로에 저장
/skill-manager:share --scope chains           # 체인 분석만
/skill-manager:share --week 2026-W12          # 특정 주 데이터
```

## 요구사항

- macOS/Linux
- Python 3
- Bash
