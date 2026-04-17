---
name: issue
description: Create GitHub issues with auto-generated English titles and contextual body content. Use when the user wants to create an issue, report a bug, request a feature, file a ticket, or says "이슈 만들어줘", "이슈 생성", "버그 리포트", "feature request". Also trigger when the user discusses a bug or feature and then says "이거 이슈로 올려줘" or similar.
allowed-tools: Bash, Read, Grep, Glob
---

# GitHub Issue Creator

대화 맥락을 기반으로 현재 repo에 GitHub issue를 생성한다.

## 실행 절차

1. 현재 repo 정보를 확인한다:
   - `gh repo view --json nameWithOwner,url,visibility -q '"\(.nameWithOwner)\t\(.url)\t\(.visibility)"'`로 repo name, url, visibility를 한 번에 확인
   - url의 호스트가 `github.com`인지(엔터프라이즈 GHES는 대상 아님), visibility가 `PUBLIC`인지 기록해 둔다 — step 5의 민감 정보 검사에서 사용
   - `gh api user -q '.login'`으로 현재 사용자 계정을 확인 (assignee용)

2. 대화 맥락을 분석하여 이슈 내용을 구성한다:
   - 버그, 기능 요청, 개선, 질문 등 이슈 유형을 파악
   - 관련 코드, 에러 메시지, 변경 사항 등을 수집

3. 이슈를 작성한다:
   - **제목**: 영어, 간결하게 (70자 이내), 동사 원형으로 시작
     - 버그: "Fix ...", "Resolve ..."
     - 기능: "Add ...", "Implement ..."
     - 개선: "Improve ...", "Update ...", "Refactor ..."
   - **본문**: 아래 템플릿을 기반으로 맥락에 맞게 작성 (불필요한 섹션은 생략)

4. 라벨을 자동 선택한다:
   - `gh label list --json name,description -q '.[] | "\(.name): \(.description)"'`으로 사용 가능한 라벨과 설명을 확인
   - 이슈 내용을 분석하여 가장 적절한 라벨을 선택 (복수 선택 가능):
     - 버그/오류/크래시 → bug
     - 새 기능/추가 → enhancement, feature
     - 문서 관련 → documentation
     - 성능 관련 → performance
     - 보안 관련 → security
     - 리팩토링/코드 정리 → refactoring
     - 테스트 관련 → test
     - 긴급/심각 → critical, urgent
     - 질문/논의 → question
   - 위는 일반적인 매핑이며, repo에 실제 존재하는 라벨 중에서만 선택한다
   - 라벨의 description도 참고하여 내용에 가장 부합하는 라벨을 고른다
   - 적절한 라벨이 없으면 라벨 없이 생성

5. **공용(public) GitHub 저장소 민감 정보 검사** — step 1에서 기록한 host가 `github.com`이고 visibility가 `PUBLIC`인 경우에만 수행한다(private·GHES·github.com이 아닌 호스트는 생략). 작성한 **제목·본문·라벨 문자열**에서 다음과 같은 **실제 민감 정보** 후보를 스캔한다:
   - 회사명/내부 도메인 (사내 서비스명, `*.corp`·`*.internal` 등 비공개 도메인, 고유한 회사/조직명)
   - 사용자 ID/이메일 (실명·실ID·실이메일 형태 — 공개 도메인이 아닌 사내/기업 이메일 포함)
   - 패스워드/토큰/API 키/비밀번호 유사 문자열 (예: `password=`, `token=`, `api_key=`, `AKIA...`, `ghp_...`, `Bearer ...`, JWT, 프라이빗 키 블록)
   - 내부 IP/호스트/URL (예: `10.*`, `172.16-31.*`, `192.168.*`, `*.corp`, `*.internal`)

   **더미/예시 값은 경고하지 않는다:** `aaa`, `1234`, `foo/bar/baz`, `example.com`, `user@example.com`, `test`, `dummy`, `placeholder`, 명백한 랜덤 해시 예제 등은 무시한다. 애매하면 알리는 쪽으로 기운다.

   후보가 하나라도 발견되면 step 6의 승인 절차에 들어가기 전에 **별도로** 사용자에게 알린다:
   - 어느 위치(제목/본문/라벨)의 어느 부분에 무엇이 있는지 목록으로 제시 (ANSI 노란색 `\033[33m ... \033[0m` 권장)
   - "공용 GitHub 저장소라 이 이슈는 공개됩니다. 계속 진행할까요?"로 물은 뒤 **사용자 응답을 기다린다**
   - 사용자가 거부하면 이슈를 만들지 않고 대기. 승인하거나 마스킹/제거 지시를 하면 그에 따라 초안을 수정한 뒤 step 6으로 진행한다.

   후보가 없으면 이 step을 조용히 통과한다.

6. 사용자에게 제목, 본문, 라벨을 보여주고 확인을 받는다. 제목·본문·라벨은 `printf`에 ANSI 녹색(`\033[32m ... \033[0m`) escape 코드를 씌워 터미널에 녹색으로 출력한다. **반드시 Bash 도구로 `printf` 명령을 실제 실행한다** — 코드 블록으로만 보여주면 안 된다:

   ```bash
   printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
   제목: ...
   본문:
   ...
   라벨: ...
   EOF
   )"
   ```

7. 확인 후 `gh issue create`로 이슈를 생성한다:

   ```text
   gh issue create --title "제목" --body "본문" --assignee @me [--label "라벨"]
   ```

8. 생성된 이슈 URL을 사용자에게 알려준다.

## 본문 템플릿

이슈 유형에 따라 적절한 섹션을 선택하여 사용한다. 모든 섹션이 필수는 아니며, 맥락에 따라 유연하게 구성한다.

### Bug Report

```markdown
## Description

[버그에 대한 간단한 설명]

## Steps to Reproduce

1. [재현 단계]

## Expected Behavior

[기대 동작]

## Actual Behavior

[실제 동작]

## Additional Context

[에러 로그, 스크린샷, 관련 코드 경로 등]
```

### Feature Request / Enhancement

```markdown
## Description

[기능 또는 개선에 대한 설명]

## Motivation

[왜 이 변경이 필요한지]

## Proposed Solution

[제안하는 해결 방법]

## Additional Context

[참고 자료, 관련 코드 경로 등]
```

## 주의사항

- 이슈 생성 전 반드시 사용자 확인을 받는다
- 본문에 민감한 정보(비밀번호, 토큰 등)가 포함되지 않도록 주의한다
- 대화에서 충분한 맥락이 없으면 사용자에게 추가 정보를 요청한다
