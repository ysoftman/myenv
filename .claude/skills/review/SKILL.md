---
name: review
description: Review GitHub PRs and track improvements as tasks
allowed-tools: Bash(gh:*), Read, Glob, Grep, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# PR Review

GitHub Pull Request를 리뷰하고, 발견된 개선사항을 task로 관리한다.

Input: $ARGUMENTS

## 인자 파싱 규칙

- 인자 없음: PR 목록을 표시하고 리뷰할 PR을 선택하게 한다
- 숫자(예: `108`): 해당 PR을 바로 리뷰한다
- URL(예: `https://github.com/.../pull/108`): URL에서 PR 번호를 추출하여 리뷰한다

## 실행 절차

### 1. PR 리뷰

메인 에이전트가 직접 리뷰를 수행한다:

1. `gh pr view <number>`로 PR 상세 정보를 확인한다
2. `gh pr diff <number>`로 변경 내용을 가져온다
3. 변경된 파일의 주변 코드 컨텍스트를 읽어 충분한 이해를 확보한다
4. 아래 관점에서 리뷰한다:
   - 코드 정확성 및 버그 위험
   - 프로젝트 컨벤션 준수
   - 성능 영향
   - 테스트 커버리지
   - 보안 고려사항
5. 리뷰 결과를 섹션별로 정리하여 표시한다

### 2. 개선사항 task 등록

같은 PR을 다시 리뷰하는 경우, 기존 task를 모두 삭제(TaskUpdate status=deleted)한 후 새로 생성한다.

리뷰에서 발견된 개선사항을 TaskCreate로 등록한다:

- subject 형식: `#번호 [우선순위] 제목` (예: `#1 [높음] retry 루프에서 context 취소 확인 누락`)
- description에 구체적인 문제 상황과 개선 방안을 기술한다
- 리뷰 완료 후 아래 형식의 요약 테이블을 표시한다:

```text
| # | 상태 | 우선순위 | 내용 |
|---|------|---------|------|
| 1 | 💤 대기 | 높음 | retry 루프에서 context 취소 확인 누락 |
| 2 | 💤 대기 | 낮음 | isBodyStreamError 문자열 매칭 |
```

- 상태 표기:
  - 💤 대기 (pending)
  - ⚡ 진행 (in_progress)
  - ✅ 완료 (completed)
  - ⏩ 스킵 (skipped)
- 사용자가 "1번 완료", "2번 스킵" 등으로 지시하면 TaskUpdate로 상태를 변경하고 테이블을 다시 표시한다

### 3. 코멘트 요청 처리

사용자가 특정 이슈에 대해 PR 코멘트를 요청하면:

- `gh api`를 사용하여 해당 라인에 리뷰 코멘트를 작성한다
- 코멘트 작성 전 사용자에게 내용을 확인받는다

## 사용 예시

- `/review` — 열린 PR 목록 표시 후 선택
- `/review 108` — PR #108 바로 리뷰
