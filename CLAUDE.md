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
