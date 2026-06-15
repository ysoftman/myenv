---
name: review
description: Review GitHub PRs and track improvements as tasks. Use when user asks to review a PR, check a pull request, says "PR 리뷰해줘", "PR 봐줘", or provides a GitHub PR URL or number. Delegates both the review judgment and comment writing to the `reviewer` agent (run in the background).
allowed-tools: Agent, Bash(gh:*), Read, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# PR Review

GitHub Pull Request를 리뷰하고, 발견된 개선사항을 task로 관리한다. task로 다루는 이유는 리뷰 결과가 한 번 보고 사라지지 않고 "1번 완료" 같은 후속 지시로 진행 상황을 추적하기 위함이다.

Input: $ARGUMENTS

## 인자 파싱 규칙

- 인자 없음: `gh pr list --limit 20`으로 열린 PR 목록을 표시하고 리뷰할 PR을 선택하게 한다. 사용자가 본인 PR만 보고 싶다고 하면 `--author "@me"`를 추가한다.
- 숫자(예: `108`): 해당 PR을 바로 리뷰한다
- URL(예: `https://github.com/.../pull/108`): URL에서 PR 번호를 추출하여 리뷰한다

## 역할 분담 원칙

리뷰 관련 처리(PR 리뷰 판단, 코멘트 달기 등)는 **항상 별도 에이전트가 담당**한다. 시점·상황과 무관하게 메인 에이전트는 리뷰 관련 실제 작업을 직접 수행하지 않으며, **언제나 사용자 인터랙션에 집중**한다.

- **메인 에이전트**(직접 수행): 인자 파싱, PR 선택, 에이전트 입력 준비, 사용자 확인, 에이전트 디스패치, 결과 보고, task 등록/상태 관리. 그 외 리뷰 관련 판단·작성은 직접 하지 않는다.
- **별도 에이전트**(항상 위임, 둘 다 `reviewer` 에이전트로 디스패치):
  - PR 리뷰 판단 → `reviewer` 에이전트 (아래 "PR 리뷰")
  - 코멘트 작성 → `reviewer` 에이전트 (아래 "코멘트 요청 처리")
- 위임은 **항상 `Agent` 도구를 `run_in_background: true`로** 한다. 메인은 호출 직후 사용자 입력 대기/처리로 돌아가고, 완료 알림이 오면 후처리(결과 보고, task 등록/완료)만 진행한다.
- 사용자 확인이 필요한 단계(코멘트 작성 승인 등)는 메인이 직접 수행하고 에이전트에 위임하지 않는다.

## 실행 절차

### 작업 환경 보존

리뷰/코멘트는 사용자의 현재 작업 환경을 바꾸지 않고 끝나야 한다. 별도 에이전트가 백그라운드로, 때로는 여러 인스턴스가 동시에 도는 구조이므로 **공유 작업트리의 브랜치를 절대 바꾸지 않는다**(`gh pr checkout`/`git checkout`으로 현재 브랜치를 전환하면 사용자 작업과 동시 실행 인스턴스가 깨진다).

- **정적 리뷰·코멘트(기본)**: checkout이 필요 없다. 변경 내용은 `gh pr diff`/`gh pr view`로, hunk 밖 파일 컨텍스트는 `gh api .../contents?ref=<headSha>`(또는 `git fetch origin pull/<n>/head` 후 `git show <sha>:<path>` — 둘 다 작업트리/브랜치를 바꾸지 않는다)로 확인한다. `<headSha>`는 에이전트가 PR 번호로 도출한다(방법은 `reviewer` 단일 출처). 이 스킬의 리뷰·코멘트는 여기에 해당한다.
- **전체 트리가 필요할 때**(테스트 실행, 빌드, 전 repo 정적분석 등): 공유 브랜치를 바꾸지 말고 **격리된 worktree**를 쓴다(`git worktree add`, 또는 `Agent` 도구의 `isolation: "worktree"`). 별도 디렉터리라 사용자 작업·동시 실행과 충돌하지 않으며, 종료 시 worktree만 제거한다.
- 임시 산출물(패치/로그/테스트 출력 등)은 repo 밖(`/tmp` 계열)에 만들고 종료 전 삭제한다.

이 규칙은 디스패치 prompt에 함께 전달해 실제로 작업하는 에이전트가 지키게 한다. 메인은 입력 준비에 `gh`만 쓰므로 작업 환경을 건드리지 않는다.

### 사전 컨텍스트 수집

리뷰 전에 아래를 먼저 확인한다. 기존 의견을 모르고 리뷰하면 같은 지적을 반복하거나 이미 합의된 방향과 충돌하는 의견을 낼 수 있다.

