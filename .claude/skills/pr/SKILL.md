---
name: pr
description: Create GitHub pull requests with English titles and structured body content. Use when the user wants to create a PR, open a pull request, merge request, or says "PR 만들어줘", "PR 생성", "풀리퀘", "pull request". Also trigger when the user finishes work on a branch and says "이거 올려줘" or similar.
allowed-tools: Bash, Read, Grep, Glob
---

# GitHub PR Creator

현재 브랜치의 변경 사항을 분석하여 GitHub pull request를 생성한다.

## 실행 절차

1. 현재 상태를 확인한다:
   - `git branch --show-current`로 현재 브랜치 확인
   - `gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'`으로 기본 브랜치 확인
   - 현재 브랜치가 기본 브랜치이면 사용자에게 알리고 중단한다

2. 변경 사항을 파악한다:
   - `git log <base-branch>..HEAD --oneline`으로 커밋 목록 확인
   - `git diff <base-branch>...HEAD --stat`으로 변경된 파일 통계 확인
   - `git diff <base-branch>...HEAD`로 전체 diff 확인
   - 커밋 메시지와 diff를 분석하여 변경 내용을 파악한다

3. 관련 GitHub 이슈를 탐색한다:
   - 커밋 메시지에서 이슈 번호 패턴 (#123) 을 검색한다
   - 대화 맥락에서 사용자가 언급한 이슈 번호를 확인한다
   - 이슈 번호가 있으면 `gh issue view <번호> --json title,number -q '"\(.number): \(.title)"'`로 이슈 정보를 확인한다

4. PR 내용을 작성한다:
   - **제목**: 영어, 70자 이내, 동사 원형으로 시작 (add, fix, update, refactor 등)
   - **본문**: 한글로 작성, 아래 템플릿을 기반으로 작성

5. 사용자에게 제목, 본문을 보여주고 확인을 받는다. 제목과 본문은 `printf`에 ANSI 녹색(`\033[32m ... \033[0m`) escape 코드를 씌워 터미널에 녹색으로 출력한다:

   ```bash
   printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
   제목: ...
   본문:
   ...
   EOF
   )"
   ```

6. 확인 후 remote에 push하고 PR을 생성한다:
   - remote에 현재 브랜치가 없으면 `git push -u origin <branch>`로 push
   - PR 생성:

   ```text
   gh pr create --title "제목" --body "본문" --assignee @me
   ```

7. 생성된 PR URL을 사용자에게 알려준다.

## 본문 템플릿

관련 이슈가 있으면 본문 첫 줄에 `Closes #이슈번호`를 명시한다. PR 머지 시 관련 이슈가 자동으로 닫힌다. 이슈가 여러 개이면 각각 `Closes`를 붙여 쉼표로 구분한다.

```markdown
Closes #123

## 변경 사항

- [변경 사항 1]
- [변경 사항 2]
- [변경 사항 3]
```

커밋이 많거나 변경이 복잡하면 카테고리별로 그룹핑한다:

```markdown
Closes #123, Closes #456

## 변경 사항

### 기능 추가

- [새 기능 설명]

### 버그 수정

- [버그 수정 설명]

### 리팩토링

- [리팩토링 설명]
```

관련 이슈가 없으면 `#이슈번호` 줄을 생략하고 변경 사항 섹션부터 시작한다.

## 주의사항

- PR 생성 전 반드시 사용자 확인을 받는다
- 본문에 민감한 정보(비밀번호, 토큰 등)가 포함되지 않도록 주의한다
- push는 PR 생성에 필요한 경우에만 수행하며, force push는 하지 않는다
- base 브랜치는 기본 브랜치를 사용하되, 사용자가 다른 브랜치를 지정하면 그에 따른다
