---
name: review
description: Review GitHub PRs and track improvements as tasks. Use when user asks to review a PR, check a pull request, says "PR 리뷰해줘", "PR 봐줘", or provides a GitHub PR URL or number. Delegates primary review judgment to the `reviewer` agent and, when available, cross-checks with `review-cross-checker`.
allowed-tools: Agent, Bash(gh:*), Bash(printf:*), Read, Glob, Grep, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# PR Review

GitHub Pull Request를 리뷰하고, 발견된 개선사항을 task로 관리한다. task로 다루는 이유는 리뷰 결과가 한 번 보고 사라지지 않고 "1번 완료" 같은 후속 지시로 진행 상황을 추적하기 위함이다.

Input: $ARGUMENTS

## 인자 파싱 규칙

- 인자 없음: `gh pr list --limit 20`으로 열린 PR 목록을 표시하고 리뷰할 PR을 선택하게 한다. 사용자가 본인 PR만 보고 싶다고 하면 `--author "@me"`를 추가한다.
- 숫자(예: `108`): 해당 PR을 바로 리뷰한다
- URL(예: `https://github.com/.../pull/108`): URL에서 PR 번호를 추출하여 리뷰한다

## 실행 절차

### 작업 환경 보존

리뷰는 사용자의 현재 작업 환경을 바꾸지 않고 끝나야 한다. PR checkout, diff 저장, 임시 테스트, 파일 생성이 필요하더라도 리뷰 종료 시 리뷰 전 상태로 되돌린다.

1. 리뷰 시작 직후 아래 상태를 기록한다:
   - 현재 브랜치: `git branch --show-current`
   - 현재 HEAD: `git rev-parse HEAD`
   - 작업트리 상태: `git status --short`
   - 추적되지 않은 파일 목록: `git ls-files --others --exclude-standard`
2. PR 내용을 확인하기 위해 브랜치를 바꾸거나 `gh pr checkout`을 실행해야 하면, 시작 시 기록한 브랜치/HEAD로 돌아갈 수 있는지 먼저 확인한다. 작업트리가 dirty이면 사용자의 변경을 덮어쓰거나 stash하지 말고, 가능한 한 `gh pr diff`, `gh pr view`, `git show`, 원격 ref 읽기처럼 checkout 없는 방식으로 리뷰한다.
3. 리뷰 중 생성한 임시 파일, 패치 파일, 로그, 테스트 산출물은 경로를 기록하고 리뷰 종료 전에 삭제한다. 임시 산출물은 가능하면 repo 밖의 `/tmp` 계열 디렉터리에 만든다.
4. 리뷰 종료 직전에 시작 시 기록한 브랜치로 돌아온다. 브랜치명이 없던 detached HEAD 상태였다면 기록한 HEAD로 돌아온다.
5. 리뷰 중 발생한 작업트리 변경은 모두 되돌린다. 단, 시작 시 이미 존재했던 사용자 변경은 유지한다. 리뷰 전 `git status --short`와 종료 직전 상태를 비교해 리뷰가 만든 변경만 제거한다.
6. 최종 응답 전에 `git status --short`와 현재 브랜치/HEAD를 확인하고, 리뷰 전 상태와 다르면 복원 작업을 계속한다. 자동 복원이 충돌이나 사용자 변경과 겹쳐 안전하지 않으면 즉시 멈추고 남은 차이를 구체적으로 보고한다.

### 사전 컨텍스트 수집

리뷰 전에 아래를 먼저 확인한다. 기존 의견을 모르고 리뷰하면 같은 지적을 반복하거나 이미 합의된 방향과 충돌하는 의견을 낼 수 있다.

1. `gh pr view <number> --comments`로 PR 본문과 일반 코멘트를 본다
2. `gh api repos/{owner}/{repo}/pulls/<number>/comments`로 라인 단위 리뷰 코멘트를 본다
3. 이미 다른 리뷰어가 지적한 사항은 리뷰에서 중복 제기하지 않고, 필요 시 "기존 코멘트와 동일 의견" 정도로만 언급한다

### PR 리뷰

