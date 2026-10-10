import type { AgentStatus, On } from "claude-code";
import type { Engine } from "claude-code/testing";
import { expect, mock, test } from "claude-code/testing";

const BAND = {
	component: "AbovePrompt",
	requestId: "band",
	props: {
		hasSurvey: false,
		isWorking: true,
		maxRows: 20,
		bodyColumns: 100,
		scroll: { offset: 0, bodyRows: 20 },
		view: {},
	},
} as const;

const PANE = {
	component: "Pane",
	requestId: "summary",
	props: {
		title: "summary",
		isFocused: false,
		bodyColumns: 100,
		placement: "dock",
		scroll: { offset: 0, bodyRows: 40 },
		view: {},
	},
} as const;

const SPIN = "[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]";

const spawn = (description: string, subagentType: string, extra: object = {}) =>
	({
		tool_use_id: `tu-${description}`,
		prompt: "do it",
		description,
		subagentType,
		provider: { plugin: "engine", tier: "core" },
		parentModel: "claude-opus-5-5",
		background: true,
		fork: false,
		...extra,
	}) as const;

const setup = async ($: Engine, on: On) => {
	const clock = mock.clock(on, { now: 1_000_000 });
	const live: Record<string, AgentStatus> = {};
	let n = 0;
	on("session.start", (_, e) => ({ cwd: e.cwd }));
	on("command.register", (_, e) => ({ value: { command: e.name } }));
	on("agent.spawn", (_, e) => {
		const id = `a${++n}`;
		if (e.workflow === undefined) {
			live[id] = "running";
		}
		return {
			model:
				e.subagentType === "reviewer"
					? "claude-sonnet-5-5"
					: "claude-haiku-5-5",
			agentId: id,
		};
	});
	on("agent.list", () => ({
		value: Object.entries(live).map(([id, status]) => ({
			id,
			status,
			description: "",
			type: "fork",
		})),
	}));
	const fail: Record<
		string,
		{ deny: string } | { isError: true; result: null; text: string }
	> = {};
	on("tool.call", (_, e) => fail[String(e.tool)] ?? { result: "ok" });
	const git = { status: "" };
	on("process.run", (_, e) => ({
		value: {
			exitCode: 0,
			stdout: e.argv.includes("rev-parse") ? "/repo\n" : git.status,
			stderr: "",
			isStdoutTruncated: false,
			isStderrTruncated: false,
		},
	}));
	on("fs.stat", (_, e) => ({
		value: {
			kind: "file",
			size: 0,
			mtimeMs: 0,
			isLink: false,
			realPath: e.path,
		},
	}));
	on("turn.complete", (_, e) => ({ text: e.answer }));
	on("prompt.submit", (_, e) => ({ text: e.text }));
	// biome-ignore lint/correctness/useYield: a streaming hook must be a generator; this one streams nothing
	on("turn.step", async function* (_, e) {
		return {
			turnId: e.turnId,
			index: e.index,
			answer: "",
			toolUses: [],
			stopReason: "end_turn",
			usage: null,
		};
	});
	on("command.list", () => ({
		value: ["jira", "commit"].map((name) => ({
			name,
			description: "",
			source: "user" as const,
		})),
	}));
	const ai: { text?: string; prompt?: string } = { text: "summary pane 커밋" };
	const usage = {
		input_tokens: 0,
		output_tokens: 0,
		cache_creation_input_tokens: 0,
		cache_read_input_tokens: 0,
	};
	on("model.complete", (_, e) => {
		ai.prompt = e.prompt;
		return {
			value:
				ai.text === undefined
					? { isAnswered: false, reason: "empty-reply", usage }
					: { isAnswered: true, text: ai.text, usage },
		};
	});
	const panes: string[] = [];
	const hidden = new Set<string>();
	on("ui.open", (_, e) => {
		hidden.delete(e.id);
		panes.push(e.id);
		return { value: { isPlaced: true } };
	});
	on("ui.close", (_, e) => {
		panes.splice(panes.indexOf(e.id), 1);
		return { value: undefined };
	});
	on("ui.panes", () => ({
		value: panes.map((id) => ({
			id,
			title: id,
			isShown: !hidden.has(id),
			isFocused: false,
			isPlaced: true,
		})),
	}));
	on("ui.render", { component: "AbovePrompt" }, ($$, e) => {
		const { Text } = $$.ui.resolve(e);
		return <Text>below</Text>;
	});
	const writes: string[] = [];
	on("state.set", (_, e, next) => {
		writes.push(e.key);
		return next(e);
	});
	await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });

	const shows = async (text: RegExp) => {
		const ui = await $.ui.mount({
			plugin: "summary",
			surface: "terminal",
			...PANE,
		});
		const found = await ui.find({ text });
		await ui.unmount();
		return found !== undefined;
	};
	return { ai, clock, fail, git, hidden, live, panes, shows, writes };
};

