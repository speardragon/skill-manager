---
name: share
effort: medium
description: "스킬 사용 리포트를 HTML 파일 또는 마크다운으로 내보내고 공유한다. 트리거: skill share, 리포트 공유, export report, 스킬 리포트 내보내기, 공유"
argument-hint: [--format html|markdown|image] [--scope full|skills|chains|health] [--output path] [--week YYYY-Www]
allowed-tools: Bash(open *)
---

# 스킬 리포트 공유

## 동작

1. `$ARGUMENTS`를 파싱하여 옵션을 결정한다
2. `~/.claude/plugins/skill-manager/weekly/` 및 `sessions/` 데이터를 읽는다
3. 지정된 형식으로 리포트를 생성한다
4. 출력 대상에 따라 파일 저장 또는 클립보드 복사를 수행한다

## 사용법

```
/skill-manager:share                          # 기본: 마크다운 → 클립보드
/skill-manager:share --format html            # HTML 파일 생성
/skill-manager:share --format markdown        # 마크다운 → 클립보드
/skill-manager:share --format image           # PNG 이미지로 저장
/skill-manager:share --output ./report.html   # 특정 경로에 저장
/skill-manager:share --output ./report.png    # 이미지 저장 경로 지정
/skill-manager:share --scope chains           # 체인 분석만
/skill-manager:share --week 2026-W12          # 특정 주 데이터
```

## 옵션

| 옵션       | 기본값     | 설명                                           |
| ---------- | ---------- | ---------------------------------------------- |
| `--format` | `markdown` | `html`, `markdown`, `image`                    |
| `--scope`  | `full`     | `full`, `skills`, `chains`, `health`           |
| `--output` | (없음)     | 파일 저장 경로. 없으면 클립보드 또는 기본 경로 |
| `--week`   | 현재 주    | 대상 주 (YYYY-Www)                             |

## 마크다운 리포트 형식

```markdown
## Skill Usage Report — 2026-W13

### 요약

- 총 호출: 142회
- 성공률: 89%
- 활성 스킬: 8/12
- 총 세션: 23

### 스킬별 통계

| 스킬           | 사용 | 성공률 | 평균 소요시간 |
| -------------- | ---- | ------ | ------------- |
| cs-register    | 25   | 96%    | 3.2s          |
| investigate-db | 22   | 91%    | 4.5s          |
| dev            | 18   | 83%    | 12.3s         |
| ...            | ...  | ...    | ...           |

### 주요 체인 패턴

1. **cs-register → investigate-db → dev → create-pr** (8회, 평균 45s)
2. **dev-setup → dev → create-pr** (5회, 평균 32s)

### 건강 요약

- 🔴 investigate-site: 성공률 45%
- 🟡 dev: 평균 소요시간 12.3s (전체 평균 4.1s)
```

## HTML 리포트 형식

- stats 대시보드와 동일한 디자인
- Chart.js를 **인라인으로** 포함 (CDN 의존 없이 standalone)
- 또는 CDN 참조를 유지하되, 오프라인 안내 문구 포함
- 파일 상단에 생성 일시와 데이터 기간 표시

## 이미지 저장 형식 (`--format image`)

HTML을 먼저 생성한 뒤 Chrome headless로 PNG 캡처한다.

**실행 순서**

1. `render.py stats`로 HTML을 `/tmp/skill-manager-report.html`에 생성
2. Chrome headless로 PNG 캡처:

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUTPUT="${output_path:-/tmp/skill-manager-report.png}"

"$CHROME" \
  --headless --disable-gpu \
  --screenshot="$OUTPUT" \
  --window-size=1400,900 \
  "file:///tmp/skill-manager-report.html" 2>/dev/null
```

3. 성공 시 `open "$OUTPUT"`으로 Finder에서 열기
4. `--scope chains`이면 `render.py chains`로 HTML 생성 후 동일하게 캡처

**Chrome 경로 우선순위**

1. `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
2. `$(which google-chrome 2>/dev/null)`
3. `$(which chromium 2>/dev/null)`

세 경로 모두 없으면 "Chrome을 찾을 수 없습니다. HTML 형식으로 대신 저장합니다."로 안내 후 HTML 저장으로 폴백.

**기본 출력 경로**: `--output` 미지정 시 `/tmp/skill-manager-report.png`

## 클립보드 복사

macOS 기준: `echo "$MARKDOWN_CONTENT" | pbcopy`
복사 완료 후 "리포트가 클립보드에 복사되었습니다." 안내.

## 데이터가 없을 때

"공유할 데이터가 없습니다. 스킬을 사용한 뒤 다시 시도해주세요." 라고 안내한다.
