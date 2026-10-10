---
name: mod-authoring
description: Claude Code mod(함수 hook 플러그인 — pane/패널, 프롬프트 위 band, 단축키 칩, 슬래시 명령)를 만들거나 고칠 때 내장 `plugin-authoring` 스킬과 함께 쓰는 실전 가이드. 패널 탭 표시·전환, keybindings action 단축키 안내(프롬프트 아래 힌트 줄 tail), 여러 mod 가 band·힌트 줄을 함께 쓰는 법, 테스트 kit 요령, 수정이 반영되지 않을 때 로드 경로 확인을 다룬다. 사용자가 mod, 모드 만들어, 패널, pane, band, 프롬프트 위 한 줄, 힌트 줄, PromptHint, 단축키 칩, 탭 전환, "reload-plugins 했는데 안 바뀜", `.claude/mods`, `dev-mods`, `register.tsx`, `ui.render`, `$.ui.open` 등을 언급하면 plugin-authoring 과 함께 반드시 사용한다.
---

# Mod Authoring

내장 `plugin-authoring` 스킬이 API·타입·예제를 준다면, 이 스킬은 실제 mod(`summary`, 배포 진행 패널 mod)를 만들며 엔진 코드로 확인한 동작과 거기서 나온 패턴을 담는다. 둘을 같이 로드하고, API 세부는 `plugin-authoring` 의 타입 파일(`claude-code.d.ts`)을 grep 해 확인한다.

재사용 코드(토글, 단축키 읽기, 힌트 줄 단축키, 테스트 mock)는 [references/snippets.md](references/snippets.md) 에 있다. 해당 기능을 구현할 때 읽는다.

## 작업 순서

1. `plugin-authoring` 을 로드하고, 쓰려는 이벤트·props 를 타입 파일에서 확인한다.
2. **이 세션이 어느 사본을 로드하는지 먼저 확인한다** (아래 "로드 경로"). 엉뚱한 사본을 고치면 테스트는 통과하는데 화면은 그대로다.
3. 구현한다. TS/TSX 는 biome 기본 포맷(tab, 큰따옴표, 세미콜론)으로 쓰고 `biome check --write <파일>` 로 맞춘다.
4. 요구 동작마다 테스트를 쓰고, **수정 전 코드에서 그 테스트가 실패하는지** 확인한다: `git stash push <register.tsx>` → `claude plugin test .` → `git stash pop`. 새 코드에서만 통과해야 회귀를 잡는 테스트다.
5. 검증: `claude plugin validate .`, `claude plugin test .`, `bunx -p typescript tsc -p .`. validate·test 는 타입 체크를 하지 않으니 tsc 를 빼먹지 않는다.
6. 로드되는 사본에 반영 → `/reload-plugins` → 사용자에게 화면 확인을 부탁한다. 테스트 kit 은 엔진 동작을 흉내낼 뿐이라 실제 배치·탭·단축키는 화면에서만 확인된다. 확인 전에는 "테스트는 통과, 화면 미확인"으로 보고한다.

## 로드 경로: 고쳤는데 반영이 안 될 때

`/reload-plugins` 는 플러그인을 **로드된 위치에서** 다시 읽을 뿐이다.

| 로드 방식 | 실제로 읽는 위치 |
| --- | --- |
| `CLAUDE_CODE_PLUGIN_DIRS`, `--plugin-dir` | 작업 폴더 그대로 (hot reload) |
| marketplace 설치 플러그인 | `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` |
| 이 세션에서 만든 mod | `~/.claude/dev-mods/<session>/<mod>/` |

- 설치 경로는 `~/.claude/plugins/installed_plugins.json` 의 `installPath`, 실행 인자는 `ps -ax -o pid,args | rg '[c]laude'` 로 확인한다.
- `diff -rq --exclude=types --exclude=tsconfig.json <작업 저장소 mod> <캐시 mod>` 로 차이를 본다.
- 개발 중에는 `claude --plugin-dir <저장소>` 로 시작하는 게 가장 깔끔하다. 이미 떠 있는 세션이면 바뀐 파일만 캐시 같은 경로로 복사하고 `/reload-plugins` 한다. 캐시 패치는 플러그인 업데이트 때 덮어써진다는 점을 사용자에게 알린다.

## Pane(패널)과 탭

엔진 동작 (v2.1.29x, 엔진 코드로 확인):

