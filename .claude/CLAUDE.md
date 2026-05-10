# Global Instructions

## Git 작업 안전

- 되돌리기 어려운 git 작업(commit, push, force push, branch 삭제 등)은 실행 전에 반드시 사용자에게 확인을 받는다.
- 단, 사용자가 현재 세션에서 사전 승인을 명시한 경우(예: "이후 커밋은 자동 진행해도 됨") 그 범위 내에서는 재확인 생략 가능.

## 커밋 / PR / Issue 메시지 규칙

- 커밋 메시지는 항상 영어로 작성한다.
- Co-Authored-By 라인은 포함하지 않는다.
- PR, issue, 커밋 등 GitHub 액션에 Claude Code 사용 문구(예: "Generated with Claude Code")를 추가하지 않는다.

## 코드 수정 후 체크

코드 수정 후 커밋 전에 반드시 해당 언어의 lint/format을 실행한다. 도구와 명령어는 `lint-formatting` 스킬을 참고한다.

단, draft/WIP 커밋 등 의도적으로 lint 실패 상태를 보존해야 하는 경우, 사용자에게 확인 후 생략할 수 있다.

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

## Team 모드 작업 규칙

작업 시 항상 team 모드(병렬 에이전트)를 사용한다. 각 pane 창은 종료하지 않는다(keep alive). 기존 팀이 있으면 TeamDelete하지 않고 재사용한다. 팀 재사용이 불가능한 경우에만 정리 후 새로 생성한다.

## 스킬 사용 표시

- 스킬 사용 시(`Skill` 도구 호출이든 슬래시 커맨드로 이미 로드된 상태든) 첫 응답에서 어떤 스킬로 처리하는지 한 문장으로 안내한다.
- 여러 스킬을 함께 쓰면 모든 이름을 표시한다.
- 예: "`commit` 스킬로 처리합니다", "`commit`, `pr` 스킬로 처리합니다".
