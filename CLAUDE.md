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

모든 프로젝트에서 markdownlint-cli2를 사용한다.

- Markdown 파일 검사: `bunx markdownlint-cli2 "**/*.md"`
- 자동 수정: `bunx markdownlint-cli2 --fix "**/*.md"`

## Shell Formatting

shell 스크립트 작성 시 shfmt를 사용하여 포맷팅한다.

- 포맷팅: `shfmt -i 4 -ci -w <file.sh>`
- 검사만: `shfmt -d <file.sh>`