리뷰 판단은 `reviewer` 에이전트에게 위임한다. 기본적으로 별도 `review-cross-checker` 에이전트로 결과를 교차 검증한다. 메인은 입력 준비, cross-check 조정, 결과 병합, 후처리를 담당한다.

표준 근거 형식은 `근거 = 파일:라인 + 실패 조건/재현 시나리오 + 영향 범위` 로 통일한다. 🔴/🟡 finding 에는 근거와 confidence 를 반드시 포함하고, 🟢 finding 은 권장을 필수로 하되 근거/영향/confidence 는 필요할 때만 포함한다.

1. `gh pr view <number>`로 PR 상세 정보(제목, 본문)를 확인한다
2. `gh pr diff <number>`로 변경 내용을 가져온다
3. 변경 규모가 매우 크면(파일 수가 많거나 핵심 모듈 포함) 핵심 파일 우선이라는 가이드를 함께 전달한다. lock 파일이나 generated 코드는 빠르게 훑도록 지시한다.
4. **`Agent` 도구로 `reviewer` 서브에이전트를 호출**한다. 다음을 prompt에 포함:
   - PR 번호와 제목
   - 변경된 diff 전체
   - PR 본문/설명 (의도 컨텍스트)
   - 사전 컨텍스트 수집 단계에서 확인한 기존 코멘트 (중복 지적 방지)
   - 변경된 파일의 컨텍스트가 필요하면 에이전트가 직접 Read하도록 안내
   - 프로젝트 컨벤션(CLAUDE.md 규칙: bun/rg/fd/biome/rumdl 등) 위반 여부도 체크 항목에 포함
   - 코드 변경으로 바로 고칠 수 있는 지적은 가능한 한 GitHub suggestion용 수정 코드 블록(```suggestion ... ```)을 포함하도록 안내
   - 🔴/🟡 finding 에 표준 근거와 confidence 를 포함하도록 요청한다
5. 기본적으로 **별도 `review-cross-checker` 에이전트**를 호출한다.
   - 생략 조건은 둘 중 하나로 제한한다: `Agent` 도구/별도 모델이 런타임에서 차단된 경우, 또는 변경이 매우 작고 위험도가 낮은 경우(예: 단일 파일 50줄 미만이며 공유 로직/런타임/보안/데이터 경로를 건드리지 않음)
   - 입력: PR 번호/제목, PR 본문, diff, 기존 코멘트, `reviewer` 결과
   - 역할: false positive 검증, 누락된 🔴/🟡 탐색, 기존 코멘트와 중복 제거, 근거가 약한 지적 기각
   - 출력은 사용자 표시용 최종 리뷰가 아니라 병합 판단용으로 받는다
6. 런타임에서 별도 에이전트 또는 다른 모델 사용이 불가능하면 메인 에이전트가 2-pass cross-check 를 수행하고, 최종 응답에 "별도 cross-check agent 미사용" 여부를 짧게 명시한다.
7. 메인은 `reviewer` 결과와 cross-check 결과를 병합한다.
   - 기존 코멘트와 중복되거나 cross-check 가 명확히 false positive 로 판정한 항목은 제외한다
   - cross-check 의 `Missed Candidates` 중 `Confidence: high` 이고 변경 범위에 직접 관련된 항목만 finding 으로 추가한다
   - `Confidence: medium` 은 open question 으로 낮추고, `Confidence: low` 는 제외한다
   - 확신이 낮은 의견은 finding 으로 올리지 말고 open question 으로 낮춘다
8. 병합된 리뷰 결과를 사용자에게 표시한다.
   - 출력은 findings(🔴 높음 / 🟡 중간 / 🟢 낮음)와 `Open Questions` 섹션으로 구성한다
   - task 등록 대상은 findings 로 한정하고, open question 은 task 로 만들지 않는다

### 개선사항 task 등록

같은 PR을 다시 리뷰하는 경우, 기존 task를 일괄 삭제하지 않는다. 사용자가 이미 "완료/스킵" 처리한 항목까지 리셋되면 진행 상태 추적이 끊기기 때문이다. 다음과 같이 병합한다:

