# Mod 재사용 코드

`summary`(`~/workspace/myenv/.claude/mods/summary`)와 배포 진행 패널 mod 에서 쓰는 코드를 정리했다. 전체 맥락은 summary mod 의 `register.tsx` 와 `tests/` 를 본다.

## 목차

- 보임 기준 토글
- 탭 전환 감지(폴링)
- 바인딩된 키 읽기
- 힌트 줄 단축키
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

탭 클릭에는 이벤트가 없어서 타이머로 확인한다. 바뀔 때만 다시 그린다.

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

```ts
// 평소 엔진 handler 가 없는 action 을 빌린다
const TOGGLE_ACTION = "app:cycleDiffBase";
let toggleKey: string | undefined;

const syncToggleKey = async ($: EngineInterface) => {
	try {
		const { bindings = [] } = JSON.parse(
			await $.fs.read(`${await $.env.get("HOME")}/.claude/keybindings.json`),
		) as {
			bindings?: { context?: string; bindings?: Record<string, unknown> }[];
		};
		toggleKey = bindings
			.filter((b) => b.context === "Global")
			.flatMap((b) => Object.entries(b.bindings ?? {}))
			.find(([, action]) => action === TOGGLE_ACTION)?.[0];
	} catch {
		toggleKey = undefined;
	}
};
```

`toggleKey` 가 없으면 단축키 안내와 숨긴 Button 을 그리지 않고, `help` 에 설정 방법을 넣는다.

```ts
const usage = () =>
	[
		`/my-cmd  패널 열기/닫기${toggleKey ? ` (${toggleKey})` : ""}`,
		...(toggleKey
			? []
			: [
					"",
					`단축키로 열고 닫으려면 ~/.claude/keybindings.json 의 "Global" bindings 에`,
					`"ctrl+x k": "${TOGGLE_ACTION}" 를 추가하세요.`,
				]),
	].join("\n");
```

## 힌트 줄 단축키

프롬프트 아래 힌트 줄 끝에 안내를 tail 로 붙이고, chord 를 받을 Button 은 숨겨서 mount 한다. 위 hook 이 넘긴 tail 은 이어 붙인다.

```tsx
on("ui.render", { component: "PromptHint" }, async ($, e, next) => {
	// 패널이 보이면 패널 안 Button 이 단축키를 받는다
	if (isShown) return next(e);
	const hint = toggleKey ? `${toggleKey} ${TAB_TITLE}` : "/my-cmd";
	const tail = [e.props.tail, hint].filter(Boolean).join(" · ");
	const below = await next({ ...e, props: { ...e.props, tail } });
	if (!toggleKey) return below;
	const { Box, Button } = $.ui.resolve(e);

	return (
		<Box flexDirection="column">
			{below}
			<Box display="none">
				<Button
					plain
					key="toggle"
					label={TAB_TITLE}
					action={TOGGLE_ACTION}
					onPress={() => toggle($)}
				/>
			</Box>
		</Box>
	);
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

// keybindings.json 에 토글 action 을 묶어 둔 사용자
const bindToggleKey = (on: On) => {
	on("env.get", () => ({ value: "/home/me" }));
	on("fs.read", (_, e) => ({
		value:
			e.path === "/home/me/.claude/keybindings.json"
				? JSON.stringify({
						bindings: [
							{
								context: "Global",
								bindings: { "ctrl+x k": "app:cycleDiffBase" },
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

	await $.command.run({
		command: "my-cmd",
		args: "",
		origin: { kind: "composer" },
		presentation: { isFullscreen: true, columns: 200 },
	});
	panes.isBehind = true;
	await clock.advance(100);
	for (const surface of ["terminal", "desktop"] as const) {
		const ui = await $.ui.mount({ plugin: "my-mod", surface, ...HINT });
		expect(await ui.find({ text: /^ctrl\+x k 내 패널$/ })).toBeDefined();
		expect((await ui.find({ key: "toggle" }))?.props).toMatchObject({
			action: "app:cycleDiffBase",
		});
		await ui.unmount();
	}
});
```

위 hook 이 넘긴 tail 을 이어 붙이는지는 `$.ui.mount({ ...HINT, props: { ...HINT.props, tail: "deploy 3/9" } })` 로 마운트해 `/^deploy 3\/9 · ctrl\+x k 내 패널$/` 를 찾아 확인한다.
