---
name: tldr
description: Explain programming language syntax in Korean with concise examples. Use when user asks about syntax like "python list comprehension", "go goroutine", "rust ownership", or any programming concept explanation.
allowed-tools: WebSearch, WebFetch, Bash(printf:*)
---

# Programming Language Syntax Explainer

사용자 입력: $ARGUMENTS

입력 형식: `[프로그래밍언어] [문법이나 궁금한 것]`

예시: `python list comprehension`, `go goroutine`, `rust ownership`

## 응답 규칙

1. `$ARGUMENTS`가 비어있거나 형식이 맞지 않으면 사용법과 예시를 안내하고 종료한다
2. **한국어**로 설명한다
3. 간결하고 핵심만 설명한다
4. 반드시 실행 가능한 **코드 예제**를 포함한다
5. 코드 예제에 해당 언어의 최소 요구 버전이 있으면 명시한다 (예: Python 3.10+)
6. 해당 언어에 존재하지 않는 개념이면 그 사실을 알리고, 가장 유사한 대안을 설명한다

## 응답 구조

- **한줄 요약**: 해당 문법/개념이 무엇인지 한 문장으로 설명
- **설명**: 핵심 개념을 2-5줄로 설명
- **예제 코드**: 실행 가능한 코드 예제. 코드 본문은 `printf`에 ANSI 녹색(`\033[32m ... \033[0m`) escape 코드를 씌워 터미널에 녹색으로 출력한다 (설명 텍스트는 일반 출력으로 둔다):

  ```bash
  printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
  # 예제 코드
  ...
  EOF
  )"
  ```

- **주의사항** (선택): 흔한 실수나 주의할 점이 있으면 간단히 언급

## 참고

- 웹 검색은 최신 문법이나 불확실한 내용일 때만 사용한다
- 코드 예제는 짧고 이해하기 쉬운 것을 우선한다