test("tracks status, name, model and elapsed time per agent", async ($, on) => {
	const { clock, live, shows } = await setup($, on);
	await $.agent.spawn(spawn("PR 리뷰", "reviewer"));
	await $.agent.spawn(spawn("오타 검사", "typo-checker", { name: "typo" }));
	// the engine's own call site carries agentId; the kit's $.tool.call types leave it out
	await $.tool.call({ tool: "Read", file_path: "/x", agentId: "a1" } as never);
	await clock.advance(42_000);
	live.a2 = "completed";
	await clock.advance(23_000);

	for (const surface of ["terminal", "desktop"] as const) {
		const ui = await $.ui.mount({ plugin: "summary", surface, ...PANE });
		expect(
			await ui.find({ text: /^agents {2}● 1 running {2}✓ 1 done$/ }),
		).toBeDefined();
		expect(
			await ui.find({
				text: new RegExp(`${SPIN} reviewer sonnet-5-5 +1m05s PR 리뷰 · Read`),
			}),
		).toBeDefined();
		expect(
			await ui.find({ text: /✓ typo +haiku-5-5 +43s 오타 검사/ }),
		).toBeDefined();
		const part = async (text: RegExp) =>
			(await ui.find({ type: "Text", text }))?.props;
		expect(await part(/^sonnet-5-5 *$/)).toMatchObject({
			color: "#89b4fa",
			dimColor: false,
		});
		expect(await part(/^haiku-5-5 *$/)).toMatchObject({
			color: "#94e2d5",
			dimColor: true,
		});
		expect(await part(/^reviewer *$/)).toMatchObject({ dimColor: false });
		expect(await part(/^typo *$/)).toMatchObject({ dimColor: true });
		await ui.unmount();
	}

	await $.prompt.submit({
		text: "done",
		wait: false,
		origin: { kind: "task-notification" },
	});
	expect(await shows(/typo/)).toBe(true);

	await $.prompt.submit({
		text: "next",
		wait: false,
		origin: { kind: "composer" },
	});
	expect(await shows(/typo/)).toBe(false);
	expect(await shows(/reviewer/)).toBe(true);
});

test("a workflow agent the engine never lists runs until its turn completes", async ($, on) => {
	const { clock, shows } = await setup($, on);
	await $.agent.spawn(
		spawn("워크플로", "general-purpose", {
			workflow: { runId: "wf_1", agentIndex: 1 },
		}),
	);
	await clock.advance(5_000);
	expect(
		await shows(new RegExp(`${SPIN} general-purpose +haiku-5-5 +5s 워크플로`)),
	).toBe(true);

	await $.turn.complete({
		answer: "ok",
		durationMs: 5_000,
		isAborted: false,
		turnId: "t1",
		agentId: "a1",
		reason: "answer",
	});
	await clock.advance(3_000);
	expect(await shows(/✓ general-purpose +haiku-5-5 +5s 워크플로/)).toBe(true);
});

test("idle teammates, untracked and repeated tool calls write no state", async ($, on) => {
	const { clock, live, shows, writes } = await setup($, on);
	await $.agent.spawn(spawn("취약점 검사", "vulnerability-package-checker"));
	await clock.advance(2_000);
	live.a1 = "idle";
	await clock.advance(1_000);
	expect(await shows(/○ vulnerability-packa… haiku-5-5 +3s 취약점 검사/)).toBe(
		true,
	);

	const before = writes.length;
	await clock.advance(5_000);
	await $.tool.call({ tool: "Read", file_path: "/x", agentId: "zz" } as never);
	expect(writes.length).toBe(before);

	live.a1 = "running";
	await $.tool.call({ tool: "Read", file_path: "/x", agentId: "a1" } as never);
	const afterFirst = writes.length;
	await $.tool.call({ tool: "Read", file_path: "/y", agentId: "a1" } as never);
	expect(writes.length).toBe(afterFirst);
});

