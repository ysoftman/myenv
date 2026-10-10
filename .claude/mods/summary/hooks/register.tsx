import type { ClassicHookInputs, EngineInterface, Register } from "claude-code";
import { atom, read, update } from "claude-code";
import type {
	AgentRow,
	Alert,
	BackgroundTask,
	Commit,
	FileTouch,
	RepoState,
	SessionCron,
	SkillRun,
	TurnMark,
	WorkItem,
} from "../types";
import { clip, cut, firstLine, pathOf, short, totalTokens } from "./format";
import { paneView } from "./pane";
import {
	newRain,
	RAIN,
	RAIN_MS,
	RAIN_ROWS,
	rainCells,
	rainMessage,
	rainSpeed,
} from "./rain";
import {
	end,
	isBusy,
	isLive,
	isOpenRun,
	RUN_END,
	STATUS,
	sync,
	TURN_END,
} from "./status";
import { PANE, SHOWN, TOGGLE_ACTION } from "./theme";

const agents = atom({ plugin: "summary", key: "agents" } as const, []);

const now = atom({ plugin: "summary", key: "now" } as const, 0);

const recent = atom({ plugin: "summary", key: "recent" } as const, []);

const files = atom({ plugin: "summary", key: "files" } as const, []);

const dirty = atom({ plugin: "summary", key: "dirty" } as const, 0);

const alerts = atom({ plugin: "summary", key: "alerts" } as const, []);

const skillRuns = atom({ plugin: "summary", key: "runs" } as const, []);

const mainModel = atom({ plugin: "summary", key: "model" } as const, "");

const paneShown = atom({ plugin: "summary", key: "shown" } as const, false);

const chord = atom({ plugin: "summary", key: "chord" } as const, "");

const seen = atom({ plugin: "summary", key: "seen" } as const, []);

// when the main turn in progress began; 0 while Claude is idle
const working = atom({ plugin: "summary", key: "working" } as const, 0);

// background work and session crons as the last stop reported them
const tasks = atom({ plugin: "summary", key: "tasks" } as const, []);

const crons = atom({ plugin: "summary", key: "crons" } as const, []);

const turns = atom({ plugin: "summary", key: "turns" } as const, []);

const repo = atom({ plugin: "summary", key: "repo" } as const, {
	ahead: 0,
	behind: 0,
	commits: [],
});

const FILES_MAX = 20;

const TURNS_MAX = 200;

const EDIT_TOOLS = new Set(["Edit", "MultiEdit", "Write", "NotebookEdit"]);

const SUMMARY =
	"You write one-line entries for a log of finished work. Given what the user asked and the " +
	"coding assistant's final reply, say what the assistant did in at most 40 characters, in the " +
	"language of the reply, as a terse phrase. Describe the action taken, not the content it " +
	"reported. No quotes, no markdown, no trailing period.";

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

// "## main...origin/main [ahead 1, behind 2]", the head line of `status -b`,
// and the last commits: the first `ahead` of them are not pushed yet.
const refreshRepo = async ($: EngineInterface, root: string, head: string) => {
	const m =
		/^## (?:No commits yet on )?(.+?)(?:\.\.\.(\S+))?(?: \[(.*)\])?$/.exec(
			head,
		);
	const count = (word: string) =>
		Number(new RegExp(`${word} (\\d+)`).exec(m?.[3] ?? "")?.[1] ?? 0);
	const log = await $.process
		.run(
			[
				"git",
				"-C",
				root,
				"log",
				"-n",
				String(SHOWN),
				"--format=%h%x09%ct%x09%s",
			],
			{
				timeoutMs: 5_000,
			},
		)
		.catch(() => undefined);
	const commits: Commit[] =
		log?.exitCode === 0
			? log.stdout
					.split("\n")
					.map((l) => l.split("\t"))
					.filter((f) => f.length >= 3)
					.map(([hash = "", at = "0", ...subject]) => ({
						hash,
						at: Number(at) * 1000,
						subject: subject.join("\t"),
					}))
			: [];
	const next: RepoState = {
		...(m?.[1] === undefined ? {} : { branch: m[1] }),
		...(m?.[2] === undefined ? {} : { upstream: m[2] }),
		ahead: count("ahead"),
		behind: count("behind"),
		commits,
	};
	if (JSON.stringify(next) !== JSON.stringify(await read($, repo))) {
		await update($, repo, () => next);
	}
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
			[
				"git",
				"-C",
				root,
				"status",
				"--porcelain=v1",
				"--branch",
				"--untracked-files=all",
			],
			{
				timeoutMs: 5_000,
			},
		)
		.catch(() => undefined);
	if (run === undefined || run.exitCode !== 0) {
		return;
	}
	const lines = run.stdout.split("\n");
	await refreshRepo($, root, lines[0]?.startsWith("## ") ? lines[0] : "");
	const status = new Map(
		lines
			.filter((l) => l.length > 3 && !l.startsWith("## "))
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
		await update($, alerts, (list) => [alert, ...list].slice(0, SHOWN));
	}
};