1. `TaskList`로 기존 task를 가져와 subject로 매칭한다
2. 이번 리뷰에도 동일한 항목이 남아 있으면 기존 task를 그대로 둔다(상태 보존)
3. 이번 리뷰에서 새로 발견한 항목만 `TaskCreate`로 추가한다(번호는 기존과 충돌하지 않게 이어 부여)
4. 변경/삭제로 더 이상 해당 없는 기존 task는 `TaskUpdate status=skipped`로 처리한다(삭제하지 않고 흔적을 남긴다)

리뷰에서 발견된 개선사항을 TaskCreate로 등록한다. 표기 체계는 `reviewer` 에이전트와 완전히 동일하다 (`🔴 높음` / `🟡 중간` / `🟢 낮음`).

- subject 형식: `#번호 우선순위 — 제목` (예: `#1 🔴 높음 — retry 루프에서 context 취소 확인 누락`)
- 우선순위 기준 (에이전트와 동일):
  - **🔴 높음**: 버그/데이터 손상/보안 위험/장애 유발 가능성. 머지 전에 반드시 처리.
  - **🟡 중간**: 동작은 하지만 성능/유지보수성/테스트 커버리지 등 명확한 약점. 가능하면 같은 PR에서 처리.
  - **🟢 낮음**: 스타일/네이밍/사소한 리팩토링 제안. 작성자 재량.
- description에 구체적인 문제 상황과 개선 방안을 기술한다 (가능하면 `file:line` 위치 포함)

### 표 출력 정책

- **초기 표 출력은 에이전트가 담당**한다. 스킬은 별도로 초기 표를 다시 출력하지 않는다 (중복 방지).
- **상태 업데이트는 스킬이 담당**한다. 사용자가 "1번 완료", "2번 스킵" 등으로 지시하면:
  1. 해당 Task를 `TaskUpdate`로 상태 변경
  2. 전체 표를 아래 형식으로 다시 출력 (에이전트 표와 동일 포맷, 상태 컬럼만 업데이트)

```bash
printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
| # | 상태 | 우선순위 | 내용 |
|---|------|---------|------|
| 1 | ✅ 완료 | 🔴 높음 | retry 루프에서 context 취소 확인 누락 |
| 2 | 💤 대기 | 🟢 낮음 | isBodyStreamError 문자열 매칭 |
EOF
)"
```

- 상태 표기:
  - 💤 대기 (pending)
  - ⚡ 진행 (in_progress)
  - ✅ 완료 (completed)
  - ⏩ 스킵 (skipped)

### 코멘트 요청 처리

사용자가 특정 이슈에 대해 PR 코멘트를 요청하면:

- `gh api`를 사용하여 해당 라인에 리뷰 코멘트를 작성한다
- 코멘트 본문은 사용자가 다른 언어를 명시하지 않는 한 한국어로 작성한다.
- 코드 변경으로 바로 고칠 수 있는 코멘트는 GitHub suggestion 코드 블록(```suggestion ... ```)을 우선 포함한다.
- suggestion은 코멘트가 달릴 diff 라인과 정확히 대응해야 한다. 수정이 여러 줄이면 한 줄 코멘트가 아니라 `start_line`/`line` 범위를 지정한 range review comment로 작성해 suggestion이 바로 적용 가능하게 한다.
- suggestion 범위가 정확히 맞지 않거나 여러 파일 수정이 필요한 경우에만 일반 코드 블록이나 설명으로 대체하고, 왜 suggestion으로 만들지 않았는지 짧게 설명한다.
- 코멘트 작성 전에는 PR 브랜치의 대상 파일을 `nl -ba` 등으로 확인해 line/range와 suggestion 대체 코드가 실제 diff에 맞는지 검증한다.
- 코멘트 작성 전 사용자에게 내용을 확인받는다(작성된 코멘트는 다른 협업자에게 즉시 보이므로 되돌리기 비용이 크다)

## 사용 예시

- `/review` — 열린 PR 목록 표시 후 선택
- `/review 108` — PR #108 바로 리뷰
