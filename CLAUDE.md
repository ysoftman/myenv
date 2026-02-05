# Global Instructions

## Package Manager

모든 프로젝트에서 npm 대신 bun을 사용한다.

- `npm install` → `bun install`
- `npm run` → `bun run`
- `npm test` → `bun test`
- `npm init` → `bun init`
- `npx` → `bunx`
- `npm ci` → `bun install --frozen-lockfile`

## Markdown Linting

모든 프로젝트에서 rumdl을 사용한다. (Rust 기반으로 markdownlint-cli2보다 빠름)

- Markdown 파일 검사: `rumdl check .`
- 자동 수정: `rumdl fmt .`

## Shell Formatting

모든 프로젝트에서 shell 스크립트 작성 시 shfmt를 사용하여 포맷팅한다.

- 포맷팅: `shfmt -i 4 -ci -w <file.sh>`
- 검사만: `shfmt -d <file.sh>`

## File Search Commands

모든 프로젝트에서 더 빠른 검색 도구를 사용한다.

- `grep` → `rg` (ripgrep)
- `find` → `fd`

예시:

- 텍스트 검색: `rg "pattern"` (grep 대신)
- 파일 찾기: `fd "pattern"` (find 대신)
- 특정 확장자 검색: `fd -e js` (find -name "*.js" 대신)
