---
name: commit
description: Review changes, run lint/format, then create a git commit with English message. Use when user wants to commit, save changes, or says "커밋", "git commit", "git ci".
allowed-tools: Bash, Read, Grep, Glob
---

# Git Commit

변경 사항을 확인하고, 린트/포맷을 수행한 뒤, 영어 커밋 메시지를 작성하여 커밋한다.

## 실행 절차

1. `git status`와 `git diff --staged`, `git diff`를 실행하여 변경 사항을 파악한다.
2. `git log --oneline -10`으로 최근 커밋 메시지 스타일을 확인한다.
3. **공용(public) GitHub 저장소 민감 정보 검사** — `git remote get-url origin`으로 원격이 `github.com`인지 확인한다(엔터프라이즈 GHES는 대상 아님). github.com이면 `gh repo view --json visibility -q .visibility` 로 public 여부를 확인한다(명령 실패 시 보수적으로 public으로 간주). public인 경우, 변경 사항(`git diff`, `git diff --staged`, 새 파일 내용)에서 다음과 같은 **실제 민감 정보** 후보를 스캔한다:
   - 회사명/내부 도메인 (사내 서비스명, `*.corp`·`*.internal` 등 비공개 도메인, 고유한 회사/조직명)
   - 사용자 ID/이메일 (실명·실ID·실이메일 형태 — 공개 도메인이 아닌 사내/기업 이메일 포함)
   - 패스워드/토큰/API 키/비밀번호 유사 문자열 (예: `password=`, `token=`, `api_key=`, `AKIA...`, `ghp_...`, `Bearer ...`, JWT, 프라이빗 키 블록)
   - 내부 IP/호스트/URL (예: `10.*`, `172.16-31.*`, `192.168.*`, `*.corp`, `*.internal`)

   **더미/예시 값은 경고하지 않는다:** `aaa`, `1234`, `foo/bar/baz`, `example.com`, `user@example.com`, `test`, `dummy`, `placeholder`, 명백한 랜덤 해시 예제 등은 무시한다. 애매하면 알리는 쪽으로 기운다.

   민감 후보가 하나라도 발견되면 step 6의 승인 절차에 들어가기 전에 **별도로** 사용자에게 알린다:
   - 어떤 파일의 어느 줄에 무엇이 있는지 목록으로 제시 (ANSI 노란색 `\033[33m ... \033[0m` 권장)
   - "공용 GitHub 저장소라 그대로 커밋하면 공개됩니다. 계속 진행할까요?"로 물은 뒤 **사용자 응답을 기다린다**
   - 사용자가 거부하면 커밋하지 않고 대기. 승인하거나 해당 라인을 수정/제거하라고 지시하면 그에 따른다.

   후보가 없으면 이 step을 조용히 통과한다.
4. 변경된 파일의 언어를 감지하고 해당 lint/format 도구를 실행한다:
   - JavaScript/TypeScript: `biome check --write .`
   - Go: `golangci-lint run --fix && gofmt -w .`
   - Rust: `cargo clippy --fix && cargo fmt`
   - Python: `ruff check --fix . && ruff format .`
   - Shell: `shfmt -i 4 -ci -w <파일>`
   - Markdown: `rumdl fmt .`
5. 변경 사항을 분석하여 커밋 메시지를 작성한다:
   - 제목은 영어 소문자로, 동사 원형으로 시작 (add, fix, update, tidy, upgrade, remove 등)
   - 70자 이내로 간결하게 작성
   - 세부 내용이 필요하면 본문에 영어 또는 한글로 작성
   - Co-Authored-By 라인은 포함하지 않음
   - Claude Code 사용 문구를 포함하지 않음
6. 사용자에게 커밋 메시지 초안과 대상 파일 목록을 제시하고 **사용자의 별도 응답을 기다린다**. 커밋 메시지는 ANSI 녹색(`\033[32m ... \033[0m`)으로 터미널에 출력한다:

   ```bash
   printf '\033[32m%s\033[0m\n' "커밋 메시지 제목"
   ```

   본문이 있는 경우 제목과 본문을 모두 녹색으로 함께 출력한다.

   **중요 — 승인의 범위:** 사용자가 스킬을 호출할 때 한 "commit", "커밋", "git ci" 등의 초기 요청은 **스킬 실행에 대한 승인일 뿐, `git commit` 명령 실행에 대한 승인이 아니다.** 초기 호출만 보고 바로 커밋을 실행하면 사용자가 메시지를 검토할 기회가 사라진다. 반드시 메시지 초안을 먼저 출력한 뒤 멈추고, 사용자가 "ok", "좋아", "go", "진행" 같은 **새로운 메시지로 승인을 줄 때까지** 다음 단계로 넘어가지 않는다. 사용자가 메시지 수정을 요청하면 반영한 새 초안을 다시 제시하고 또 승인을 기다린다.
7. 승인을 받은 뒤 `git status`와 `git diff`를 다시 실행하여 추가 변경이 없는지 확인한다. 변경이 있으면 사용자에게 알리고 지시를 받는다 (자동으로 처음부터 다시 수행하지 않는다).
8. `git add`로 해당 파일만 staging하고 커밋한다.
9. 커밋 메시지는 HEREDOC 형식으로 전달한다:

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
