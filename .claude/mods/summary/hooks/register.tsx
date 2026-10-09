import type {
	AgentStatus,
	EngineInterface,
	Register,
	TurnCompleteReason,
} from "claude-code";
import { atom, read, update } from "claude-code";

import type { AgentRow, Alert, FileTouch, SkillRun, WorkItem } from "../types";

const agents = atom({ plugin: "summary", key: "agents" } as const, []);
const now = atom({ plugin: "summary", key: "now" } as const, 0);
const recent = atom({ plugin: "summary", key: "recent" } as const, []);
const files = atom({ plugin: "summary", key: "files" } as const, []);
const dirty = atom({ plugin: "summary", key: "dirty" } as const, 0);
const alerts = atom({ plugin: "summary", key: "alerts" } as const, []);
const skillRuns = atom({ plugin: "summary", key: "runs" } as const, []);
const mainModel = atom({ plugin: "summary", key: "model" } as const, "");
const paneOpen = atom({ plugin: "summary", key: "open" } as const, false);
const chord = atom({ plugin: "summary", key: "chord" } as const, "");
const seen = atom({ plugin: "summary", key: "seen" } as const, []);

const PANE = "summary";
const TOGGLE_ACTION = "app:toggleDiffPreSession";
const RECENT_MAX = 5;
const RUNS_MAX = 8;
const FILES_MAX = 20;
const FILES_SHOWN = 6;
const AGENTS_ENDED_SHOWN = 5;
const ALERTS_MAX = 4;
const EDIT_TOOLS = new Set(["Edit", "MultiEdit", "Write", "NotebookEdit"]);
const SUMMARY =
	"You write one-line entries for a log of finished work. Given what the user asked and the " +
	"coding assistant's final reply, say what the assistant did in at most 40 characters, in the " +
	"language of the reply, as a terse phrase. Describe the action taken, not the content it " +
	"reported. No quotes, no markdown, no trailing period.";

const C = {
	text: "#cdd6f4",
	subtext: "#a6adc8",
	overlay: "#7f849c",
	surface2: "#585b70",
	surface1: "#45475a",
	surface0: "#313244",
	mauve: "#cba6f7",
	pink: "#f5c2e7",
	lavender: "#b4befe",
	blue: "#89b4fa",
	sky: "#89dceb",
	teal: "#94e2d5",
	green: "#a6e3a1",
	yellow: "#f9e2af",
	peach: "#fab387",
	red: "#f38ba8",
};

const SPINNER = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏";
const PULSE = "◇◈◆◈";
const GLOW = [
	C.mauve,
	C.pink,
	C.lavender,
	C.blue,
	C.sky,
	C.blue,
	C.lavender,
	C.pink,
];

const ICON: Record<AgentRow["status"], string> = {
	running: "●",
	idle: "○",
	done: "✓",
	failed: "✗",
	killed: "■",
};
const COLOR: Record<AgentRow["status"], string> = {
	running: C.yellow,
	idle: C.overlay,
	done: C.green,
	failed: C.red,
	killed: C.red,
};
const GIT_COLOR: Record<string, string> = {
	M: C.yellow,
	A: C.green,
	D: C.red,
	R: C.blue,
	"??": C.teal,
};
const RUN: Record<
	NonNullable<SkillRun["result"]>,
	{ icon: string; color: string }
> = {
	done: { icon: "✓", color: C.green },
	failed: { icon: "✗", color: C.red },
	aborted: { icon: "■", color: C.overlay },
};

const STATUS: Record<AgentStatus, AgentRow["status"]> = {
	pending: "running",
	running: "running",
	waiting: "running",
	idle: "idle",
	completed: "done",
	failed: "failed",
	killed: "killed",
};
const TURN_END: Record<TurnCompleteReason, AgentRow["status"]> = {
	answer: "done",
	aborted: "killed",
	refusal: "failed",
	error: "failed",
};

