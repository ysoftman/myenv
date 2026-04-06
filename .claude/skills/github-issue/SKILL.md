---
name: github-issue
description: Create GitHub issues with auto-generated English titles and contextual body content. Use when the user wants to create an issue, report a bug, request a feature, file a ticket, or says "이슈 만들어줘", "이슈 생성", "버그 리포트", "feature request". Also trigger when the user discusses a bug or feature and then says "이거 이슈로 올려줘" or similar.
allowed-tools: Bash, Read, Grep, Glob
---

# GitHub Issue Creator

대화 맥락을 기반으로 현재 repo에 GitHub issue를 생성한다.

## 실행 절차

1. 현재 repo 정보를 확인한다:
   - `gh repo view --json nameWithOwner -q '.nameWithOwner'`로 repo를 확인
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

5. 사용자에게 제목, 본문, 라벨을 보여주고 확인을 받는다.

6. 확인 후 `gh issue create`로 이슈를 생성한다:

   ```text
   gh issue create --title "제목" --body "본문" --assignee @me [--label "라벨"]
   ```

7. 생성된 이슈 URL을 사용자에게 알려준다.

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
