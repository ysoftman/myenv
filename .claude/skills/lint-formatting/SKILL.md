---
name: lint-formatting
description: Run language-specific linters and formatters with full command reference. Use when user asks to lint, format, check style, or says "린트", "포맷", "lint", "format", "biome", "ruff", "clippy", "golangci-lint", "rumdl", "prettier", "shfmt". Also use when needing detailed command variants (check-only, fix-only, partial scope) beyond the standard fix-everything command.
allowed-tools: Bash, Read, Glob
---

# Lint & Formatting

언어별 lint/format 도구의 전체 명령어 reference. 표준 "수정 후 자동 수정" 명령어는 CLAUDE.md `코드 수정 후 체크` 섹션에 있으며, 이 스킬은 check-only, 부분 적용 등 변형 명령어를 다룬다.

## 표준 명령어 (수정 + 포맷팅 통합)

CLAUDE.md `코드 수정 후 체크` 섹션과 동일하지만 빠른 참조용:

- JavaScript/TypeScript: `biome check --write .`
- Go: `golangci-lint run --fix && gofmt -w .`
- Rust: `cargo clippy --fix && cargo fmt`
- Python: `ruff check --fix . && ruff format .`
- HTML: `bunx prettier --write <파일>`
- Shell: `shfmt -i 4 -ci -w <파일>`
- Markdown: `rumdl fmt .`

## JavaScript/TypeScript (Biome)

- 린트만: `biome lint .`
- 포맷팅만 (수정): `biome format --write .`
- 포맷팅 검사만: `biome format .`
- 린트 + 포맷팅 통합 수정: `biome check --write .`
- 검사만 (수정 없이): `biome check .`

## Go (golangci-lint + gofmt)

golangci-lint는 다양한 린터를 통합 실행한다.

- 린트 검사: `golangci-lint run`
- 특정 디렉터리 검사: `golangci-lint run ./...`
- 자동 수정: `golangci-lint run --fix`
- 포맷팅: `gofmt -w .`

## Rust (clippy + rustfmt)

- 린트 검사: `cargo clippy`
- 린트 자동 수정: `cargo clippy --fix`
- 포맷팅: `cargo fmt`
- 포맷팅 검사만: `cargo fmt --check`

## Python (ruff)

- 린트 검사: `ruff check .`
- 린트 자동 수정: `ruff check --fix .`
- 포맷팅: `ruff format .`
- 포맷팅 검사만: `ruff format --check .`

## HTML (Prettier)

Biome가 HTML을 미지원하므로 Prettier를 사용한다.

- 포맷팅: `bunx prettier --write <파일>`
- 검사만: `bunx prettier --check <파일>`

## Shell (shfmt)

- 포맷팅: `shfmt -i 4 -ci -w <file.sh>`
- 검사만: `shfmt -d <file.sh>`

## Markdown (rumdl)

- 검사만 (수정 없이): `rumdl check .`
- 자동 수정: `rumdl fmt .`

## 실행 절차

1. 사용자 요청에서 대상 언어와 작업(검사 vs 수정)을 파악한다. 명시되지 않으면 `git status`로 변경된 파일의 확장자를 확인하여 추론한다.
2. 위 reference에서 해당 명령어를 선택해 실행한다.
3. 결과를 사용자에게 보고한다. 에러가 있으면 파일 경로와 라인 번호를 함께 제시한다.

## 주의사항

- 표준 "수정 후 자동 수정" 워크플로우는 `commit` 스킬이 자체적으로 처리한다. 이 스킬은 명시적 lint/format 요청 또는 변형 명령어가 필요할 때 사용한다.
- HTML과 Shell의 `<파일>` 부분은 실제 파일 경로로 치환한다. 전체 디렉터리 일괄 적용 시에는 `fd`와 조합한다 (예: `fd -e sh -x shfmt -i 4 -ci -w {}`).