const RUN_END: Record<TurnCompleteReason, SkillRun["result"]> = {
	answer: "done",
	aborted: "aborted",
	refusal: "failed",
	error: "failed",
};

const ORDER: AgentRow["status"][] = [
	"running",
	"idle",
	"done",
	"failed",
	"killed",
];

const modelColor = (model: string) =>
	model.startsWith("opus")
		? C.peach
		: model.startsWith("haiku")
			? C.teal
			: C.blue;

const LABEL_MAX = 20;

const elapsed = (ms: number) => {
	const s = Math.max(0, Math.round(ms / 1000));
	return s < 60
		? `${s}s`
		: `${Math.floor(s / 60)}m${String(s % 60).padStart(2, "0")}s`;
};

const clip = (s: string) =>
	s.length > LABEL_MAX ? `${s.slice(0, LABEL_MAX - 1)}…` : s;

const isLive = (a: AgentRow) => a.status === "running" || a.status === "idle";

const end = (a: AgentRow, t: number) =>
	a.status === "running" ? t : (a.endedAt ?? t);

const sync = (
	a: AgentRow,
	live: AgentRow["status"] | undefined,
	t: number,
): AgentRow => {
	if (
		!isLive(a) ||
		(live === undefined && !a.listed) ||
		(live === a.status && a.listed)
	) {
		return a;
	}
	const status = live ?? "done";
	return {
		...a,
		listed: true,
		status,
		...(status === "running" ? {} : { endedAt: end(a, t) }),
	};
};

const patch = async (
	$: EngineInterface,
	id: string,
	fn: (a: AgentRow) => AgentRow | undefined,
) => {
	if ((await read($, agents)).some((a) => a.id === id && fn(a) !== undefined)) {
		await update($, agents, (list) =>
			list.map((a) => (a.id === id ? (fn(a) ?? a) : a)),
		);
	}
};

const cut = (s: string, n: number) =>
	s.length > n ? `${s.slice(0, n - 1)}…` : s;