- pane 이 여러 개면 **하나만 보이고 나머지는 탭**이다. 탭 제목은 여백 포함 최대 12칸에서 잘리므로 `title` 은 10칸 이내로 둔다(한글 1자 = 2칸, 예: `배포 패널` 9칸). 본문 제목은 pane 안에서 따로 그린다.
- 이미 열린 id 로 `$.ui.open` 을 다시 부르면 **제목만 바뀌고 앞으로 올라오지 않는다**. 반면 새로 연 pane 은 (키보드를 가진 pane 이 없으면) 보이는 탭이 된다. 그래서 가려진 탭을 앞으로 꺼내려면 close 후 다시 open 한다(대신 탭 순서가 맨 뒤로 간다).
- `focus: true` 는 빈 composer 일 때만 앞으로 올리고 키보드까지 가져간다. 탭 전환 용도로는 쓰지 않는다.
- `$.ui.panes()` 는 **자기 plugin 의 pane 만** 준다. `isShown` = 지금 보이는 탭, `isPlaced: false` = 좁은 터미널에서 대기 중(사람이 요청하지 않은 open 은 144칸, 한 번 연 id 는 110칸 미만이면 대기). 대기 중인 pane 은 `isShown` 도 false 다.
- **가려진 탭의 pane 은 render 되지 않는다.** 그 안의 Button 과 action 단축키도 사라진다.
- 탭을 클릭해 전환해도 이벤트가 없다. `$.clock.every` 에서 `$.ui.panes()` 를 폴링해 보임 여부가 바뀔 때만 상태를 갱신하고 다시 그린다.

토글은 "열림" 이 아니라 "보임" 기준으로 짠다: 보이면 닫고, 열려 있지만 가려졌거나 대기 중이면 닫았다 다시 열고, 없으면 연다. 열림 기준으로 짜면 가려진 탭에서 단축키를 눌렀을 때 앞으로 나오지 않고 닫혀 버린다. 코드는 snippets 의 "보임 기준 토글".

## 단축키

- plugin 은 키를 직접 등록할 수 없다. `~/.claude/keybindings.json` 의 `Global` 에서 **평소 엔진 handler 가 없는 action**(예: `app:cycleDiffBase`, `app:toggleDiffPreSession`)에 chord 를 묶고, 그 action 을 단 `Button` 이 chord 를 받는다. 그 action 의 엔진 handler 가 떠 있으면(예: diff 패널이 열림) 엔진 동작이 우선한다는 점을 README 에 적는다.
- Button 은 **mount 돼 있을 때만** chord 를 받는다. 어느 render site 든 상관없고(v2.1.296 엔진 코드 확인: Button 컴포넌트가 mount 되며 action 을 등록), `display="none"` Box 안에 숨겨도 mount 는 유지된다. 그래서 pane 이 보이면 pane 안에, 안 보이면(닫힘·가려짐·대기) 프롬프트 아래 힌트 줄에 숨긴 Button 을 둬서 언제나 하나는 mount 되게 한다(아래 "힌트 줄").
- 안내는 실제로 바인딩한 사람에게만 보인다: `keybindings.json` 을 읽어 그 action 에 묶인 키를 찾고, 있으면 그 키를 힌트 줄·pane 하단·명령 설명에 표시한다. 없으면 단축키 안내와 숨긴 Button 을 빼고, `help` 출력에 설정 방법을 넣고, 토스트에는 슬래시 명령 이름을 쓴다. 키 이름을 코드에 고정하면 설정하지 않은 사람에게 눌러도 안 되는 단축키가 보인다.
- 다시 읽는 시점은 `session.start`, 자기 명령 실행, 관련 스킬 시작 정도면 충분하다(매 프레임 읽지 않는다). 명령 목록의 설명 문구는 등록 시점 값이라 다음 세션에 바뀐다.
- README 에는 바인딩 JSON 과 함께 "이미 파일이 있으면 덮어쓰지 말고 `Global` 블록의 `bindings` 에 한 줄만 추가"를 적는다.
- 엔진 기본 `ctrl+x tab` 은 band·pane 에 포커스를 주고, 그 상태에서 Tab·Enter 로 탭을 고를 수 있다. 바인딩과 무관하게 동작하니 pane 하단 안내에 같이 둬도 된다.

## 힌트 줄(PromptHint): 단축키 안내 자리

band 에 칩 줄을 두면 할 일이 없을 때도 프롬프트 위 한 줄을 늘 차지한다. 단축키 안내는 프롬프트 아래 힌트 줄(`? for shortcuts` 줄) 끝에 흐린 글씨로 붙인다. summary mod 가 이 방식이다.

- `ui.render` 의 `{ component: "PromptHint" }` 에서 `props.tail` 을 채워 `next` 로 넘긴다. 엔진이 원래 줄(pill 포함)을 그대로 그리고 끝에 ` · ` 와 tail 을 dim 으로 붙이며, 줄 끝에서 자르고 4칸 미만이면 뺀다(v2.1.296 엔진 코드 확인). tail 에 구분자를 직접 넣지 않는다.
- **tail 이어 붙이기 규칙**: 위 hook 이 넘긴 `e.props.tail` 을 지우지 말고 `[e.props.tail, 내 안내].filter(Boolean).join(" · ")` 로 이어 붙인다. 여러 mod 가 끼어도 한 줄로 합쳐진다.
- chord 용 Button 은 `next(...)` 결과(`{ type: "engine", ref }` 노드 또는 아래 mod 의 tree)와 함께 column Box 로 감싸고, `display="none"` Box 안에 넣는다. 화면에는 안 보이지만 mount 돼 chord 를 받는다.
- 자기 pane 이 보이는 동안에는 `return next(e)` 로 빠진다(pane 안 Button 이 chord 를 받으므로).
- 바인딩이 없으면 숨긴 Button 없이 tail 만 둔다(슬래시 명령 이름을 쓰거나 아예 빼기).
- band 의 `ctrl+x ctrl+a`(`[-]`) 접기는 band tree 를 unmount 해서 거기 둔 Button 의 chord 도 죽는다. 힌트 줄에 두면 이 영향이 없다.

