# Global Instructions

## Git 작업 시 확인

git commit, push, force push, branch 삭제 등 되돌리기 어려운 git 작업은 실행 전에 반드시 사용자에게 확인을 받는다. 커밋 메시지는 항상 영어로 작성한다. Co-Authored-By 라인은 커밋 메시지에 포함하지 않는다. PR, issue, 커밋 등 GitHub 액션에 Claude Code 사용 문구(예: "Generated with Claude Code")를 추가하지 않는다.

## 코드 수정 후 체크

코드 수정 후 커밋 전에 반드시 해당 언어의 lint/format을 실행한다.

- JavaScript/TypeScript: `biome check --write .`
- Go: `golangci-lint run --fix && gofmt -w .`
- Rust: `cargo clippy --fix && cargo fmt`
- Python: `ruff check --fix . && ruff format .`
- HTML: `bunx prettier --write <수정된 파일>`
- Shell: `shfmt -i 4 -ci -w <수정된 파일>`
- Markdown: `rumdl fmt .`

## File Search Commands

모든 프로젝트에서 더 빠른 검색 도구를 사용한다.

- `grep` → `rg` (ripgrep, Rust 기반으로 grep보다 빠름)
- `find` → `fd` (Rust 기반으로 find보다 빠름)

예시:

- 텍스트 검색: `rg "pattern"` (grep 대신)
- 파일 찾기: `fd "pattern"` (find 대신)
- 특정 확장자 검색: `fd -e js` (find -name "*.js" 대신)

## Node Package Manager

모든 프로젝트에서 npm 대신 bun을 사용한다. (Zig 기반으로 npm/yarn보다 빠름)

- `npm install` → `bun install`
- `npm run` → `bun run`
- `npm test` → `bun test`
- `npm init` → `bun init`
- `npx` → `bunx`
- `npm ci` → `bun install --frozen-lockfile`

## Markdown Linting & Formatting

모든 프로젝트에서 rumdl을 사용한다. (Rust 기반으로 markdownlint-cli2보다 빠름)

- Markdown 파일 검사: `rumdl check .`
- 자동 수정: `rumdl fmt .`

## HTML Formatting

모든 프로젝트에서 HTML 파일 포맷팅 시 Prettier를 사용한다. (Biome가 HTML을 미지원하므로 Prettier 사용)

- 포맷팅: `bunx prettier --write <수정된 파일>`
- 검사만: `bunx prettier --check <수정된 파일>`

## Shell Formatting

모든 프로젝트에서 shell 스크립트 작성 시 shfmt를 사용하여 포맷팅한다.

- 포맷팅: `shfmt -i 4 -ci -w <file.sh>`
- 검사만: `shfmt -d <file.sh>`

## JavaScript/TypeScript Linting & Formatting

모든 프로젝트에서 JavaScript/TypeScript 코드 린팅/포맷팅 시 Biome를 사용한다. (Rust 기반으로 ESLint, Prettier보다 빠름)

- 린트 검사: `biome lint .`
- 포맷팅: `biome format --write .`
- 포맷팅 검사만: `biome format .`
- 린트 + 포맷팅 한번에: `biome check --write .`
- 검사만 (수정 없이): `biome check .`

## Go Linting & Formatting

모든 프로젝트에서 Go 코드 린팅 시 golangci-lint를 사용한다. (다양한 린터를 통합 실행)

- 린트 검사: `golangci-lint run`
- 특정 디렉터리 검사: `golangci-lint run ./...`
- 자동 수정: `golangci-lint run --fix`
- 포맷팅: `gofmt -w .`

## Rust Linting & Formatting

모든 프로젝트에서 Rust 코드 린팅/포맷팅 시 clippy와 rustfmt를 사용한다.

- 린트 검사: `cargo clippy`
- 린트 자동 수정: `cargo clippy --fix`
- 포맷팅: `cargo fmt`
- 포맷팅 검사만: `cargo fmt --check`

## Python Linting & Formatting

모든 프로젝트에서 Python 코드 린팅/포맷팅 시 ruff를 사용한다. (Rust 기반으로 flake8, black, isort보다 빠름)

- 린트 검사: `ruff check .`
- 린트 자동 수정: `ruff check --fix .`
- 포맷팅: `ruff format .`
- 포맷팅 검사만: `ruff format --check .`

## Claude 설정 파일 포맷팅

Claude 관련 설정 파일(CLAUDE.md, AGENTS.md, `.claude/agents/*.md`, `.claude/skills/**/SKILL.md` 등)을 생성하거나 수정한 후에는 항상 `rumdl fmt <수정된 파일>` 을 실행하여 Markdown 포맷팅을 적용한다. 특히 스킬(SKILL.md)과 에이전트(`.claude/agents/*.md`) 파일 작성 시 frontmatter 이후 본문은 반드시 `#`(h1) heading으로 시작하고, 이후 섹션은 `##` 이하를 사용한다.

## Team 모드 작업 규칙

작업 시 항상 team 모드(병렬 에이전트)를 사용한다. 각 pane 창은 종료하지 않는다(keep alive). 기존 팀이 있으면 TeamDelete하지 않고 재사용한다. 팀 재사용이 불가능한 경우에만 정리 후 새로 생성한다.

## 스킬 사용 표시

스킬을 사용할 때는 어떤 스킬로 처리하는지 한 문장으로 먼저 안내한다. `Skill` 도구를 호출하는 경우뿐 아니라, 사용자가 슬래시 커맨드(`/<skill-name>`)로 호출해 스킬이 이미 로드된 상태로 들어온 경우에도 첫 응답에서 동일하게 안내한다. 여러 스킬을 사용할 경우 모든 스킬 이름을 함께 표시한다. 예: "`commit` 스킬로 처리합니다" 또는 "`commit`, `pr` 스킬로 처리합니다".
