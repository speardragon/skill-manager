---
name: health
effort: low
description: "스킬 상태 진단 리포트를 터미널에 출력한다. 실패율, 미사용 스킬, 비정상 소요시간을 감지한다. 트리거: skill health, 스킬 진단, health check, 스킬 상태"
---

# 스킬 건강 진단

## 동작

1. `~/.claude/plugins/skill-manager/weekly/` 에서 현재 주 데이터를 읽는다
2. 등록된 스킬 목록을 `.claude/skills/` 디렉토리에서 가져온다
3. 건강 지표를 계산하고 터미널에 포맷팅된 리포트를 출력한다 (HTML 아님)

## 데이터가 없을 때

"아직 수집된 데이터가 없습니다." 라고 안내한다.

## 진단 항목

### 1. 위험 (CRITICAL)
- 성공률 < 50% → `🔴 CRITICAL: {skill} 성공률 {rate}%`

### 2. 경고 (WARNING)
- 성공률 50~70% → `🟡 WARNING: {skill} 성공률 {rate}%`
- 평균 소요시간이 전체 평균의 3배 이상 → `🟡 SLOW: {skill} 평균 {avg}s (전체 평균 {global_avg}s)`

### 3. 정보 (INFO)
- 등록되어 있지만 이번 주 사용되지 않은 스킬 → `⚪ UNUSED: {skill}`
- 1회만 사용된 스킬 → `🔵 LOW USAGE: {skill} (1회)`

### 4. 건강 (HEALTHY)
- 성공률 > 90%, 정상 소요시간 → `🟢 HEALTHY: {skill}`

## 출력 형식

```
╔══════════════════════════════════════╗
║       Skill Health Report            ║
║       2026-03                        ║
╠══════════════════════════════════════╣
║ Total Skills: 12  |  Active: 8       ║
║ Overall Success Rate: 87%            ║
╠══════════════════════════════════════╣

  🔴 CRITICAL
  └─ investigate-site: 성공률 45% (9/20)

  🟡 WARNING
  └─ dev: 평균 12.3s (전체 평균 4.1s)

  ⚪ UNUSED
  ├─ classroom-copy
  └─ aidt-channel-create

  🟢 HEALTHY (6 skills)
  ├─ cs-register: 성공률 95% | 평균 3.2s
  ├─ investigate-db: 성공률 92% | 평균 4.5s
  └─ ...

╠══════════════════════════════════════╣
║ 권장사항                              ║
╠══════════════════════════════════════╣
  1. investigate-site 실패 원인 조사 필요
  2. dev 스킬 소요시간 최적화 검토
╚══════════════════════════════════════╝
```

## 등록된 스킬 경로

프로젝트 루트 기준: `.claude/skills/` 디렉토리의 하위 폴더명이 곧 스킬 이름이다.
현재 워크스페이스가 아닌 aidt-docs 레포 기준으로 확인해야 할 수 있으므로,
`~/.claude/plugins/skill-manager/` 경로에 데이터가 있는 스킬 목록도 함께 참조한다.
