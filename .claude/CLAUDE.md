# Global Instructions

## Git 작업 시 확인

git commit, push, force push, branch 삭제 등 되돌리기 어려운 git 작업은 실행 전에 반드시 사용자에게 확인을 받는다. 커밋 메시지는 항상 영어로 작성한다. Co-Authored-By 라인은 커밋 메시지에 포함하지 않는다. PR, issue, 커밋 등 GitHub 액션에 Claude Code 사용 문구(예: "Generated with Claude Code")를 추가하지 않는다.

## 코드 수정 후 체크

코드 수정 후 커밋 전에 반드시 해당 언어의 lint/format을 실행한다. 도구와 명령어는 `lint-formatting` 스킬을 참고한다.

## File Search Commands

`grep` 대신 `rg` (ripgrep), `find` 대신 `fd`를 사용한다.

- 텍스트 검색: `rg "pattern"`
- 파일 찾기: `fd "pattern"`
- 특정 확장자: `fd -e js`

## Node Package Manager

모든 프로젝트에서 npm 대신 bun을 사용한다.

- `npm install` → `bun install`
- `npm run` → `bun run`
- `npm test` → `bun test`
- `npx` → `bunx`

## Claude 설정 파일 작성 규칙

Claude 관련 설정 파일(CLAUDE.md, AGENTS.md, `.claude/agents/*.md`, `.claude/skills/**/SKILL.md` 등) 작성 시 frontmatter 이후 본문은 반드시 `#`(h1) heading으로 시작하고, 이후 섹션은 `##` 이하를 사용한다.

## Team 모드 작업 규칙

작업 시 항상 team 모드(병렬 에이전트)를 사용한다. 각 pane 창은 종료하지 않는다(keep alive). 기존 팀이 있으면 TeamDelete하지 않고 재사용한다. 팀 재사용이 불가능한 경우에만 정리 후 새로 생성한다.

## 스킬 사용 표시

스킬을 사용할 때는 어떤 스킬로 처리하는지 한 문장으로 먼저 안내한다. `Skill` 도구를 호출하는 경우뿐 아니라, 사용자가 슬래시 커맨드(`/<skill-name>`)로 호출해 스킬이 이미 로드된 상태로 들어온 경우에도 첫 응답에서 동일하게 안내한다. 여러 스킬을 사용할 경우 모든 스킬 이름을 함께 표시한다. 예: "`commit` 스킬로 처리합니다" 또는 "`commit`, `pr` 스킬로 처리합니다".
