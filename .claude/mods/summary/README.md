# summary mod

Claude Code 세션에서 지금 무슨 일이 일어나고 있는지 한 패널에 모아 보여 주는 mod 다.

| 박스 | 내용 |
| --- | --- |
| recent | 끝난 턴마다 한 줄 요약 (haiku), 경과·소요 시간, 토큰 |
| tasks | 서브에이전트, background shell, session cron |
| files | 세션이 고친 파일과 git 상태 (`1×` Edit 횟수, `·` shell·서브에이전트가 바꾼 파일) |
| git | 브랜치, upstream, ahead/behind, 최근 커밋 |
| skills | 실행한 스킬과 모델 |
| turn time | 메인 턴마다 걸린 시간 sparkline |

## 설치

이 폴더를 plugin 디렉터리로 로드한다. 둘 중 하나를 쓴다.

- `~/.claude/settings.json` 의 `env.CLAUDE_CODE_PLUGIN_DIRS` 에 이 폴더 경로를 넣는다 (여러 개면 `:` 로 구분).
- `claude --plugin-dir <이 폴더>` 로 실행한다.

myenv 의 `installclaudecode.sh` 는 `.claude/mods/*` 를 `CLAUDE_CODE_PLUGIN_DIRS` 에 넣고, 아래 단축키도 그 키나 action 이 비어 있을 때만 `keybindings.json` 에 넣어 준다.

Claude Code 2.1.296 에서 확인했다.

## 사용

- `/summary`: 패널 열기/닫기
- `/summary help`: 사용법. 단축키를 설정하지 않았으면 설정 방법도 보여 준다.

## 단축키

plugin 은 단축키를 직접 등록할 수 없어, 각자 `~/.claude/keybindings.json` 에 추가해야 한다. 평소 비어 있는 엔진 action `app:toggleDiffPreSession` 을 빌려 쓰므로, diff 패널이 열려 있을 때는 diff 패널의 원래 동작이 우선한다.

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    { "context": "Global", "bindings": { "ctrl+x s": "app:toggleDiffPreSession" } }
  ]
}
```

이미 `keybindings.json` 이 있으면 파일을 덮어쓰지 말고, 기존 `"context": "Global"` 블록의 `bindings` 에 `"ctrl+x s": "app:toggleDiffPreSession"` 한 줄만 추가한다.

바인딩하기 전에는 패널 하단과 프롬프트 아래 힌트 줄에 `/summary` 가 보이고, 바인딩하면 그 키가 보인다. 다른 키에 묶어도 그 키가 안내에 표시된다.
