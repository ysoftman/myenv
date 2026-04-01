---
name: commit
description: Review changes, run lint/format and typo checks, then create a git commit with English message. Use when user wants to commit, save changes, or says "커밋".
allowed-tools: Bash, Read, Grep, Glob, Agent(typo-checker), Agent(vulnerability-package-checker)
---

# Git Commit

변경 사항을 확인하고, 린트/포맷 및 오타 검사를 수행한 뒤, 영어 커밋 메시지를 작성하여 커밋한다.

## 실행 절차

1. `git status`와 `git diff --staged`, `git diff`를 실행하여 변경 사항을 파악한다.
2. `git log --oneline -10`으로 최근 커밋 메시지 스타일을 확인한다.
3. 변경된 파일의 언어를 감지하고 해당 lint/format 도구를 실행한다:
   - JavaScript/TypeScript: `biome check --write .`
   - Go: `golangci-lint run --fix && gofmt -w .`
   - Rust: `cargo clippy --fix && cargo fmt`
   - Python: `ruff check --fix . && ruff format .`
   - Shell: `shfmt -i 4 -ci -w <파일>`
   - Markdown: `rumdl fmt .`
4. 변경된 파일 중 의존성 파일(package.json, go.mod, Cargo.toml, requirements.txt, pyproject.toml 등)이 있으면 `vulnerability-package-checker` 에이전트를 실행한다.
5. `typo-checker` 에이전트를 실행하여 변경된 파일의 오타를 검사한다. 오타가 발견되면 사용자에게 알린다.
6. 변경 사항을 분석하여 커밋 메시지를 작성한다:
   - 제목은 영어 소문자로, 동사 원형으로 시작 (add, fix, update, tidy, upgrade, remove 등)
   - 70자 이내로 간결하게 작성
   - 세부 내용이 필요하면 본문에 영어 또는 한글로 작성
   - Co-Authored-By 라인은 포함하지 않음
   - Claude Code 사용 문구를 포함하지 않음
7. 사용자에게 커밋 메시지와 대상 파일을 보여주고 확인을 받는다.
8. 확인 후 `git status`와 `git diff`를 다시 실행하여 추가 변경이 없는지 확인한다. 변경이 있으면 사용자에게 알리고 지시를 받는다 (자동으로 처음부터 다시 수행하지 않는다).
9. `git add`로 해당 파일만 staging하고 커밋한다.
10. 커밋 메시지는 HEREDOC 형식으로 전달한다:

```bash
git commit -m "$(cat <<'EOF'
커밋 메시지 제목

선택적 본문
EOF
)"
```

## 주의사항

- `git add -A`나 `git add .`는 사용하지 않는다. 파일을 명시적으로 지정한다.
- .env, credentials 등 민감한 파일은 커밋하지 않는다.
- push는 하지 않는다. 사용자가 별도로 요청할 때만 push한다.
