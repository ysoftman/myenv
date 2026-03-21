---
name: commit
description: 변경 사항을 확인하고 커밋 메시지를 작성하여 커밋합니다.
disable-model-invocation: true
---

아래 절차에 따라 git commit을 수행하세요.

1. `git status`와 `git diff --staged`, `git diff`를 실행하여 변경 사항을 파악합니다.
2. `git log --oneline -10`으로 최근 커밋 메시지 스타일을 확인합니다.
3. 변경 사항을 분석하여 커밋 메시지를 작성합니다:
   - 제목은 영어 소문자로, 동사 원형으로 시작 (add, fix, update, tidy, upgrade, remove 등)
   - 70자 이내로 간결하게 작성
   - 세부 내용이 필요하면 본문에 영어 또는 한글로 작성
   - Co-Authored-By 라인은 포함하지 않음
   - Claude Code 사용 문구를 포함하지 않음
4. 사용자에게 커밋 메시지와 대상 파일을 보여주고 확인을 받습니다.
5. 확인 후 `git add`로 해당 파일만 staging하고 커밋합니다.
6. 커밋 메시지는 HEREDOC 형식으로 전달합니다:

```bash
git commit -m "$(cat <<'EOF'
커밋 메시지 제목

선택적 본문
EOF
)"
```

주의사항:

- `git add -A`나 `git add .`는 사용하지 않습니다. 파일을 명시적으로 지정합니다.
- .env, credentials 등 민감한 파일은 커밋하지 않습니다.
- push는 하지 않습니다. 사용자가 별도로 요청할 때만 push합니다.