type StopInput = ClassicHookInputs["Stop"];

const syncBackground = async (
	$: EngineInterface,
	list: StopInput["background_tasks"] = [],
	scheduled: StopInput["session_crons"] = [],
) => {
	const line = (s: string) => cut(s.split("\n")[0] ?? "", 120);
	// subagents already have their rows under agents
	const nextTasks: BackgroundTask[] = list
		.filter((b) => b.type !== "subagent" && b.agent_type === undefined)
		.map((b) => ({
			id: b.id,
			type: b.type,
			status: b.status,
			label: line(
				b.command ??
					(b.server === undefined
						? (b.name ?? b.description)
						: `${b.server} ${b.tool ?? ""}`),
			),
		}));
	const nextCrons: SessionCron[] = scheduled.map((c) => ({
		id: c.id,
		schedule: c.schedule,
		recurring: c.recurring,
		prompt: line(c.prompt),
	}));
	if (JSON.stringify(nextTasks) !== JSON.stringify(await read($, tasks))) {
		await update($, tasks, () => nextTasks);
	}
	if (JSON.stringify(nextCrons) !== JSON.stringify(await read($, crons))) {
		await update($, crons, () => nextCrons);
	}
};

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
	await update($, skillRuns, (l) => [...l, run].slice(-SHOWN));
};

const isPaneShown = async ($: EngineInterface) =>
	(await $.ui.panes()).some((p) => p.id === PANE && p.isShown);

const setShown = async ($: EngineInterface, isShown: boolean) => {
	if ((await read($, paneShown)) !== isShown) {
		await update($, paneShown, () => isShown);
	}
};

const syncChord = async ($: EngineInterface) => {
	const key = (await boundKey($)) ?? "";
	if ((await read($, chord)) !== key) {
		await update($, chord, () => key);
	}
	return key;
};

