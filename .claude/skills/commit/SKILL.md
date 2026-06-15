---
name: commit
description: Review changes, run lint/format, then create a git commit with English message. Use when user wants to commit, save changes, or says "커밋", "git commit", "git ci".
allowed-tools: Bash, Read, Grep, Glob
model: sonnet
effort: low
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

   민감 후보가 하나라도 발견되면 **이 경우에만 예외적으로** 커밋을 멈추고 사용자에게 알린다(공개 저장소 노출은 되돌리기 어렵기 때문):
   - 어떤 파일의 어느 줄에 무엇이 있는지 목록으로 제시 (ANSI 노란색 `\033[33m ... \033[0m` 권장)
   - "공용 GitHub 저장소라 그대로 커밋하면 공개됩니다. 계속 진행할까요?"로 물은 뒤 **사용자 응답을 기다린다**
   - 사용자가 거부하면 커밋하지 않고 대기. 승인하거나 해당 라인을 수정/제거하라고 지시하면 그에 따른다.

   후보가 없으면 이 step을 조용히 통과한다.
4. 변경된 파일의 언어를 감지하고 `lint-formatting` 스킬의 표준 명령어를 실행하여 lint/format을 적용한다.
   - **Markdown 파일이 포함된 경우**: 반드시 `rumdl fmt --extend-disable MD013 .` 형태로 실행한다. `--extend-disable MD013` 플래그를 빠뜨리면 한국어 본문이 80자 wrap 조건에 걸려 false positive 가 대량 발생한다. 추가 규칙을 더 끄려면 `--extend-disable MD013,MD024` 처럼 콤마로 나열하되 MD013 은 항상 포함한다.
5. 변경 사항을 분석하여 커밋 메시지를 작성한다:
   - 제목은 영어 소문자로, 동사 원형으로 시작 (add, fix, update, tidy, upgrade, remove 등)
   - 70자 이내로 간결하게 작성
   - 세부 내용이 필요하면 본문에 영어 또는 한글로 작성
   - Co-Authored-By 라인은 포함하지 않음
   - Claude Code 사용 문구를 포함하지 않음
6. 작성한 커밋 메시지를 ANSI 녹색(`\033[32m ... \033[0m`)으로 터미널에 출력한다. **확인을 기다리지 않고 바로 커밋까지 진행한다** (확인을 두지 않는 이유는 아래 "확인 절차를 두지 않는 이유" 참고).

   **반드시 Bash 도구로 아래 `printf` 명령을 실제 실행한다.** 코드 블록이나 인라인 텍스트로만 명령을 보여주면 안 된다 — 실제 실행 결과(녹색 텍스트)가 터미널에 찍혀야 한다:

   ```bash
   printf '\033[32m%s\033[0m\n' "커밋 메시지 제목"
   ```

   본문이 있는 경우 제목과 본문을 모두 녹색으로 한 번의 `printf` 실행으로 함께 출력한다.
7. 커밋 직전 `git status`와 `git diff`를 다시 실행하여 step 1 이후 의도치 않은 변경이 섞이지 않았는지 확인한다. 예상과 다른 변경이 있으면 커밋을 멈추고 사용자에게 알린다.
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
- push는 하지 않는다. push가 필요하면 사용자에게 안내하고, **push 실행 전에는 반드시 사용자 확인을 받는다** (원격 반영은 되돌리기 어려우므로 확인 대상은 commit 이 아니라 push 다).

## 확인 절차를 두지 않는 이유

commit 직전에 사용자 확인(별도 메시지 승인)을 받지 않고, 한 turn 안에서 초안 출력과 커밋까지 끝낸다. 이유는 두 가지다:

1. **commit 은 되돌리기 쉽다.** 잘못된 커밋은 `git revert` / `git commit --amend` / `git reset` 으로 사후에 수정·취소할 수 있다. 정작 되돌리기 어려운 단계는 원격에 반영하는 `push` 이고, 확인은 그 단계에서 받는다(이 스킬은 push 를 하지 않는다).
2. **속도.** 이 스킬은 `model: sonnet` + `effort: low` 로 동작하는데, 스킬의 model/effort 오버라이드는 **스킬을 트리거한 turn 에만** 적용된다. 확인을 별도 메시지로 받으면 그다음 turn(실제 커밋 실행)은 **세션 기본 모델(예: opus + max effort)로 복귀**해 느려진다. 확인을 별도 turn 으로 분리하지 않고 한 turn 안에서 끝내야 sonnet + low 가 유지되어 빠르다.

예외: step 3 의 공용 저장소 민감 정보가 발견된 경우에만 멈추고 확인을 받는다(공개 노출은 되돌리기 어렵기 때문).
