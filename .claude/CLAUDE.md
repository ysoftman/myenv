# Global Instructions

## Git 작업 안전

- 되돌리기 어려운 git 작업(commit, push, force push, branch 삭제 등)은 실행 전에 반드시 사용자에게 확인을 받는다.
- 단, 사용자가 현재 세션에서 사전 승인을 명시한 경우(예: "이후 커밋은 자동 진행해도 됨") 그 범위 내에서는 재확인 생략 가능.

## PR 머지 (절대 규칙)

- PR 머지는 **반드시 GitHub 웹 UI 에서 사람이 직접 수행**한다. Claude 는 **절대 PR 머지를 실행하지 않는다**.
- 머지는 **리뷰 승인(approve)이 받아진 PR 에 한해서만** 진행 가능하다. mergeable 상태나 branch protection 우회 가능 여부와 무관하게 적용된다.
- 다음 명령은 Claude 가 실행하지 않는다:
  - `gh pr merge` (모든 모드: --merge / --squash / --rebase)
  - base 브랜치 fast-forward 또는 직접 머지하는 `git merge` / `git push` 조합
  - GitHub API 의 PR merge 엔드포인트 호출
- 사용자가 "머지해", "merge", "이대로 머지하자" 등 명시 지시하더라도 Claude 는 머지를 직접 수행하지 않고 **사용자에게 웹 UI 에서 머지하도록 안내**한다.
- 자기 작업 브랜치의 로컬 통합(예: 로컬 feature branch 를 다른 로컬 브랜치로 머지)은 위 규칙에서 제외 — 다만 머지된 결과를 protected 브랜치로 push 하는 단계는 여전히 위 규칙에 따른다.

## 커밋 / PR / Issue 메시지 규칙

- 커밋 메시지는 항상 영어로 작성한다.
- Co-Authored-By 라인은 포함하지 않는다.
- PR, issue, 커밋 등 GitHub 액션에 Claude Code 사용 문구(예: "Generated with Claude Code")를 추가하지 않는다.

## 코드 수정 후 체크

코드 수정 후 커밋 전에 반드시 해당 언어의 lint/format을 실행한다. 도구와 명령어는 `lint-formatting` 스킬을 참고한다.

단, draft/WIP 커밋 등 의도적으로 lint 실패 상태를 보존해야 하는 경우, 사용자에게 확인 후 생략할 수 있다.

## 작업 명세 확인

- 구현, 리뷰, 포맷, 린트, 커밋, PR, issue 작업을 시작하기 전에 현재 요청에
  관련된 명세를 먼저 읽는다. 최소한 이 파일과 해당 `.claude/skills/**/SKILL.md`,
  repo의 README/CONTRIBUTING, 패키지 스크립트, 사용자가 언급한 issue/PR/문서를
  확인한다.
- 명세에 도구나 절차가 지정되어 있으면 추측으로 대체하지 않는다. 명세가 서로
  충돌하면 더 높은 우선순위의 지침을 따르고, 불명확하면 사용자에게 확인한다.

## 파일 검색 도구

`grep` 대신 `rg` (ripgrep), `find` 대신 `fd`를 사용한다.

- 텍스트 검색: `rg "pattern"`
- 파일 찾기: `fd "pattern"`
- 특정 확장자: `fd -e js`

## Node 패키지 매니저

모든 프로젝트에서 npm 대신 bun을 사용한다.

- `npm install` → `bun install`
- `npm run` → `bun run`
- `npm test` → `bun test`
- `npx` → `bunx`

단, Node 런타임 전용 패키지(예: puppeteer 등 일부 네이티브 의존)에서 호환성 문제가 발생하면 npm/npx로 폴백한다.

## Claude 설정 파일 작성 규칙

Claude 관련 설정 파일(CLAUDE.md, AGENTS.md, `.claude/agents/*.md`, `.claude/skills/**/SKILL.md` 등) 작성 시 frontmatter 이후 본문은 반드시 `#`(h1) heading으로 시작하고, 이후 섹션은 `##` 이하를 사용한다.

## Team 모드 자동 사용

- 작업이 병렬 진행에 유리하면 사용자가 `/team`을 명시하지 않아도 `team` 스킬을
  자동으로 사용한다. 세부 판단 기준은 `team` 스킬을 따른다.

## 전문 에이전트 활용

서브에이전트 또는 team 모드에서 작업 유형이 다음 중 하나에 해당하면 `general-purpose` 대신 `.claude/agents/`의 전문 에이전트를 우선 사용한다.

- 코드 리뷰 / 변경사항 검토 → `reviewer`
- 웹 검색 / 라이브러리 비교 / 외부 문서 조회 → `researcher`
- 오타 / 철자 / 네이밍 일관성 검사 → `typo-checker`
- 의존성 보안 취약점 / CVE 검사 → `vulnerability-package-checker`

## 스킬 사용 표시

- 스킬 사용 시(`Skill` 도구 호출이든 슬래시 커맨드로 이미 로드된 상태든) 첫 응답에서 어떤 스킬로 처리하는지 한 문장으로 안내한다.
- 여러 스킬을 함께 쓰면 모든 이름을 표시한다.
- 예: "`commit` 스킬로 처리합니다", "`commit`, `pr` 스킬로 처리합니다".