test("a stopped or vanished teammate keeps the time it worked", async ($, on) => {
	const { clock, live, shows } = await setup($, on);
	await $.agent.spawn(
		spawn("대기 후 종료", "general-purpose", { name: "idler" }),
	);
	await $.agent.spawn(
		spawn("대기 후 사라짐", "general-purpose", { name: "scout" }),
	);
	await $.tool.call({ tool: "Read", file_path: "/x", agentId: "a2" } as never);
	await $.tool.call({ tool: "SubagentHandback", agentId: "a2" } as never);
	expect(
		await shows(
			new RegExp(`${SPIN} scout +haiku-5-5 +0s 대기 후 사라짐 · Read`),
		),
	).toBe(true);

	await clock.advance(2_000);
	live.a1 = "idle";
	live.a2 = "idle";
	await clock.advance(31_000);
	await $.tool.call({ tool: "TaskStop", task_id: "idler" });
	delete live.a1;
	delete live.a2;
	await clock.advance(2_000);
	expect(await shows(/■ idler +haiku-5-5 +3s/)).toBe(true);
	expect(await shows(/✓ scout +haiku-5-5 +3s/)).toBe(true);
	expect(await shows(/^agents {2}✓ 1 done {2}■ 1 killed$/)).toBe(true);
});

test("the band offers the summary toggle only while the pane is closed", async ($, on) => {
	const { panes } = await setup($, on);
	await $.agent.spawn(spawn("PR 리뷰", "reviewer"));
	const ui = await $.ui.mount({
		plugin: "summary",
		surface: "terminal",
		...BAND,
	});
	expect((await ui.find({ key: "toggle" }))?.props).toMatchObject({
		action: "app:toggleDiffPreSession",
	});
	expect(await ui.find({ text: /^below$/ })).toBeDefined();
	expect(await ui.find({ text: /reviewer/ })).toBeUndefined();

	await ui.press({ key: "toggle" });
	expect(panes).toEqual(["summary"]);
	expect(await ui.find({ key: "toggle" })).toBeUndefined();
	expect(await ui.find({ text: /^below$/ })).toBeDefined();

	await $.command.run({ command: "summary", args: "" } as never);
	expect(panes).toEqual([]);
	expect(await ui.find({ key: "toggle" })).toBeDefined();
	await ui.unmount();
});

test("a pane hidden behind another tab is brought back instead of closed", async ($, on) => {
	const { clock, hidden, panes } = await setup($, on);
	const run = () => $.command.run({ command: "summary", args: "" } as never);
	await run();
	const ui = await $.ui.mount({
		plugin: "summary",
		surface: "terminal",
		...BAND,
	});
	expect(await ui.find({ key: "toggle" })).toBeUndefined();

	hidden.add("summary");
	await clock.advance(100);
	expect(await ui.find({ key: "toggle" })).toBeDefined();

	expect((await run()).text).toMatch(/opened/);
	expect(panes).toEqual(["summary"]);
	expect(hidden.size).toBe(0);
	expect(await ui.find({ key: "toggle" })).toBeUndefined();
	await ui.unmount();
});

test("a forked skill the engine runs with no agent.spawn shows once it steps", async ($, on) => {
	const { clock, live, shows } = await setup($, on);
	live.f1 = "running";
	for await (const _ of $.turn.step({
		turnId: "t1",
		index: 0,
		model: "claude-opus-5-5",
		messageCount: 1,
		agentId: "f1",
	})) {
	}
	expect(await shows(new RegExp(`${SPIN} fork +opus-5-5`))).toBe(true);

	live.f1 = "completed";
	await clock.advance(2_000);
	expect(await shows(/✓ fork +opus-5-5 +1s/)).toBe(true);
});

test("the pane lists skill runs with the model each ran on", async ($, on) => {
	const { shows } = await setup($, on);
	const type = (text: string) =>
		$.prompt.submit({ text, wait: false, origin: { kind: "composer" } });
	const step = async (turnId: string) => {
		for await (const _ of $.turn.step({
			turnId,
			index: 0,
			model: "claude-sonnet-5-5",
			effort: "low",
			messageCount: 1,
		})) {
		}
	};
	await type("/jira list");
	await step("t1");
	await $.turn.complete(finish("t1", ""));
	await type("/commit");
	await step("t2");
	expect(await shows(new RegExp(`^${SPIN} commit sonnet-5-5 · low 0s$`))).toBe(
		true,
	);
	expect(await shows(/^✓ jira sonnet-5-5 · low 0s$/)).toBe(true);
	expect(await shows(/^sonnet-5-5 · low$/)).toBe(true);
});

