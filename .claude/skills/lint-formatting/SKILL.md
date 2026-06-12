---
name: lint-formatting
description: Run language-specific linters, formatters, and static type checks with full command reference. Use when user asks to lint, format, type-check, check style, or says "린트", "포맷", "타입 체크", "lint", "format", "type check", "biome", "ruff", "pyright", "clippy", "golangci-lint", "rumdl", "prettier", "shfmt". Also use when needing detailed command variants (check-only, fix-only, partial scope) beyond the standard fix-everything command.
allowed-tools: Bash, Read, Glob
model: sonnet
effort: low
---

# Lint & Formatting

언어별 lint/format/정적 타입 체크 도구의 명령어 reference. 표준 "수정 + 포맷팅 통합" 명령어와 check-only, 부분 적용 등 변형을 함께 다룬다.

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

## Python 정적 타입 체크 (pyright)

분류상 lint/format 이 아닌 정적 타입 체크지만, Python 코드 수정 후 검증에는 ruff 와 함께 항상 포함한다 — 사용자가 에디터에서 pyright diagnostics 를 보고 있어서, pyright 에러가 남은 커밋은 미완성 코드로 인식된다.

- 검사: `bunx pyright <수정한 파일...>` (pyright 글로벌 미설치 — bunx 로 실행)
- **수정한 파일만 검사한다.** repo 전체를 0 error 게이트로 걸지 않는다 — pyright 미도입 프로젝트는 기존 부채(특히 동적 스텁 패턴이 많은 테스트 파일)만으로 에러가 수십~수백 건일 수 있다.
- 기존 부채 에러는 범위 외 — 수정/추가한 코드에서 나온 에러만 0 으로 만든다. 기존 부채 일괄 정리나 pyrightconfig 도입은 사용자와 별도 합의 후 진행한다.
- 자주 걸리는 패턴과 해법:
  - closure 가 캡처한 변수는 바깥 `if` 의 narrowing 이 함수 안으로 전파되지 않는다 → 함수 본문에서 재검사
  - `.get()` 결과를 isinstance 로 거른 뒤 `["key"]` 로 재접근하면 narrowing 이 안 붙는다 → walrus(`:=`) 또는 로컬 변수로 바인딩
  - try/except import fallback stub 은 실함수와 파라미터 이름까지 일치시킨다 (이름 불일치도 시그니처 비호환)

## HTML (Prettier)

Biome가 HTML을 미지원하므로 Prettier를 사용한다.

- 포맷팅: `bunx prettier --write <파일>`
- 검사만: `bunx prettier --check <파일>`
- `tidy`는 HTML 포맷터로 사용하지 않는다. 사용자가 명시적으로 요청하거나
  프로젝트 스크립트가 `tidy`를 요구하는 경우에만 예외로 다룬다.

## Shell (shfmt)

- 포맷팅: `shfmt -i 4 -ci -w <file.sh>`
- 검사만: `shfmt -d <file.sh>`

## Markdown (rumdl)

**필수: rumdl 을 실행할 때는 항상 `--extend-disable MD013` 플래그를 붙인다.** 플래그 없는 `rumdl check .` / `rumdl fmt .` 형태는 이 환경에서 사용하지 않는다. MD013(line-length) 은 한국어 본문 가독성 때문에 의도적으로 끈 정책이며, `--extend-disable` 은 프로젝트 `.rumdl.toml` 의 disable 목록에 더해지는 형태라 기존 설정과 충돌하지 않는다.

- 검사만 (수정 없이): `rumdl check --extend-disable MD013 .`
- 자동 수정: `rumdl fmt --extend-disable MD013 .`
- 추가 규칙 끄기: `--extend-disable MD013,MD024` 처럼 콤마로 나열한다 (MD013 은 항상 포함).

## 실행 절차

1. 사용자 요청에서 대상 언어와 작업(검사 vs 수정)을 파악한다. 명시되지 않으면 `git status`로 변경된 파일의 확장자를 확인하여 추론한다.
2. 위 reference와 프로젝트 스크립트(`package.json`, `Makefile`, CI 설정 등)를 확인해 명령어를 선택한다. reference와 프로젝트 스크립트가 충돌하면 사용자에게 확인한다.
3. 명령어를 추측하거나 설치된 도구 이름만 보고 대체하지 않는다.
4. 결과를 사용자에게 보고한다. 에러가 있으면 파일 경로와 라인 번호를 함께 제시한다.

## 주의사항

- 표준 "수정 후 자동 수정" 워크플로우는 `commit` 스킬이 자체적으로 처리한다. 이 스킬은 명시적 lint/format 요청 또는 변형 명령어가 필요할 때 사용한다.
- HTML과 Shell의 `<파일>` 부분은 실제 파일 경로로 치환한다. 전체 디렉터리 일괄 적용 시에는 `fd`와 조합한다 (예: `fd -e sh -x shfmt -i 4 -ci -w {}`).