// Shown: close. Open behind another pane's tab: the engine only retitles an
// open id, while a newly opened pane becomes the shown tab, so reopen it.
const toggle = async ($: EngineInterface, root: string | undefined) => {
	const pane = (await $.ui.panes()).find((p) => p.id === PANE);
	if (pane?.isShown) {
		await $.ui.close({ id: PANE });
		await setShown($, false);
		return false;
	}
	if (pane !== undefined) {
		await $.ui.close({ id: PANE });
	}
	await $.ui.open({ id: PANE, title: "summary", columns: 60 });
	await setShown($, true);
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

export const register: Register = (on) => {
	let loaded: string[] = [];
	let worked = false;
	let ask = "";
	let draining = false;
	let tick = 0;
	let root: string | undefined;
	const rain = newRain();
	// the tokens the last main model call took
	let stepTokens = 0;
	// The hint line's isWorking, the engine's own word on a running turn;
	// undefined until the line draws after a (re)load.
	let hintWorking: boolean | undefined;

	on("session.start", async ($, e, next) => {
		const key = await syncChord($);
		const top = await $.process
			.run(["git", "rev-parse", "--show-toplevel"], { timeoutMs: 5_000 })
			.catch(() => undefined);
		root = top?.exitCode === 0 ? top.stdout.trim() : undefined;
		await refreshGit($, root, false);
		await setShown($, await isPaneShown($));
		$.clock.every(100, async () => {
			// a render hook only reads, so the hint line's word lands here
			if (
				hintWorking !== undefined &&
				hintWorking !== (await read($, working)) > 0
			) {
				const t = await $.clock.now();
				await update($, working, () => (hintWorking ? t : 0));
			}
			// a click on another pane's tab hides this one without an event
			await setShown($, await isPaneShown($));
			if (!(await read($, paneShown))) {
				return;
			}
			tick++;
			const list = await read($, agents);
			const busy = isBusy(
				list,
				await read($, skillRuns),
				await read($, recent),
			);
			const since = await read($, working);
			const running = list.filter((a) => a.status === "running");
			rain.pace = rainSpeed(
				[
					...(since > 0 ? [await read($, mainModel)] : []),
					...running.map((a) => a.model),
				],
				running.length,
				stepTokens,
			);
			// a turn alone redraws once a second for its elapsed time
			if (busy || tick % (since > 0 ? 10 : 100) === 0) {
				$.ui.invalidate("ui.render");
			}
		});
		// The rain repaints its Raster in place: a redraw of the whole pane folds
		// to one per 100 ms, a blit runs at the surface's frame rate.
		$.clock.every(RAIN_MS, async () => {
			if (rain.columns === 0 || !(await read($, paneShown))) {
				return;
			}
			const now = await $.clock.now();
			rain.t += Math.min(now - rain.at, 1000) * rain.pace;
			rain.at = now;
			// idle, the rain clock stands still and only the message moves
			if (rain.pace === 0) {
				if (!rain.wasIdle) {
					rain.wasIdle = true;
					rain.idleSince = now;
				}
				const message = rainMessage(rain.columns, rain.idleSince, now);
				if (message === rain.lastMessage) {
					return;
				}
				rain.lastMessage = message;
				await $.ui
					.blit({
						requestId: PANE,
						key: RAIN,
						cells: rainCells(rain.t, rain.columns, RAIN_ROWS, message),
					})
					.catch(() => undefined);
				return;
			}
			rain.wasIdle = false;
			rain.lastMessage = "";
			await $.ui
				.blit({
					requestId: PANE,
					key: RAIN,
					cells: rainCells(rain.t, rain.columns, RAIN_ROWS),
				})
				.catch(() => undefined);
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
		// commits and pushes from another terminal show up too
		$.clock.every(15_000, async () => {
			if (await read($, paneShown)) {
				await refreshGit($, root, false);
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
		if (step.usage !== null) {
			stepTokens = totalTokens(step.usage);
		}
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
			const mark: TurnMark = { ms: e.durationMs, ok: e.reason === "answer" };
			await update($, turns, (list) => [...list, mark].slice(-TURNS_MAX));
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
					...(e.usage === undefined ? {} : { tokens: totalTokens(e.usage) }),
					ask,
					answer: e.answer.slice(0, 4000),
				};
				await update($, recent, (list) =>
					[item, ...list.filter((w) => w.id !== item.id)].slice(0, SHOWN),
				);
			}
			if (worked) {
				await refreshGit($, root, true);
			}
			worked = false;
		}

		return next(e);
	});

	// A stop carries the session's background work and crons; a finished task
	// or a fired cron wakes the session, so the next stop brings the change.
	on("classic.Stop", async ($, e, next) => {
		await syncBackground($, e.background_tasks, e.session_crons);
		return next(e);
	}).catch((_, e, next) => next(e));

	on("classic.SubagentStop", async ($, e, next) => {
		await syncBackground($, e.background_tasks, e.session_crons);
		return next(e);
	}).catch((_, e, next) => next(e));

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
		await setShown($, false);

		return closed;
	}).catch((_, e, next) => next(e));

	// The hint under the prompt carries the toggle hint as dim tail text, so the
	// band above the prompt stays free. A chord presses only a mounted Button, so
	// one rides along hidden.
	on("ui.render", { component: "PromptHint" }, async ($, e, next) => {
		hintWorking = e.props.isWorking;
		if (await read($, paneShown)) {
			return next(e);
		}
		const key = await read($, chord);
		const tail = [e.props.tail, key === "" ? `/${PANE}` : `${key} ${PANE}`]
			.filter(Boolean)
			.join(" · ");
		const below = await next({ ...e, props: { ...e.props, tail } });
		if (key === "") {
			return below;
		}
		const { Box, Button } = $.ui.resolve(e);

		return (
			<Box flexDirection="column">
				{below}
				<Box display="none">
					<Button
						plain
						key="toggle"
						label={PANE}
						action={TOGGLE_ACTION}
						onPress={() => toggle($, root)}
					/>
				</Box>
			</Box>
		);
	});

	on("ui.render", { component: "Pane", requestId: PANE }, async ($, e) =>
		paneView({
			e,
			els: $.ui.resolve(e),
			t: await $.clock.now(),
			root,
			rain,
			hint: hintOf(await read($, chord)),
			onToggle: () => toggle($, root),
			list: await read($, agents),
			runs: await read($, skillRuns),
			work: await read($, recent),
			touched: await read($, files),
			uncommitted: await read($, dirty),
			git: await read($, repo),
			warnings: await read($, alerts),
			tag: await read($, mainModel),
			since: await read($, working),
			bg: await read($, tasks),
			scheduled: await read($, crons),
			marks: await read($, turns),
		}),
	);
};