test("the shimmer sweeps a full cycle without breaking the pane", async ($, on) => {
	const { clock, shows } = await setup($, on);
	await $.agent.spawn(spawn("PR 리뷰", "reviewer"));
	for (let i = 0; i < 110; i++) {
		await clock.advance(100);
		expect(await shows(/^━+$/)).toBe(true);
	}
});

const finish = (
	turnId: string,
	answer: string,
	reason: "answer" | "aborted" = "answer",
) =>
	({
		answer,
		durationMs: 12_000,
		isAborted: reason === "aborted",
		turnId,
		reason,
		usage: {
			input_tokens: 50_000,
			output_tokens: 8_000,
			cache_creation_input_tokens: 0,
			cache_read_input_tokens: 0,
			model: "claude-opus-5-5",
		},
	}) as const;

test("a finished main turn that used tools lands under recent as one summarized line", async ($, on) => {
	const { ai, clock, shows } = await setup($, on);
	await $.prompt.submit({
		text: "최근 커밋 알려줘",
		wait: false,
		origin: { kind: "composer" },
	});
	await $.tool.call({ tool: "Read", file_path: "/x" });
	await $.turn.complete(finish("m1", "커밋했습니다: `0a6d2da`\n\n세부 내용"));
	expect(
		await shows(new RegExp(`^${SPIN} 0s ago +12s +58k summarizing…$`)),
	).toBe(true);

	await clock.advance(1_500);
	expect(await shows(/^✓ \d+s ago +12s +58k summary pane 커밋$/)).toBe(true);
	expect(ai.prompt).toContain("최근 커밋 알려줘");
	expect(ai.prompt).toContain("커밋했습니다");
});

test("a reply with no tool use or an interrupted turn adds nothing to recent", async ($, on) => {
	const { clock, shows } = await setup($, on);
	await $.turn.complete(finish("m1", "네, 맞습니다."));
	await $.tool.call({ tool: "Read", file_path: "/x" });
	await $.turn.complete(finish("m2", "", "aborted"));
	await clock.advance(1_500);
	expect(await shows(/^no finished work yet$/)).toBe(true);
});

test("a summary the model cannot give falls back to the first line of the reply", async ($, on) => {
	const { ai, clock, shows } = await setup($, on);
	ai.text = undefined;
	await $.tool.call({ tool: "Read", file_path: "/x" });
	await $.turn.complete(finish("m1", "## 커밋했습니다: `0a6d2da`\n본문"));
	await clock.advance(1_500);
	expect(await shows(/^✓ \d+s ago +12s +58k 커밋했습니다: 0a6d2da$/)).toBe(
		true,
	);
});

test("files lists what the session edited with its git status", async ($, on) => {
	const { git, shows } = await setup($, on);
	git.status = " M other.ts\n";
	await $.command.run({ command: "summary", args: "" } as never);
	expect(await shows(/^files {2}0 edited · 1 uncommitted$/)).toBe(true);
	const edit = {
		tool: "Edit",
		file_path: "/repo/src/a.ts",
		old_string: "a",
		new_string: "b",
	};
	await $.tool.call(edit as never);
	await $.tool.call(edit as never);
	await $.tool.call({
		tool: "Write",
		file_path: "/repo/b.ts",
		content: "",
	} as never);
	await $.tool.call({ tool: "Read", file_path: "/repo/c.ts" });
	git.status = " M src/a.ts\n?? b.ts\n M other.ts\n";
	await $.turn.complete(finish("m1", "done"));
	expect(await shows(/^files {2}2 edited · 3 uncommitted$/)).toBe(true);
	expect(await shows(/^\?\? +1× b\.ts$/)).toBe(true);
	expect(await shows(/^M +2× src\/a\.ts$/)).toBe(true);
	expect(await shows(/c\.ts/)).toBe(false);
});

