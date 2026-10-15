# Mod 재사용 코드

`summary`(`~/workspace/myenv/.claude/mods/summary`)와 `rule-guard`(`~/workspace/myenv/.claude/mods/rule-guard`) mod 에서 쓰는 코드를 정리했다. 전체 맥락은 두 mod 의 `register.tsx` 와 `tests/` 를 본다.

## 목차

- 보임 기준 토글
- 탭 전환 감지(폴링)
- 바인딩된 키 읽기
- help 명령과 단축키 명령
- 힌트 줄 단축키 안내
- 테스트 mock

## 보임 기준 토글

```ts
const PANE = "my-pane";
// 탭은 여백 포함 12칸에서 잘리므로 10칸 이내
const TAB_TITLE = "내 패널";
let isShown = false;

// 보이면 닫고, 가려졌거나 대기 중이면 닫았다 다시 열어 앞으로, 없으면 연다. 열었으면 true.
const toggle = async ($: EngineInterface) => {
	const pane = (await $.ui.panes()).find((p) => p.id === PANE);
	if (pane) await $.ui.close({ id: PANE });
	isShown = !pane?.isShown;
	if (isShown) await $.ui.open({ id: PANE, title: TAB_TITLE });
	$.ui.invalidate("ui.render");

	return isShown;
};
```

`$.state` atom 으로 보임 여부를 들고 있다면(summary 방식) `ui.close` hook 에서도 false 로 갱신한다. 사람이 닫기 표시나 `ctrl+x x` 로 닫는 경우가 있기 때문이다.

## 탭 전환 감지(폴링)

탭 클릭에는 이벤트가 없어서 타이머로 확인한다. 바뀔 때만 다시 그린다. 패널이 보일 때 힌트 줄 안내를 빼는 데 쓴다. 안내를 늘 두면(rule-guard 방식) 필요 없다.

```ts
on("session.start", async ($, e, next) => {
	$.clock.every(100, async () => {
		const wasShown = isShown;
		isShown = (await $.ui.panes()).some((p) => p.id === PANE && p.isShown);
		if (isShown !== wasShown) $.ui.invalidate("ui.render");
	});

	return next(e);
});
```

## 바인딩된 키 읽기

단축키는 `~/.claude/keybindings.json` 의 `"Chat"` 문맥에 `"ctrl+x m": "command:my-cmd"` 로 묶는다. 키가 `/my-cmd` 를 입력한 것처럼 실행한다. 문맥은 따지지 않고 그 action 에 묶인 키를 찾는다.

```ts
const CMD = "my-cmd";
let toggleKey: string | undefined;
// 엔진 action pane:previous/pane:next(모든 plugin pane 탭 이동)에 묶인 키
let tabKeys = "";

const syncToggleKey = async ($: EngineInterface) => {
	try {
		const { bindings = [] } = JSON.parse(
			await $.fs.read(`${await $.env.get("HOME")}/.claude/keybindings.json`),
		) as {
			bindings?: { context?: string; bindings?: Record<string, unknown> }[];
		};
		const bound = bindings.flatMap((b) => Object.entries(b.bindings ?? {}));
		const keyOf = (action: string) =>
			bound.find(([, a]) => a === action)?.[0];
		toggleKey = keyOf(`command:${CMD}`);
		tabKeys = [keyOf("pane:previous"), keyOf("pane:next")]
			.filter(Boolean)
			.join(" ");
	} catch {
		toggleKey = undefined;
		tabKeys = "";
	}
};
```

`toggleKey` 가 없으면 단축키 안내 대신 `/my-cmd` 를 쓰고, `help` 에 설정 방법을 넣는다(아래 "help 명령과 단축키 명령"). `tabKeys` 는 비어 있지 않을 때만 pane 하단에 탭 이동 안내로 그린다. render 가 읽는 값이면 모듈 변수 대신 `$.state` atom 에 둔다(summary·rule-guard 의 `chord`, `tabs`).

## help 명령과 단축키 명령

`command:` action 은 인자를 넣을 수 없으니, 인자 없는 `/my-cmd` 가 토글이어야 한다. 토글하는 명령이 따로 있어야 하면 `my-cmd-pane` 처럼 인자 없는 명령을 하나 더 등록한다(rule-guard 의 `/rule-guard-pane`).

```ts
const usage = () =>
	[
		`/${CMD}  패널 열기/닫기${toggleKey ? ` (${toggleKey})` : ""}`,
		`/${CMD} help  이 도움말`,
		...(toggleKey
			? []
			: [
					"",
					'단축키로 열고 닫으려면 ~/.claude/keybindings.json 의 "Chat" bindings 에',
					`"ctrl+x m": "command:${CMD}" 를 추가하세요 (README 참고, 다른 키도 됨).`,
				]),
	].join("\n");

on("session.start", async ($, e, next) => {
	await syncToggleKey($);
	await $.command.register({
		name: CMD,
		description: `패널 열기/닫기${toggleKey ? ` (${toggleKey})` : ""} · help: 사용법`,
		argumentHint: "[help]",
		// 턴이 도는 중에 단축키를 눌러도 바로 실행
		immediate: true,
	});

	return next(e);
});

on("command.run", { command: CMD }, async ($, e) => {
	// 세션 중에 바인딩했어도 바로 반영되게 다시 읽는다
	await syncToggleKey($);
	if (e.args.trim() === "help") return { text: usage() };
	await toggle($);
	// text 를 주면 단축키를 누를 때마다 대화 기록에 출력이 남는다
	return {};
});
```

