# Mod 재사용 코드

`summary`(`~/workspace/myenv/.claude/mods/summary`)와 배포 진행 패널 mod 에서 쓰는 코드를 정리했다. 전체 맥락은 summary mod 의 `register.tsx` 와 `tests/` 를 본다.

## 목차

- 보임 기준 토글
- 탭 전환 감지(폴링)
- 바인딩된 키 읽기
- band 칩 한 줄 합치기
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

`toggleKey` 가 없으면 칩·단축키 안내를 그리지 않고, `help` 에 설정 방법을 넣는다.

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

## band 칩 한 줄 합치기

각 mod 가 같은 helper 를 갖는다(플러그인끼리 코드를 공유할 수 없으므로 복사).

```ts
import type { RenderNode } from "claude-code";

// band 를 함께 쓰는 mod 들의 규칙: 칩은 key 가 BAND_CHIPS 인 Box 에 넣고, 위 hook 이 아래 tree 에서
// 그 Box 를 빼내 자기 칩 뒤에 이어 붙여 band 맨 아래에 한 줄로 다시 그린다.
const BAND_CHIPS = "band-chips";

const takeChips = (
	node: RenderNode | undefined,
): [RenderNode[], RenderNode | undefined] => {
	if (!node || typeof node === "string" || node.type !== "Box")
		return [[], node];
	if (node.props?.key === BAND_CHIPS) return [node.children ?? [], undefined];
	let chips: RenderNode[] = [];
	const children = (node.children ?? []).flatMap((child) => {
		if (chips.length) return [child];
		const [found, rest] = takeChips(child);
		chips = found;
		return rest === undefined ? [] : [rest];
	});
	return chips.length ? [chips, { ...node, children }] : [[], node];
};
```

band hook:

```tsx
on("ui.render", { component: "AbovePrompt" }, async ($, e, next) => {
	// 설문 중이거나, 패널이 보이거나(패널 안 Button 이 단축키를 받음), 바인딩이 없으면 아래에 양보
	if (e.props.hasSurvey || isShown || !toggleKey) return next(e);
	const [chips, rest] = takeChips(await next(e));
	const { Box, Button, Text } = $.ui.resolve(e);

	return (
		<Box flexDirection="column">
			{rest}
			<Box key={BAND_CHIPS} gap={2}>
				<Button
					plain
					key="toggle"
					action={TOGGLE_ACTION}
					onPress={() => toggle($)}
				>
					<Text backgroundColor="#313244" color="#b4befe">
						{` ${toggleKey} `}
					</Text>
					<Text color="#7f849c"> {TAB_TITLE}</Text>
				</Button>
				{chips}
			</Box>
		</Box>
	);
});
```

진행 상태 같은 정보 줄이 있으면 `{rest}` 위에 두고, 칩 줄은 항상 맨 아래에 둔다.

## 테스트 mock

```tsx
import type { On } from "claude-code";
import { expect, mock, test } from "claude-code/testing";

const BAND = {
	component: "AbovePrompt",
	props: {
		hasSurvey: false,
		isWorking: false,
		maxRows: 3,
		bodyColumns: 100,
		scroll: { offset: 0, bodyRows: 3 },
		view: {},
	},
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
	// 아래 hook: 엔진 대신 아무것도 안 그리는 band
	on("ui.render", { component: "AbovePrompt" }, ($, e) => {
		const { Box } = $.ui.resolve(e);
		return <Box key="engine" />;
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
		const ui = await $.ui.mount({ plugin: "my-mod", surface, ...BAND });
		const rows = await ui.findAll({ type: "Box", key: "band-chips" });
		expect(rows).toHaveLength(1);
		await ui.unmount();
	}
});
```

다른 mod 의 칩 줄을 흉내낼 때는 test hook 이 `<Box key="band-chips"><Button key="other" onPress={...}>...</Button></Box>` 를 그리게 하고, 합쳐진 줄의 Button key 를 `(rows[0]?.children as { type: string; props: { key?: string } }[])` 에서 확인한 뒤 `ui.press({ key: "other", plugin: "test" })` 로 눌러 본다.
