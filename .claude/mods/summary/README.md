# summary mod

Claude Code 세션에서 지금 무슨 일이 일어나고 있는지 한 패널에 모아 보여 주는 mod 다.

| 박스 | 내용 |
| --- | --- |
| 헤더 | 진행 중인 일: ⏳ 메인 턴, 🔧 스킬, 🤖 서브에이전트, 📝 recent 요약 생성 |
| recent | 끝난 턴마다 한 줄 요약 (haiku), 경과·소요 시간, 토큰 |
| agents & jobs | 서브에이전트, background shell, session cron |
| files | 세션이 고친 파일과 git 상태 (`1×` Edit 횟수, `·` shell·서브에이전트가 바꾼 파일) |
| git | 브랜치, upstream, ahead/behind, 최근 커밋, 현재 브랜치의 열린 PR (아래 "PR 줄") |
| skills | 실행한 스킬과 모델 |
| turn time | 메인 턴마다 걸린 시간 sparkline |

## PR 줄

git 박스에 현재 브랜치의 열린 PR 을 한 줄로 보여 준다. 예: `PR #12 ✅ approved · CI ✔ · 💬 2 unresolved`

| 항목 | 표시 |
| --- | --- |
| draft | `✎ draft` |
| 리뷰 | `✅ approved`, `❌ changes requested`, `👀 review required` |
| CI (마지막 커밋의 check 종합) | `CI ✔`, `CI ✗ failed`, `CI ⋯ running`, check 가 없으면 생략 |
| 미해결 리뷰 스레드 | `💬 N unresolved`, 0 이면 생략 |

approve 됐고 draft 가 아니며 CI 가 통과했거나 없으면 `⇢ ready: merge it in the web UI` 와 PR URL 을 덧붙인다. 머지는 사람이 GitHub 웹 UI 에서 한다.

- `gh` 로그인과 GitHub (Enterprise 포함) remote 가 필요하다. remote 는 gh 처럼 `upstream`, `github`, `origin` 순으로 골라 그 호스트로 `gh api graphql` 을 한 번 부른다. gh 가 없거나 인증이 안 됐거나 열린 PR 이 없으면 줄을 그리지 않는다.
- 필수 리뷰 규칙이 없는 저장소(reviewDecision 없음)는 최신 리뷰에 approve 가 있고 change request 가 없으면 approved 로 본다.
- 남의 fork 에서 같은 브랜치 이름으로 연 PR 은 빼고, 내 fork 에서 연 PR 은 보여 준다.
- 네트워크 호출이라 세션 시작과 턴이 끝날 때 읽되, 직전 조회 후 60초가 안 됐으면 건너뛴다. Bash 로 `git push` 나 `gh pr ...` 를 실행한 직후, 브랜치가 바뀐 뒤 처음 끝나는 턴에는 바로 읽는다. 쉬는 동안 받은 approve 는 다음 턴이 끝날 때 보인다.

## 설치

이 폴더를 plugin 디렉터리로 로드한다. 둘 중 하나를 쓴다.

- `~/.claude/settings.json` 의 `env.CLAUDE_CODE_PLUGIN_DIRS` 에 이 폴더 경로를 넣는다 (여러 개면 `:` 로 구분).
- `claude --plugin-dir <이 폴더>` 로 실행한다.

myenv 의 `installclaudecode.sh` 는 `.claude/mods/*` 를 `CLAUDE_CODE_PLUGIN_DIRS` 에 넣고, 아래 단축키도 그 키나 action 이 비어 있을 때만 `keybindings.json` 에 넣어 준다(예전 `app:toggleDiffPreSession` 바인딩은 옮겨 준다).

Claude Code 2.1.296 에서 확인했다 (PR 줄은 2.1.299).

## 사용

Claude 를 시작하면 패널이 바로 열린다. 다만 엔진은 요청 없이 연 패널을 터미널이 144칸(전에 열어 두고 손으로 닫지 않았다면 110칸) 이상일 때만 그린다. 그보다 좁으면 터미널을 넓히거나 `/summary` 를 실행할 때 보인다. `/reload-plugins` 때는 다시 열지 않는다.

- `/summary`: 패널 열기/닫기. 다른 탭에 가려져 있으면 닫지 않고 앞으로 꺼낸다. 출력은 남기지 않는다.
- `/summary help`: 사용법. 단축키를 설정하지 않았으면 설정 방법도 보여 준다.

## 단축키

plugin 은 단축키를 직접 등록할 수 없어, 각자 `~/.claude/keybindings.json` 에 추가해야 한다. `command:<이름>` action 은 그 슬래시 명령을 입력한 것처럼 실행하므로 `/summary` 를 키에 묶는다.

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    { "context": "Chat", "bindings": { "ctrl+x s": "command:summary" } }
  ]
}
```

이미 `keybindings.json` 이 있으면 파일을 덮어쓰지 말고, `"context": "Chat"` 블록의 `bindings` 에 `"ctrl+x s": "command:summary"` 한 줄만 추가한다(블록이 없으면 추가한다). 예전에 넣은 `"Global"` 의 `"ctrl+x s": "app:toggleDiffPreSession"` 은 지운다.

바인딩하기 전에는 패널 하단과 프롬프트 아래 힌트 줄에 `/summary` 가 보이고, 바인딩하면 그 키가 보인다. 다른 키에 묶어도 그 키가 안내에 표시된다.
