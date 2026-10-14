# rule-guard mod

전역 `CLAUDE.md` 에 글로만 적힌 규칙을 `tool.call` hook 으로 실제로 막는 mod 다. 모델이 규칙을 잊거나 세션 system-reminder 가 반대로 요구해도(예: 커밋에 `Claude-Session:` 트레일러를 넣으라는 요구) 도구 호출 단계에서 거부된다. 거부 사유에는 룰 id, 대안, 이 세션에서 끄는 방법이 들어가고, 화면에는 `🛡 <id>` 토스트가 뜬다.

## 룰

모두 기본 on 이다.

| id | 막는 것 | 통과하는 예 |
| --- | --- | --- |
| `no-pr-merge` | `gh pr merge`, `gh api`·`curl`·`wget` 의 `pulls/<n>/merge` 호출, graphql `mergePullRequest`, 이름에 `merge_pull_request` 가 들어간 MCP 도구 | `gh pr view`, 로컬 `git merge` |
| `no-ai-trailer` | `git commit`, `gh pr create`/`edit` 명령에 `Co-Authored-By: Claude`, `Claude-Session:`, `Generated with Claude Code`, `claude.ai/code/session` (대소문자 무시) | 다른 사람의 `Co-Authored-By` |
| `bun-over-npm` | 명령 위치의 `npm`, `npx` | `bun`, `bunx`, `echo npm`, 커밋 메시지 속 npm |
| `rg-fd` | 명령 위치의 `grep`(`egrep`, `fgrep`), `find` | `git grep`, `--find-renames`, `git log --grep` |
| `lint-before-commit` | 세션 cwd 안에서 고친 lint 대상 파일이 남아 있는데 lint 없이 `git commit` | `biome check --write x && git commit ...` |
| `banned-words` | `bannedPaths` 아래 파일 수정, 또는 cwd 가 `bannedPaths` 아래일 때의 `git commit`, `gh pr`/`gh issue` 의 `create`/`edit` 에 금지어 | 설정하지 않으면 아무것도 막지 않는다 |

- 명령 위치: 줄 시작, `|` `;` `&&` `||` `(` `$(` 뒤, `then`·`do`·`xargs`·`env`·`sudo` 등 뒤. 따옴표 안 문자열(`$(` 없는 것)과 heredoc 본문은 명령으로 보지 않는다.
- `lint-before-commit`: Edit/Write/MultiEdit/NotebookEdit 가 성공한 파일 중 세션 cwd 안(심볼릭 링크는 실제 경로로 확인)이고 `lint-formatting` 스킬 도구가 다루는 확장자(`js` `ts` `jsx` `tsx` `json` `go` `rs` `py` `html` `sh` `md` `toml` 등)만 기록한다. 메모리 파일, scratchpad 같은 cwd 밖 파일은 무시한다. Bash 명령에 `biome`, `ruff`, `rumdl`, `shfmt`, `shellcheck`, `golangci-lint`, `gofmt`, `gopls check`, `prettier`, `pyright`, `taplo`, `cargo fmt`/`clippy`, `make|just|bun run lint|fmt|format` 이 들어 있으면 대기 목록을 전부 비운다. lint 결과(성공·실패)는 보지 않는다.

## 설치

이 폴더를 plugin 디렉터리로 로드한다. 둘 중 하나를 쓴다.

- `~/.claude/settings.json` 의 `env.CLAUDE_CODE_PLUGIN_DIRS` 에 이 폴더 경로를 `:` 로 이어 붙인다.

  ```json
  {
    "env": {
      "CLAUDE_CODE_PLUGIN_DIRS": "~/workspace/myenv/.claude/mods/summary:~/workspace/myenv/.claude/mods/rule-guard"
    }
  }
  ```

- `claude --plugin-dir <이 폴더>` 로 실행한다.

Claude Code 2.1.299 에서 확인했다.

## 사용

- `/rule-guard`: 룰마다 id, 상태(on / off / 설정 안 됨), 이 세션 차단 횟수, 설명을 표로 보여 준다. lint 대기 파일이 있으면 목록도 보여 준다.
- `/rule-guard-pane`: 같은 상태를 패널로 열고 닫는다. 전체 화면이면 대화 기록 오른쪽에 붙고, 아니면 프롬프트 위에 뜬다. 상태가 바뀌면 패널도 바로 바뀐다. 다른 탭에 가려져 있으면 닫지 않고 앞으로 꺼낸다. 출력은 남기지 않는다.
- `/rule-guard off <id>`, `/rule-guard on <id>`: 이 세션 동안만 끄고 켠다. 잘못된 id 면 사용 가능한 id 를 알려 준다.
- `/rule-guard help`: 사용법. 단축키가 없으면 설정 방법도 보여 준다.

모델은 슬래시 명령을 실행할 수 없어서 룰을 끄는 건 사용자만 할 수 있다. 예를 들어 호환성 문제로 npm 이 꼭 필요하면 `/rule-guard off bun-over-npm` 으로 끈다. 끈 상태와 차단 횟수는 `/reload-plugins` 를 해도 세션 동안 유지되고, 새 세션에서는 다시 모두 켜진다.

## 패널 단축키

`keybindings.json` 의 `command:<이름>` action 은 그 슬래시 명령을 입력한 것처럼 실행한다. action 에는 인자를 넣을 수 없어서 인자 없는 `/rule-guard-pane` 을 따로 둔다. `~/.claude/keybindings.json` 에 다음을 넣는다. 파일이 이미 있으면 덮어쓰지 말고 `"Chat"` 블록의 `bindings` 에 한 줄만 추가한다(없으면 블록을 추가한다).

```json
{
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+x r": "command:rule-guard-pane"
      }
    }
  ]
}
```

- 다른 키에 묶어도 된다. 힌트 줄·패널·`help`·명령 목록 안내가 그 키를 따른다.
- 바인딩이 있으면 프롬프트 아래 힌트 줄 끝에 `ctrl+x r rule-guard` 가 보인다.
- 엔진 action 을 빌리지 않으므로 diff 패널과 겹치지 않는다.

## banned-words 설정

`bannedWords`(쉼표 구분 금지어)와 `bannedPaths`(쉼표 구분 경로 prefix, `~` 사용 가능)를 둘 다 넣어야 동작한다. 하나라도 비어 있으면 `/rule-guard` 에 "설정 안 됨" 으로 나오고 아무것도 막지 않는다. `/config` 메뉴의 rule-guard 항목에서 넣거나 `~/.claude/settings.json` 에 직접 넣는다. 키는 plugin 이름 `rule-guard` 다(엔진은 `rule-guard@inline` 도 읽는다).

```json
{
  "pluginConfigs": {
    "rule-guard": {
      "options": {
        "bannedWords": "secretword,another-secret",
        "bannedPaths": "~/workspace/public-repo"
      }
    }
  }
}
```

금지어는 대소문자를 무시하고 부분 문자열로 찾는다. 경로는 적힌 경로와 심볼릭 링크를 따라간 실제 경로를 모두 확인한다.

## 개발

```sh
claude plugin validate .
claude plugin test .
biome check --write hooks/register.tsx tests/rule-guard.test.tsx types/index.d.ts
```

타입 체크는 mod 가 한 번 로드돼 `.claude-plugin/types/` 가 생긴 뒤 `bunx -p typescript tsc -p .` 로 한다.