코드는 snippets 의 "힌트 줄 단축키".

## Band(AbovePrompt) 함께 쓰기

진행 상태처럼 정말 보여 줄 정보가 있을 때만 band 를 쓴다.

- band 는 여러 plugin 의 hook 이 위에서 아래로 감싸는 chain 이다. 위 hook 은 `next(e)` 결과(아래가 그린 tree)를 자기 tree 에 넣는다. 그릴 게 없으면 `return next(e)` 하고, `e.props.hasSurvey` 면 양보한다. `next(e)` 결과를 빠뜨리면 아래 mod 가 화면에서 사라진다.
- plugin tree 가 하나라도 있으면 엔진이 `[-]` 를 붙여 band 한 줄을 차지한다. 숨긴 Button 만 band 에 두어도 빈 줄 + `[-]` 가 남으니, 단축키용 Button 은 band 가 아니라 힌트 줄에 둔다.
- 자기 pane 이 보이는 동안에는 band 를 그리지 않는다(같은 정보가 pane 에 있으므로).
- 예전 규칙(단축키 칩을 key `band-chips` Box 에 넣고 위 hook 이 `takeChips` 로 모아 한 줄로 그림)은 다른 band mod 가 아직 쓴다. 새 mod 는 힌트 줄을 쓴다.
- `next(e)` 결과는 plain-data tree(`{ type, props, children }`)다. Box·Button 의 key 는 `props.key` 에 있다. 다른 mod 의 Button 을 옮겨 그려도 그대로 눌린다(테스트로 확인).

## 다시 그리기와 상태

- 모듈 변수는 reload 때마다 초기화된다. 스피너 프레임, 보임 여부처럼 다시 계산할 수 있는 그리기용 값에만 쓴다.
- `$.state` atom 은 세션 동안 유지되고, 값을 쓰면 그 값을 읽은 render 가 다시 그려진다. 계약은 `types/index.d.ts` 의 `PluginState` 에 선언하고, 키 이름을 바꾸면 계약도 같이 바꾼다.
- 값이 바뀔 때만 쓴다(`read` 후 비교하고 `update`). 매 tick 쓰면 불필요하게 다시 그려지고, write 횟수를 검사하는 테스트도 깨진다.
- 애니메이션은 필요할 때만: 작업 중일 때 10fps, 그 밖엔 느리게 또는 멈춤. `$.ui.invalidate("ui.render")` 를 무조건 돌리지 않는다.

## 테스트 kit 요령

자세한 mock 코드는 snippets 의 "테스트 mock".

- kit 에는 엔진 bottom 이 없다. `ui.open`/`ui.close`/`ui.panes` 를 메모리로 흉내내고, `isShown` 은 실제처럼(대기 중이면 false, 새로 연 pane 은 보이는 탭) 계산한다. 흉내가 실제와 다르면 테스트가 엉뚱한 동작을 승인한다.
- `$.session.start` 를 부르려면 `session.start`·`command.register` 응답 hook 이 필요하다. `$.clock.every` 는 보통 `session.start` 에서 걸리므로, 타이머를 테스트하려면 세션을 시작해야 한다.
- 모든 `on(...)` 은 테스트에서 `$` 를 처음 부르기 전에 등록한다.
- `mock.clock(on)` 이 준 clock 의 `advance(ms)` 로 타이머를 돌린다.
- `find`/`findAll` 에서 Text 의 key 는 남지 않으니 문구로 찾는다. `findAll` 결과의 `children` 에서 key 는 `props.key` 다.
- 다른 mod 를 흉내낸 test hook 의 Button 은 `ui.press({ key, plugin: "test" })` 로 누른다.
- `keybindings.json` 읽기는 `env.get`(HOME), `fs.read` 를 mock 한다. mock 이 없으면 읽기가 실패하므로 "바인딩 없음" 시나리오가 된다.
- UI 테스트는 `["terminal", "desktop"]` 두 surface 를 모두 돈다.

## 문서에 없는 엔진 동작 확인

타입 파일의 doc comment 를 먼저 본다. 그래도 모르면(예: 탭 폭, 이미 열린 id 의 open 동작) 엔진 코드를 직접 확인한다.

```bash
strings -n 8 "$(readlink -f "$(command -v claude)")" | rg -o '.{0,200}shownId.{0,200}' | head
```

엔진 코드는 버전마다 바뀌고 이름이 축약돼 있다. 확인한 사실과 추정을 구분해 보고하고, 확인한 버전을 함께 적는다.
