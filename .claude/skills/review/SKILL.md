---
name: review
description: Review GitHub PRs and track improvements as tasks. Use when user asks to review a PR, check a pull request, says "PR 리뷰해줘", "코드 리뷰", "리뷰해줘", "PR 봐줘", or provides a GitHub PR URL or number.
allowed-tools: Bash(gh:*), Bash(printf:*), Read, Glob, Grep, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# PR Review

GitHub Pull Request를 리뷰하고, 발견된 개선사항을 task로 관리한다. task로 다루는 이유는 리뷰 결과가 한 번 보고 사라지지 않고 "1번 완료" 같은 후속 지시로 진행 상황을 추적하기 위함이다.

Input: $ARGUMENTS

## 인자 파싱 규칙

- 인자 없음: `gh pr list --limit 20`으로 열린 PR 목록을 표시하고 리뷰할 PR을 선택하게 한다. 사용자가 본인 PR만 보고 싶다고 하면 `--author "@me"`를 추가한다.
- 숫자(예: `108`): 해당 PR을 바로 리뷰한다
- URL(예: `https://github.com/.../pull/108`): URL에서 PR 번호를 추출하여 리뷰한다

## 실행 절차

### 사전 컨텍스트 수집

리뷰 전에 아래를 먼저 확인한다. 기존 의견을 모르고 리뷰하면 같은 지적을 반복하거나 이미 합의된 방향과 충돌하는 의견을 낼 수 있다.

1. `gh pr view <number> --comments`로 PR 본문과 일반 코멘트를 본다
2. `gh api repos/{owner}/{repo}/pulls/<number>/comments`로 라인 단위 리뷰 코멘트를 본다
3. 이미 다른 리뷰어가 지적한 사항은 리뷰에서 중복 제기하지 않고, 필요 시 "기존 코멘트와 동일 의견" 정도로만 언급한다

### PR 리뷰

메인 에이전트가 직접 리뷰를 수행한다:

1. `gh pr view <number>`로 PR 상세 정보를 확인한다
2. `gh pr diff <number>`로 변경 내용을 가져온다
3. 변경 규모나 위험도가 크다고 판단되면(파일 수가 많거나, 핵심 모듈이 포함된 경우) 핵심 파일을 우선 깊게 보고 나머지는 카테고리별로 요약한다. lock 파일이나 generated 코드처럼 자동 생성된 변경은 빠르게 훑는다.
4. 변경된 파일의 주변 코드 컨텍스트를 읽어 충분한 이해를 확보한다. diff만 보고 판단하면 의도와 제약을 놓치기 쉽다.
5. 아래 관점에서 리뷰한다:
   - 코드 정확성 및 버그 위험
   - 프로젝트 컨벤션 준수 (CLAUDE.md 규칙 포함: bun/rg/fd/biome/rumdl 등 도구 사용 여부)
   - 성능 영향
   - 테스트 커버리지
   - 보안 고려사항
6. 리뷰 결과를 섹션별로 정리하여 한국어로 표시한다 (리뷰 본문은 일반 출력으로 둔다)

### 개선사항 task 등록

같은 PR을 다시 리뷰하는 경우, 기존 task를 일괄 삭제하지 않는다. 사용자가 이미 "완료/스킵" 처리한 항목까지 리셋되면 진행 상태 추적이 끊기기 때문이다. 다음과 같이 병합한다:

1. `TaskList`로 기존 task를 가져와 subject로 매칭한다
2. 이번 리뷰에도 동일한 항목이 남아 있으면 기존 task를 그대로 둔다(상태 보존)
3. 이번 리뷰에서 새로 발견한 항목만 `TaskCreate`로 추가한다(번호는 기존과 충돌하지 않게 이어 부여)
4. 변경/삭제로 더 이상 해당 없는 기존 task는 `TaskUpdate status=skipped`로 처리한다(삭제하지 않고 흔적을 남긴다)

리뷰에서 발견된 개선사항을 TaskCreate로 등록한다:

- subject 형식: `#번호 [우선순위] 제목` (예: `#1 [높음] retry 루프에서 context 취소 확인 누락`)
- 우선순위 기준:
  - **높음**: 버그/데이터 손상/보안 위험/장애 유발 가능성. 머지 전에 반드시 처리.
  - **중간**: 동작은 하지만 성능/유지보수성/테스트 커버리지 등 명확한 약점. 가능하면 같은 PR에서 처리.
  - **낮음**: 스타일/네이밍/사소한 리팩토링 제안. 작성자 재량.
- description에 구체적인 문제 상황과 개선 방안을 기술한다
- 리뷰 완료 후 아래 형식의 요약 테이블을 표시한다. 테이블은 `printf`에 ANSI 녹색(`\033[32m ... \033[0m`) escape 코드를 씌워 터미널에 녹색으로 출력한다(일반 리뷰 본문과 시각적으로 구분되어 후속 지시 대상을 빠르게 찾을 수 있다):

```bash
printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
| # | 상태 | 우선순위 | 내용 |
|---|------|---------|------|
| 1 | 💤 대기 | 높음 | retry 루프에서 context 취소 확인 누락 |
| 2 | 💤 대기 | 낮음 | isBodyStreamError 문자열 매칭 |
EOF
)"
```

- 상태 표기:
  - 💤 대기 (pending)
  - ⚡ 진행 (in_progress)
  - ✅ 완료 (completed)
  - ⏩ 스킵 (skipped)
- 사용자가 "1번 완료", "2번 스킵" 등으로 지시하면 TaskUpdate로 상태를 변경하고 테이블을 다시 표시한다

### 코멘트 요청 처리

사용자가 특정 이슈에 대해 PR 코멘트를 요청하면:

- `gh api`를 사용하여 해당 라인에 리뷰 코멘트를 작성한다
- 코멘트 작성 전 사용자에게 내용을 확인받는다(작성된 코멘트는 다른 협업자에게 즉시 보이므로 되돌리기 비용이 크다)

## 사용 예시

- `/review` — 열린 PR 목록 표시 후 선택
- `/review 108` — PR #108 바로 리뷰
