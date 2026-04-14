---
name: typos
description: Check typos in the current project (English and Korean). Scans variables, functions, comments, docs, and strings. Run before commits or on demand. Use when user asks to check spelling, find typos, or review text quality.
allowed-tools: Agent(typo-checker), Bash(typos:*), Bash(git diff:*), Bash(git status:*), Bash(fd:*), Bash(rg:*), Bash(printf:*)
---

# Typo Check

프로젝트의 오타, 철자 오류, 네이밍 불일치를 검사한다.

Input: $ARGUMENTS

## 인자 파싱

- 인자가 있으면 해당 파일/디렉터리만 검사한다 (예: `/typos src/`, `/typos README.md`)
- 인자가 없으면 `git status`로 변경된 파일을 우선 검사한다
- 변경된 파일이 없으면 사용자에게 전체 프로젝트 스캔 여부를 확인한다

## 검사 범위

- 영어 및 한국어 텍스트
- 변수명, 함수명, 문자열 리터럴, 주석
- 문서 및 README 파일

## 실행 절차

1. 인자를 파싱하여 검사 대상을 결정한다
2. 인자가 없으면 `git status`로 변경된 파일을 확인한다
3. `typo-checker` 에이전트를 실행하여 대상 파일의 오타를 검사한다
4. 결과를 파일 경로와 함께 정리하여 보고한다:
   - 파일별로 그룹화
   - 각 오타에 대해 위치, 원본, 수정 제안을 표시
   - 오타가 없으면 "오타가 발견되지 않았습니다"로 보고
   - 결과 리포트 본문은 `printf`에 ANSI 녹색(`\033[32m ... \033[0m`) escape 코드를 씌워 터미널에 녹색으로 출력한다:

   ```bash
   printf '\033[32m%s\033[0m\n' "$(cat <<'EOF'
   오타 리포트
   ...
   EOF
   )"
   ```