테스트는 바인딩 없음·있음 두 경우를 본다. `keybindings.json` 을 읽는 `fs.read` mock 이 없으면 "바인딩 없음"이 된다.

```ts
test("help 는 바인딩이 없을 때만 설정 방법을 보여 준다", async ($, on) => {
	await setup($, on);
	const { text } = await $.command.run({ command: "my-cmd", args: "help" } as never);
	expect(text).toContain(`"ctrl+x m": "command:my-cmd"`);
});
```

## 힌트 줄 단축키 안내

프롬프트 아래 힌트 줄 끝에 안내를 tail 로 붙인다. 위 hook 이 넘긴 tail 은 이어 붙인다. 키는 `command:` 바인딩이 받으므로 Button 을 숨겨 둘 필요가 없다.

```tsx
on("ui.render", { component: "PromptHint" }, async ($, e, next) => {
	// 패널이 보이면 패널 하단에 같은 안내가 있다
	if (isShown) return next(e);
	const hint = toggleKey ? `${toggleKey} ${TAB_TITLE}` : `/${CMD}`;
	const tail = [e.props.tail, hint].filter(Boolean).join(" · ");

	return next({ ...e, props: { ...e.props, tail } });
});
```

## 테스트 mock

```tsx
import type { On } from "claude-code";
import { expect, mock, test } from "claude-code/testing";

const HINT = {
	component: "PromptHint",
	requestId: "prompt-hint",
	props: { isDraft: false, isWorking: false, hint: "? for shortcuts" },
} as const;

// 엔진 대신 pane 목록을 메모리로 흉내낸다. 새로 연 pane 은 보이는 탭이 된다.
const fakePanes = (on: On) => {
	const state = { isOpen: false, isBehind: false };
	on("ui.open", () => {
		state.isOpen = true;
		state.isBehind = false;
		return { value: { isPlaced: true as const } };
	});
	on("ui.close", () => {
		state.isOpen = false;
		return { value: undefined };
	});
	on("ui.panes", () => ({
		value: state.isOpen
			? [
					{
						id: "my-pane",
						title: "내 패널",
						isShown: !state.isBehind,
						isFocused: false,
						isPlaced: true,
					},
				]
			: [],
	}));
	return state;
};

// keybindings.json 의 Chat 문맥에 /my-cmd 를 묶어 둔 사용자
const bindToggleKey = (on: On) => {
	on("env.get", () => ({ value: "/home/me" }));
	on("fs.read", (_, e) => ({
		value:
			e.path === "/home/me/.claude/keybindings.json"
				? JSON.stringify({
						bindings: [
							{
								context: "Chat",
								bindings: { "ctrl+x m": "command:my-cmd" },
							},
						],
					})
				: "",
	}));
};

test("hidden tab comes back to front", async ($, on) => {
	// 모든 on() 은 $ 를 처음 부르기 전에
	const clock = mock.clock(on);
	bindToggleKey(on);
	const panes = fakePanes(on);
	// 아래 hook: 엔진 대신 받은 tail 을 그대로 그려 tail 을 검사할 수 있게 한다
	on("ui.render", { component: "PromptHint" }, ($, e) => {
		const { Text } = $.ui.resolve(e);
		return <Text>{e.props.tail ?? ""}</Text>;
	});
	// $.session.start 에 필요한 응답 (타이머가 session.start 에서 걸린다)
	on("command.register", (_, e) => ({ value: { command: e.name } }));
	on("session.start", (_, e) => ({ cwd: e.cwd }));
	await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });

	// 단축키(command:my-cmd)와 같은 경로: 인자 없는 실행, 출력 없음
	const run = () =>
		$.command.run({
			command: "my-cmd",
			args: "",
			origin: { kind: "composer" },
			presentation: { isFullscreen: true, columns: 200 },
		});
	expect((await run()).text).toBeUndefined();
	panes.isBehind = true;
	await clock.advance(100);
	for (const surface of ["terminal", "desktop"] as const) {
		const ui = await $.ui.mount({ plugin: "my-mod", surface, ...HINT });
		expect(await ui.find({ text: /^ctrl\+x m 내 패널$/ })).toBeDefined();
		await ui.unmount();
	}
	await run();
	expect(panes).toMatchObject({ isOpen: true, isBehind: false });
});
```

위 hook 이 넘긴 tail 을 이어 붙이는지는 `$.ui.mount({ ...HINT, props: { ...HINT.props, tail: "deploy 3/9" } })` 로 마운트해 `/^deploy 3\/9 · ctrl\+x m 내 패널$/` 를 찾아 확인한다.