1. `gh pr view <number> --comments`로 PR 본문과 일반 코멘트를 본다
2. `gh api repos/{owner}/{repo}/pulls/<number>/comments`로 라인 단위 리뷰 코멘트를 본다
3. 이미 다른 리뷰어가 지적한 사항은 리뷰에서 중복 제기하지 않고, 필요 시 "기존 코멘트와 동일 의견" 정도로만 언급한다

### PR 리뷰

리뷰 판단은 **항상 `reviewer` 에이전트에게 위임**한다. 메인은 리뷰 판단을 직접 하지 않고 입력 준비와 결과 후처리만 담당하며, 위임 후에는 사용자 입력에 계속 반응한다.

1. `gh pr view <number>`로 PR 상세 정보(제목, 본문, baseRefName)를 확인한다
2. `gh pr diff <number>`로 변경 내용을 가져온다
3. 변경 규모가 매우 크면(파일 수가 많거나 핵심 모듈 포함) 핵심 파일 우선이라는 가이드를 함께 전달한다. lock 파일이나 generated 코드는 빠르게 훑도록 지시한다.
4. **`Agent` 도구로 `reviewer` 서브에이전트를 `run_in_background: true`로 디스패치**한다. 호출 직후 메인은 사용자 입력 대기/처리로 돌아간다(리뷰 완료를 동기적으로 기다리지 않는다). prompt에 다음을 포함:
   - PR 번호와 제목
   - 변경된 diff 전체
   - PR 본문/설명 (의도 컨텍스트)
   - **base 브랜치(baseRefName)와 head SHA** — `reviewer`가 PR 무관 여부를 base 대조로 판정하는 데 쓴다
   - 사전 컨텍스트 수집 단계에서 확인한 기존 코멘트 (중복 지적 방지)
   - hunk 밖 파일 컨텍스트가 필요하면 **checkout 없이 PR head 파일을 확인**하도록 안내한다(`gh api .../contents?ref=<headSha>` 또는 `git fetch origin pull/<n>/head` 후 `git show <sha>:<path>`, `<headSha>`는 에이전트가 PR 번호로 도출). 현재 작업트리를 그대로 읽는 `Read`는 PR head와 내용이 다를 수 있으므로 쓰지 않는다.
   - 프로젝트 컨벤션(CLAUDE.md 규칙: bun/rg/fd/biome/rumdl 등) 위반 여부도 체크 항목에 포함
   - **🔴/고심각도 finding 은 `reviewer` 방법론의 "검증 게이트"(Methodology #4)를 통과한 것만 보고**하도록 지시한다: diff 패턴만으로 race/dangling/overflow 등을 단정하지 말고 hunk 밖 실제 head 코드로 확인(타입·락·수명·참조)하며, 확신이 없으면 🔴 로 올리지 말고 한 단계 낮추거나 질문 형태로 제시하라고 명시한다. (기준 자체는 `reviewer` 단일 출처)
   - 각 finding 에 우선순위를 붙이되, **PR 변경 영향이 아닌 finding 에만 `[PR 무관]` 마커**를 달고(PR 변경에서 비롯된 finding 은 무표시가 기본), `[PR 무관]`은 base 대조로 확인 후 별도 섹션으로 분리해 달라고 안내(기준은 `reviewer` 정의가 단일 출처)
   - 코드 변경으로 바로 고칠 수 있는 지적은 가능한 한 GitHub suggestion용 수정 코드 블록(```suggestion ... ```)을 포함하도록 안내
5. 서브에이전트 완료 알림이 오면 반환된 리뷰 결과(🔴 높음 / 🟡 중간 / 🟢 낮음 + PR 변경 영향이 아닌 것만 `[PR 무관]`으로 표시된 findings)를 받는다
6. 받은 결과 본문은 사용자에게 그대로 표시하고, 이어서 "개선사항 task 등록"을 진행한다

### 개선사항 task 등록

같은 PR을 다시 리뷰하는 경우, 기존 task를 일괄 삭제하지 않는다. 사용자가 이미 "완료/스킵" 처리한 항목까지 리셋되면 진행 상태 추적이 끊기기 때문이다. 다음과 같이 병합한다:

1. `TaskList`로 기존 task를 가져와 subject로 매칭한다
2. 이번 리뷰에도 동일한 항목이 남아 있으면 기존 task를 그대로 둔다(상태 보존)
3. 이번 리뷰에서 새로 발견한 항목만 `TaskCreate`로 추가한다(번호는 기존과 충돌하지 않게 이어 부여)
4. 변경/삭제로 더 이상 해당 없는 기존 task는 `TaskUpdate status=skipped`로 처리한다(삭제하지 않고 흔적을 남긴다)

리뷰에서 발견된 개선사항을 TaskCreate로 등록한다. 우선순위는 **`reviewer`가 분류한 값(🔴 높음 / 🟡 중간 / 🟢 낮음)을 그대로 반영**한다. 분류 기준의 단일 출처는 `reviewer` 에이전트 정의(Methodology)이며, 스킬은 기준을 중복 기술하지 않는다.

- subject 형식: `#번호 우선순위 — 제목` — PR 변경에서 비롯된 항목은 마커 없이 우선순위만 표기한다. PR 변경 영향이 아닌 항목만 우선순위 뒤에 `[PR 무관]`을 붙인다.
  - 예: `#1 🔴 높음 — retry 루프에서 context 취소 확인 누락`
  - 예: `#2 🟡 중간 [PR 무관] — 기존 add() 락 부재 (이 PR과 무관, 참고용)`
- description에 구체적인 문제 상황과 개선 방안을 기술한다 (가능하면 `file:line` 위치 포함). `[PR 무관]`이면 base 대조로 확인된 "기존부터 존재" 근거도 함께 적는다.
- **`[PR 무관]` task는 이 PR의 머지 조건이 아니다.** PR 코멘트로 다는 것보다 별도 이슈/추후 처리가 적절하므로, 사용자에게 보고할 때 이를 구분해 안내한다(예: "PR 무관 항목은 참고용이며 이 PR에서 고칠 필요는 없습니다").

### 상태 업데이트

리뷰 결과는 task로 추적하므로 **별도의 표는 출력하지 않는다**. 진행 상황은 task 목록으로 확인한다.

- 사용자가 "1번 완료", "2번 스킵" 등으로 지시하면 해당 Task를 `TaskUpdate`로 상태 변경만 한다(completed / skipped 등).
- 상태 변경 후에는 어떤 task를 어떤 상태로 바꿨는지 한 줄로 간단히 확인해 준다(표 재출력 없음).

### 코멘트 요청 처리

사용자가 특정 이슈에 대해 PR 코멘트를 요청하면, **실제 코멘트 작성은 `reviewer` 에이전트에게 위임**한다. 메인은 코멘트 작성에 묶여 있지 않고 사용자 입력을 계속 대기/처리할 수 있어야 한다.

#### 메인 에이전트의 역할

1. 코멘트 대상(이슈/task 번호, 파일, 라인)을 정한다. 코멘트 본문은 메인이 새로 작성하는 것이 아니라 **`reviewer`가 낸 finding(문제/권장 + suggestion 코드)을 그대로 코멘트 본문으로 구성**한다(메인은 리뷰 내용을 직접 작성하지 않는다 — 역할 분담 원칙).
2. **코멘트 작성 전 사용자에게 내용을 확인받는다.** 작성된 코멘트는 다른 협업자에게 즉시 보이므로 되돌리기 비용이 크다. 이 확인 단계는 메인이 직접 수행한다(서브에이전트에게 위임하지 않는다).
3. 사용자가 승인하면 **`Agent` 도구로 `reviewer` 서브에이전트를 `run_in_background: true`로 호출**해 코멘트 작성을 넘긴다. 호출 직후 메인은 즉시 사용자 입력 대기/처리로 돌아간다(작성 완료를 동기적으로 기다리지 않는다).
4. 서브에이전트 완료 알림이 오면 결과(코멘트 URL 또는 실패 사유)를 사용자에게 간단히 보고한다. 실패 시 사용자에게 재시도 여부를 확인한다.
5. **코멘트가 특정 task(개선사항)에 대응하고 작성이 성공하면, 해당 Task를 `TaskUpdate status=completed`로 변경**한다. 코멘트 작성이 실패했으면 task 상태는 그대로 둔다(성공한 코멘트만 완료 처리).
6. 여러 코멘트를 한 번에 요청받으면, 각 코멘트를 독립 서브에이전트로 동시에 디스패치한다. 각 서브에이전트가 완료될 때마다 대응 task를 개별적으로 완료 처리한다(전체가 끝날 때까지 기다리지 않는다).

#### `reviewer`에 전달할 prompt 내용

- PR 번호와 repo(owner/repo)
- 코멘트 대상 파일 경로, line 또는 `start_line`/`line` 범위
- 승인된 코멘트 본문(`reviewer` finding 기반)
- suggestion 적용 시 대체 코드

코멘트 작성의 구체 규칙(`gh api` 사용, suggestion 우선, line 검증, checkout 금지, 결과 반환 형식 등)은 **`reviewer` 에이전트 정의(`~/.claude/agents/reviewer.md`)의 "코멘트 작성 위임" 섹션을 단일 출처**로 한다. 스킬은 규칙을 중복 기술하지 않으며, 위 입력만 전달하면 `reviewer`가 자신의 규칙대로 처리한다.

## 사용 예시

- `/review` — 열린 PR 목록 표시 후 선택
- `/review 108` — PR #108 바로 리뷰