test("files a shell or a finished subagent changed join without an edit count", async ($, on) => {
	const { git, shows } = await setup($, on);
	git.status = " M other.ts\n";
	await $.command.run({ command: "summary", args: "" } as never);
	await $.tool.call({ tool: "Bash", command: "sed -i s/a/b/ sh.ts" } as never);
	git.status = " M other.ts\n M sh.ts\n";
	await $.turn.complete(finish("m1", "done"));
	expect(await shows(/^files {2}1 edited · 2 uncommitted$/)).toBe(true);
	expect(await shows(/^M +· sh\.ts$/)).toBe(true);
	expect(await shows(/other\.ts/)).toBe(false);

	git.status += "?? bg.ts\n";
	await $.turn.complete({
		answer: "ok",
		durationMs: 1_000,
		isAborted: false,
		turnId: "t2",
		agentId: "a9",
		reason: "answer",
	});
	expect(await shows(/^\?\? +· bg\.ts$/)).toBe(true);
});

test("the pane keeps live agents and only the latest finished ones", async ($, on) => {
	const { clock, live, shows } = await setup($, on);
	for (let i = 1; i <= 8; i++) {
		await $.agent.spawn(spawn(`작업${i}`, "general-purpose"));
	}
	for (let i = 1; i <= 7; i++) {
		live[`a${i}`] = "completed";
	}
	await clock.advance(1_000);
	expect(await shows(/^agents {2}● 1 running {2}✓ 7 done$/)).toBe(true);
	expect(await shows(/작업8/)).toBe(true);
	expect(await shows(/작업3/)).toBe(true);
	expect(await shows(/작업2/)).toBe(false);
	expect(await shows(/^\+2 more$/)).toBe(true);
});

test("alerts collect denied and failed tool calls until the next prompt", async ($, on) => {
	const { fail, shows } = await setup($, on);
	await $.agent.spawn(spawn("오타 검사", "typo-checker", { name: "typo" }));
	fail.Bash = { deny: "standalone sleep is blocked" };
	await $.tool.call({ tool: "Bash", command: "sleep 25" } as never);
	fail.Grep = {
		isError: true,
		result: null,
		text: "Exit code 2\nrg: bad regex",
	};
	await $.tool.call({ tool: "Grep", pattern: "(", agentId: "a1" } as never);
	expect(await shows(/^alerts$/)).toBe(true);
	expect(await shows(/^✗ \d+s ago +Bash {2}standalone sleep is blocked$/)).toBe(
		true,
	);
	expect(await shows(/^✗ \d+s ago +Grep @typo {2}Exit code 2$/)).toBe(true);

	await $.prompt.submit({
		text: "next",
		wait: false,
		origin: { kind: "composer" },
	});
	expect(await shows(/^alerts$/)).toBe(false);
});

test("the header icon pulses only while something runs", async ($, on) => {
	const { shows } = await setup($, on);
	expect(await shows(/^◆ summary$/)).toBe(true);
	await $.agent.spawn(spawn("PR 리뷰", "reviewer"));
	expect(await shows(/^[◇◈◆] summary$/)).toBe(true);
});

test("/summary opens and closes the pane without a keybinding", async ($, on) => {
	const { panes } = await setup($, on);
	const ui = await $.ui.mount({
		plugin: "summary",
		surface: "terminal",
		...BAND,
	});
	expect(await ui.find({ text: /^ \/summary $/ })).toBeDefined();
	await ui.unmount();
	expect(
		(await $.command.run({ command: "summary", args: "" } as never)).text,
	).toBe("summary pane opened (/summary to close)");
	expect(panes).toEqual(["summary"]);
	expect(
		(await $.command.run({ command: "summary", args: "" } as never)).text,
	).toMatch(/closed/);
	expect(panes).toEqual([]);
});

test("the toggle hint names the chord bound to the toggle action", async ($, on) => {
	on("env.get", () => ({ value: "/home/me" }));
	on("fs.read", (_, e) => ({
		value:
			e.path === "/home/me/.claude/keybindings.json"
				? JSON.stringify({
						bindings: [
							{
								context: "Global",
								bindings: { "ctrl+x s": "app:toggleDiffPreSession" },
							},
						],
					})
				: "",
	}));
	await setup($, on);
	const ui = await $.ui.mount({
		plugin: "summary",
		surface: "terminal",
		...BAND,
	});
	expect(await ui.find({ text: /^ ctrl\+x s $/ })).toBeDefined();
	await ui.unmount();
	expect(
		(await $.command.run({ command: "summary", args: "" } as never)).text,
	).toBe("summary pane opened (ctrl+x s to close)");
});