const firstLine = (answer: string) =>
	cut(
		answer
			.split("\n")
			.map((l) =>
				l
					.replace(/^[#>*\-\s]+/, "")
					.replace(/[*`]/g, "")
					.trim(),
			)
			.find((l) => l !== "") ?? "done",
		60,
	);

const ago = (ms: number) => {
	const s = Math.max(0, Math.round(ms / 1000));
	return s < 60
		? `${s}s`
		: s < 3600
			? `${Math.floor(s / 60)}m`
			: `${Math.floor(s / 3600)}h`;
};

const summarize = async ($: EngineInterface, ask: string, answer: string) => {
	try {
		const done = await $.model.complete({
			model: "haiku",
			system: SUMMARY,
			prompt: `User asked:\n${ask}\n\nAssistant replied:\n${answer}`,
			maxTokens: 60,
			timeoutMs: 20_000,
		});
		const line = done.isAnswered ? done.text.split("\n")[0]?.trim() : undefined;
		return line ? cut(line, 60) : firstLine(answer);
	} catch {
		return firstLine(answer);
	}
};

const kilo = (n: number) => (n < 1000 ? `${n}` : `${Math.round(n / 1000)}k`);

const tail = (s: string, n: number) =>
	s.length > n ? `…${s.slice(s.length - n + 1)}` : s;

const pathOf = (e: object) => {
	const { file_path, notebook_path } = e as {
		file_path?: unknown;
		notebook_path?: unknown;
	};
	const path = file_path ?? notebook_path;
	return typeof path === "string" ? path : undefined;
};

const refreshGit = async (
	$: EngineInterface,
	root: string | undefined,
	adopt: boolean,
) => {
	if (root === undefined) {
		return;
	}
	const run = await $.process
		.run(
			["git", "-C", root, "status", "--porcelain=v1", "--untracked-files=all"],
			{
				timeoutMs: 5_000,
			},
		)
		.catch(() => undefined);
	if (run === undefined || run.exitCode !== 0) {
		return;
	}
	const status = new Map(
		run.stdout
			.split("\n")
			.filter((l) => l.length > 3)
			.map(
				(l) =>
					[
						l.slice(3).split(" -> ").at(-1) ?? "",
						l.slice(0, 2).trim(),
					] as const,
			),
	);
	if ((await read($, dirty)) !== status.size) {
		await update($, dirty, () => status.size);
	}
	const before = await read($, seen);
	const paths = [...status.keys()];
	if (JSON.stringify(paths) !== JSON.stringify(before)) {
		await update($, seen, () => paths);
	}
	const list = await read($, files);
	const known = new Set([...before, ...list.map((f) => f.path)]);
	const fresh = adopt
		? paths.filter((p) => !known.has(p) && !known.has(`${root}/${p}`))
		: [];
	const added: FileTouch[] = fresh.map((p) => ({
		path: `${root}/${p}`,
		edits: 0,
	}));
	const next = [...added, ...list]
		.slice(0, FILES_MAX)
		.map(({ status: _, ...f }) => {
			const s = f.path.startsWith(`${root}/`)
				? status.get(f.path.slice(root.length + 1))
				: undefined;
			return s === undefined ? f : { ...f, status: s };
		});
	if (JSON.stringify(next) !== JSON.stringify(list)) {
		await update($, files, () => next);
	}
};

const record = async (
	$: EngineInterface,
	tool: string,
	agentId: string | undefined,
	path: string | undefined,
	ran: { deny?: string; isError?: true; text?: string },
) => {
	const failed = ran.deny !== undefined || ran.isError === true;
	if (!failed && EDIT_TOOLS.has(tool) && path !== undefined) {
		const stat = await $.fs
			.stat(path, { resolve: true })
			.catch(() => undefined);
		const real = stat?.realPath ?? path;
		await update($, files, (list) => {
			const hit = list.find((f) => f.path === real);
			return [
				{ ...hit, path: real, edits: (hit?.edits ?? 0) + 1 },
				...list.filter((f) => f.path !== real),
			].slice(0, FILES_MAX);
		});
	}
	if (failed && tool !== "SubagentHandback") {
		const agent =
			agentId === undefined
				? undefined
				: (await read($, agents)).find((a) => a.id === agentId)?.label;
		const alert: Alert = {
			at: await $.clock.now(),
			tool,
			reason: cut(
				firstLine((ran.deny ?? ran.text ?? "").trim() || "error"),
				120,
			),
			...(agent === undefined ? {} : { agent }),
		};
		await update($, alerts, (list) => [alert, ...list].slice(0, ALERTS_MAX));
	}
};

const short = (model: string) => model.replace(/^.*claude-/, "");

const discover = async ($: EngineInterface, id: string, model: string) => {
	if ((await read($, agents)).some((a) => a.id === id)) {
		return;
	}
	const info = (await $.agent.list()).find((a) => a.id === id);
	if (info === undefined) {
		return;
	}
	const row: AgentRow = {
		id,
		label: clip(info.name ?? info.type),
		model: short(model),
		description: info.description,
		startedAt: await $.clock.now(),
		status: "running",
		listed: true,
		...(info.name === undefined ? {} : { name: info.name }),
	};
	await update($, agents, (list) =>
		list.some((a) => a.id === id) ? list : [...list, row],
	);
	await update($, now, () => row.startedAt);
};

const isOpenRun = (r: SkillRun | undefined) =>
	r !== undefined && r.result === undefined;

const patchOpen = async ($: EngineInterface, fn: (r: SkillRun) => SkillRun) => {
	const last = (await read($, skillRuns)).at(-1);
	if (
		last !== undefined &&
		isOpenRun(last) &&
		JSON.stringify(fn(last)) !== JSON.stringify(last)
	) {
		await update($, skillRuns, (l) => [...l.slice(0, -1), fn(last)]);
	}
};

const openRun = async (
	$: EngineInterface,
	skills: string[],
	model: string,
	effort?: string,
) => {
	if (isOpenRun((await read($, skillRuns)).at(-1))) {
		await patchOpen($, (r) => ({ ...r, skills }));
		return;
	}
	const run: SkillRun = {
		skills,
		model,
		...(effort === undefined ? {} : { effort }),
		startedAt: await $.clock.now(),
	};
	await update($, skillRuns, (l) => [...l, run].slice(-RUNS_MAX));
};

const isPaneOpen = async ($: EngineInterface) =>
	(await $.ui.panes()).some((p) => p.id === PANE);

const setOpen = async ($: EngineInterface, isOpen: boolean) => {
	if ((await read($, paneOpen)) !== isOpen) {
		await update($, paneOpen, () => isOpen);
	}
};

const syncChord = async ($: EngineInterface) => {
	const key = (await boundKey($)) ?? "";
	if ((await read($, chord)) !== key) {
		await update($, chord, () => key);
	}
	return key;
};

const toggle = async ($: EngineInterface, root: string | undefined) => {
	if (await isPaneOpen($)) {
		await $.ui.close({ id: PANE });
		await setOpen($, false);
		return false;
	}
	await $.ui.open({ id: PANE, title: "summary", columns: 60 });
	await setOpen($, true);
	await syncChord($);
	await refreshGit($, root, false);
	return true;
};

const hintOf = (key: string) => key || `/${PANE}`;

const boundKey = async ($: EngineInterface) => {
	try {
		const { bindings = [] } = JSON.parse(
			await $.fs.read(`${await $.env.get("HOME")}/.claude/keybindings.json`),
		) as {
			bindings?: { context?: string; bindings?: Record<string, unknown> }[];
		};
		return bindings
			.filter((b) => b.context === "Global")
			.flatMap((b) => Object.entries(b.bindings ?? {}))
			.find(([, action]) => action === TOGGLE_ACTION)?.[0];
	} catch {
		return undefined;
	}
};

const isBusy = (list: AgentRow[], runs: SkillRun[], work: WorkItem[]) =>
	list.some((a) => a.status === "running") ||
	(runs.length > 0 && runs.at(-1)?.result === undefined) ||
	work.some((w) => w.text === undefined);

export const register: Register = (on) => {
	let loaded: string[] = [];
	let worked = false;
	let ask = "";
	let draining = false;
	let tick = 0;
	let root: string | undefined;

	on("session.start", async ($, e, next) => {
		const key = await syncChord($);
		const top = await $.process
			.run(["git", "rev-parse", "--show-toplevel"], { timeoutMs: 5_000 })
			.catch(() => undefined);
		root = top?.exitCode === 0 ? top.stdout.trim() : undefined;
		await refreshGit($, root, false);
		await setOpen($, await isPaneOpen($));
		$.clock.every(100, async () => {
			if (!(await read($, paneOpen))) {
				return;
			}
			tick++;
			const busy = isBusy(
				await read($, agents),
				await read($, skillRuns),
				await read($, recent),
			);
			if (busy || tick % 100 === 0) {
				$.ui.invalidate("ui.render");
			}
		});
		$.clock.every(1500, async () => {
			const item = (await read($, recent)).find((w) => w.text === undefined);
			if (draining || item === undefined) {
				return;
			}
			draining = true;
			try {
				const text = await summarize($, item.ask ?? "", item.answer ?? "");
				await update($, recent, (list) =>
					list.map(({ ask: _ask, answer: _answer, ...w }) =>
						w.id === item.id ? { ...w, text } : w,
					),
				);
			} finally {
				draining = false;
			}
		});
		$.clock.every(1000, async () => {
			const rows = await read($, agents);
			if (!rows.some(isLive)) {
				return;
			}
			const t = await $.clock.now();
			const live = new Map(
				(await $.agent.list()).map((a) => [a.id, STATUS[a.status]]),
			);
			if (rows.some((a) => sync(a, live.get(a.id), t) !== a)) {
				await update($, agents, (list) =>
					list.map((a) => sync(a, live.get(a.id), t)),
				);
			}
			if ((await read($, agents)).some((a) => a.status === "running")) {
				await update($, now, () => t);
			}
		});

		await $.command.register({
			name: PANE,
			description: `Open or close the summary pane${key === "" ? "" : ` (${key})`}`,
			immediate: true,
		});

		return next(e);
	});

	on("agent.spawn", async ($, e, next) => {
		const ran = await next(e);
		if (ran.agentId === undefined) {
			return ran;
		}
		const row: AgentRow = {
			id: ran.agentId,
			label: clip(e.name ?? e.subagentType),
			model: short(ran.model),
			description: e.description,
			startedAt: await $.clock.now(),
			status: "running",
			...(e.name === undefined ? {} : { name: e.name }),
		};
		await update($, agents, (list) => [
			...list.filter((a) => a.id !== row.id),
			row,
		]);
		await update($, now, () => row.startedAt);

		return ran;
	}).catch((_, e, next) => next(e));

	on("turn.step", async function* ($, e, next) {
		if (e.agentId !== undefined) {
			await discover($, e.agentId, e.model);
			return yield* next(e);
		}
		const effort = e.effort === undefined ? undefined : String(e.effort);
		if (loaded.length > 0) {
			await openRun($, [...loaded], short(e.model), effort);
		}
		const step = yield* next(e);
		const answered = short(step.usage?.model ?? e.model);
		if (loaded.length > 0) {
			await patchOpen($, (r) => ({ ...r, model: answered }));
		}
		const tag = [answered, effort].filter((v) => v !== undefined).join(" · ");
		if ((await read($, mainModel)) !== tag) {
			await update($, mainModel, () => tag);
		}

		return step;
	});

	on("tool.call", { tool: "Skill" }, async (_, e, next) => {
		const ran = await next(e);
		if (
			e.agentId === undefined &&
			ran.deny === undefined &&
			ran.isError !== true
		) {
			loaded = [...new Set([...loaded, e.skill])];
		}

		return ran;
	}).catch((_, e, next) => next(e));

	on("tool.call", async ($, e, next) => {
		const tool = String(e.tool);
		const id = e.agentId;
		worked ||= id === undefined;
		const [, ran] = await Promise.all([
			id === undefined || tool === "SubagentHandback"
				? undefined
				: patch($, id, (a) =>
						a.status === "running" && a.tool === tool
							? undefined
							: { ...a, status: "running", tool },
					),
			next(e),
		]);
		await record($, tool, id, pathOf(e), ran);

		return ran;
	}).catch((_, e, next) => next(e));

	on("tool.call", { tool: "TaskStop" }, async ($, e, next) => {
		const ran = await next(e);
		const task = e.task_id ?? e.shell_id;
		if (ran.deny !== undefined || ran.isError === true || task === undefined) {
			return ran;
		}
		const t = await $.clock.now();
		const hit = (a: AgentRow) =>
			a.status !== "killed" && (a.id === task || a.name === task);
		if ((await read($, agents)).some(hit)) {
			await update($, agents, (list) =>
				list.map((a) =>
					hit(a) ? { ...a, status: "killed", endedAt: end(a, t) } : a,
				),
			);
		}

		return ran;
	}).catch((_, e, next) => next(e));

	on("turn.complete", async ($, e, next) => {
		const id = e.agentId;
		if (id !== undefined && !(await $.agent.list()).some((a) => a.id === id)) {
			const endedAt = await $.clock.now();
			await patch($, id, (a) =>
				isLive(a) && !a.listed
					? { ...a, status: TURN_END[e.reason], endedAt }
					: undefined,
			);
		}
		if (id !== undefined) {
			await refreshGit($, root, true);
		}
		if (id === undefined) {
			if (loaded.length > 0) {
				const endedAt = await $.clock.now();
				await patchOpen($, (r) => ({
					...r,
					endedAt,
					result: RUN_END[e.reason],
				}));
				loaded = [];
			}
			if (worked && e.reason === "answer" && e.answer.trim() !== "") {
				const item: WorkItem = {
					id: e.turnId,
					at: await $.clock.now(),
					durationMs: e.durationMs,
					...(e.usage === undefined
						? {}
						: {
								tokens:
									e.usage.input_tokens +
									e.usage.output_tokens +
									e.usage.cache_read_input_tokens +
									e.usage.cache_creation_input_tokens,
							}),
					ask,
					answer: e.answer.slice(0, 4000),
				};
				await update($, recent, (list) =>
					[item, ...list.filter((w) => w.id !== item.id)].slice(0, RECENT_MAX),
				);
			}
			if (worked) {
				await refreshGit($, root, true);
			}
			worked = false;
		}

		return next(e);
	});

	on("prompt.submit", async ($, e, next) => {
		if (e.turnId === undefined) {
			ask = e.text.slice(0, 1000);
			const name = /^\/([\w:.-]+)(?=\s|$)/.exec(e.text)?.[1];
			const isCommand =
				name !== undefined &&
				(await $.command.list()).some((c) => c.name === name);
			loaded = isCommand ? [name] : [];
		}
		if (e.origin.kind === "composer" || e.origin.kind === "bridge") {
			await update($, agents, (list) => list.filter(isLive));
			if ((await read($, alerts)).length > 0) {
				await update($, alerts, () => []);
			}
		}

		return next(e);
	}).catch((_, e, next) => next(e));

	on("command.run", { command: PANE }, async ($) => ({
		text: (await toggle($, root))
			? `summary pane opened (${hintOf(await read($, chord))} to close)`
			: "summary pane closed",
	})).catch((_, e, next) => next(e));

	on("ui.close", { id: PANE }, async ($, e, next) => {
		const closed = await next(e);
		await setOpen($, false);

		return closed;
	}).catch((_, e, next) => next(e));

	on("ui.render", { component: "AbovePrompt" }, async ($, e, next) => {
		if (e.props.hasSurvey || (await read($, paneOpen))) {
			return next(e);
		}
		const key = await read($, chord);
		const below = await next(e);
		const { Box, Button, Text } = $.ui.resolve(e);

		return (
			<Box flexDirection="column">
				<Button
					plain
					key="toggle"
					action={TOGGLE_ACTION}
					onPress={() => toggle($, root)}
				>
					<Text
						backgroundColor={C.surface0}
						color={C.lavender}
					>{` ${hintOf(key)} `}</Text>
					<Text color={C.overlay}>{key === "" ? "" : " summary"}</Text>
				</Button>
				{below}
			</Box>
		);
	});

	on("ui.render", { component: "Pane", requestId: PANE }, async ($, e) => {
		const { Box, Button, Text } = $.ui.resolve(e);
		const list = await read($, agents);
		const runs = await read($, skillRuns);
		const work = await read($, recent);
		const touched = await read($, files);
		const uncommitted = await read($, dirty);
		const warnings = await read($, alerts);
		const tag = await read($, mainModel);
		const t = await $.clock.now();
		const frame = Math.floor(t / 100);
		const spin = SPINNER[frame % SPINNER.length];
		const busy = isBusy(list, runs, work);
		const glow = busy ? (GLOW[frame % GLOW.length] ?? C.mauve) : C.mauve;
		const width = Math.max(30, e.props.bodyColumns);
		const rule = width - 2;
		const at = busy ? (frame % (rule + 6)) - 3 : -3;
		const lit = [at, at + 3].map((n) => Math.min(rule, Math.max(0, n))) as [
			number,
			number,
		];
		const ended = list.filter((a) => !isLive(a));
		const hidden = new Set(
			ended.slice(0, Math.max(0, ended.length - AGENTS_ENDED_SHOWN)),
		);
		const shown = list.filter((a) => !hidden.has(a));
		const labelWidth = Math.max(0, ...shown.map((a) => a.label.length));
		const modelWidth = Math.max(0, ...shown.map((a) => a.model.length));
		const pathWidth = width - 4 - 3 - 4;
		const shortPath = (p: string) =>
			root !== undefined && p.startsWith(`${root}/`)
				? p.slice(root.length + 1)
				: p;
		const counts = ORDER.map(
			(s) => [s, list.filter((a) => a.status === s).length] as const,
		);
		const keycap = (k: string) => (
			<Text backgroundColor={C.surface0} color={C.lavender}>{` ${k} `}</Text>
		);

		return (
			<Box flexDirection="column" width={width}>
				<Box
					borderStyle="round"
					borderColor={glow}
					paddingX={1}
					justifyContent="space-between"
				>
					<Text bold color={C.mauve}>
						<Text color={glow}>{busy ? PULSE[frame % PULSE.length] : "◆"}</Text>{" "}
						summary
					</Text>
					<Text color={modelColor(tag)}>{tag}</Text>
				</Box>
				<Box paddingX={1}>
					<Text>
						<Text color={C.surface0}>{"━".repeat(lit[0])}</Text>
						<Text color={C.lavender}>{"━".repeat(lit[1] - lit[0])}</Text>
						<Text color={C.surface0}>{"━".repeat(rule - lit[1])}</Text>
					</Text>
				</Box>
				{warnings.length > 0 && (
					<Box
						flexDirection="column"
						borderStyle="round"
						borderColor={C.red}
						paddingX={1}
					>
						<Text bold color={C.red}>
							alerts
						</Text>
						{warnings.map((a) => (
							<Text wrap="truncate-end">
								<Text color={C.red}>✗</Text>{" "}
								<Text color={C.overlay}>
									{`${ago(t - a.at)} ago`.padEnd(7)}
								</Text>{" "}
								<Text color={C.peach}>{a.tool}</Text>
								{a.agent !== undefined && (
									<Text color={C.overlay}>{` @${a.agent}`}</Text>
								)}
								<Text color={C.subtext}>{`  ${a.reason}`}</Text>
							</Text>
						))}
					</Box>
				)}
				<Box
					flexDirection="column"
					borderStyle="round"
					borderColor={C.surface1}
					paddingX={1}
				>
					<Text bold color={C.blue}>
						skills
					</Text>
					{runs.length === 0 ? (
						<Text color={C.overlay}>no skill yet</Text>
					) : (
						[...runs].reverse().map((r) => (
							<Text wrap="truncate-end">
								{r.result === undefined ? (
									<Text color={C.peach}>{spin}</Text>
								) : (
									<Text color={RUN[r.result].color}>{RUN[r.result].icon}</Text>
								)}{" "}
								<Text
									bold={r.result === undefined}
									color={r.result === undefined ? C.text : C.subtext}
								>
									{r.skills.join(", ")}
								</Text>{" "}
								<Text color={modelColor(r.model)}>
									{[r.model, r.effort]
										.filter((v) => v !== undefined)
										.join(" · ")}
								</Text>{" "}
								<Text color={C.overlay}>
									{elapsed((r.endedAt ?? t) - r.startedAt)}
								</Text>
							</Text>
						))
					)}
				</Box>
				<Box
					flexDirection="column"
					borderStyle="round"
					borderColor={C.surface1}
					paddingX={1}
				>
					<Text>
						<Text bold color={C.mauve}>
							agents
						</Text>
						{counts
							.filter(([, n]) => n > 0)
							.map(([s, n]) => (
								<Text color={COLOR[s]}>{`  ${ICON[s]} ${n} ${s}`}</Text>
							))}
					</Text>
					{list.length === 0 && <Text color={C.overlay}>no agent running</Text>}
					{shown.map((a) => (
						<Text wrap="truncate-end">
							<Text color={COLOR[a.status]}>
								{a.status === "running" ? spin : ICON[a.status]}
							</Text>{" "}
							<Text color={C.text} dimColor={a.status !== "running"}>
								{a.label.padEnd(labelWidth)}
							</Text>{" "}
							<Text
								color={modelColor(a.model)}
								dimColor={a.status !== "running"}
							>
								{a.model.padEnd(modelWidth)}
							</Text>{" "}
							<Text color={C.overlay} dimColor={a.status !== "running"}>
								{elapsed(end(a, t) - a.startedAt).padStart(6)}
							</Text>{" "}
							<Text color={C.subtext} dimColor>
								{a.description}
								{a.status === "running" && a.tool !== undefined
									? ` · ${a.tool}`
									: ""}
							</Text>
						</Text>
					))}
					{hidden.size > 0 && (
						<Text color={C.overlay}>{`+${hidden.size} more`}</Text>
					)}
				</Box>
				<Box
					flexDirection="column"
					borderStyle="round"
					borderColor={C.surface1}
					paddingX={1}
				>
					<Text>
						<Text bold color={C.yellow}>
							files
						</Text>
						<Text color={C.overlay}>
							{`  ${touched.length} edited · ${uncommitted} uncommitted`}
						</Text>
					</Text>
					{touched.length === 0 && (
						<Text color={C.overlay}>no file edited yet</Text>
					)}
					{touched.slice(0, FILES_SHOWN).map((f) => (
						<Text>
							<Text
								color={
									f.status === undefined
										? C.overlay
										: (GIT_COLOR[f.status] ?? C.peach)
								}
							>
								{(f.status ?? "·").padEnd(2)}
							</Text>{" "}
							<Text color={C.overlay}>
								{(f.edits > 0 ? `${f.edits}×` : "·").padStart(3)}
							</Text>{" "}
							<Text color={C.text}>{tail(shortPath(f.path), pathWidth)}</Text>
						</Text>
					))}
					{touched.length > FILES_SHOWN && (
						<Text
							color={C.overlay}
						>{`+${touched.length - FILES_SHOWN} more`}</Text>
					)}
				</Box>
				<Box
					flexDirection="column"
					borderStyle="round"
					borderColor={C.surface1}
					paddingX={1}
				>
					<Text bold color={C.green}>
						recent
					</Text>
					{work.length === 0 && (
						<Text color={C.overlay}>no finished work yet</Text>
					)}
					{work.map((w) => (
						<Text wrap="truncate-end">
							{w.text === undefined ? (
								<Text color={C.peach}>{spin}</Text>
							) : (
								<Text color={C.green}>✓</Text>
							)}{" "}
							<Text color={C.overlay}>{`${ago(t - w.at)} ago`.padEnd(7)}</Text>{" "}
							<Text color={C.overlay} dimColor>
								{elapsed(w.durationMs).padStart(5)}
							</Text>{" "}
							<Text color={C.overlay} dimColor>
								{(w.tokens === undefined ? "" : kilo(w.tokens)).padStart(4)}
							</Text>{" "}
							<Text color={w.text === undefined ? C.subtext : C.text}>
								{w.text ?? "summarizing…"}
							</Text>
						</Text>
					))}
				</Box>
				<Box paddingX={1} gap={2}>
					<Button
						plain
						key="toggle"
						action={TOGGLE_ACTION}
						onPress={() => toggle($, root)}
					>
						{keycap(hintOf(await read($, chord)))}
						<Text color={C.subtext}> close</Text>
					</Button>
					<Text>
						{keycap("ctrl+x tab")}
						<Text color={C.subtext}> focus</Text>
					</Text>
				</Box>
			</Box>
		);
	});
};
