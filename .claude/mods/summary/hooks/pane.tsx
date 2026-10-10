import type { Elements, RenderInput } from "claude-code";
import type {
	AgentRow,
	Alert,
	BackgroundTask,
	FileTouch,
	RepoState,
	SessionCron,
	SkillRun,
	TurnMark,
	WorkItem,
} from "../types";
import { hhmm, nextFire } from "./cron";
import { ago, elapsed, kilo, tail } from "./format";
import type { Rain } from "./rain";
import { RAIN, RAIN_ROWS, rainCells, rainMessage } from "./rain";
import { end, isBusy, isLive } from "./status";
import {
	C,
	COLOR,
	GIT_COLOR,
	GLOW,
	ICON,
	modelColor,
	ORDER,
	PULSE,
	RUN,
	SHOWN,
	SPARK,
	SPINNER,
	TOGGLE_ACTION,
} from "./theme";

// Everything the pane draws, read by register (only it may touch $).
export type PaneValues = {
	e: RenderInput<"Pane">;
	els: Elements[RenderInput<"Pane">["surface"]];
	t: number;
	root: string | undefined;
	rain: Rain;
	hint: string;
	onToggle: () => unknown;
	list: AgentRow[];
	runs: SkillRun[];
	work: WorkItem[];
	touched: FileTouch[];
	uncommitted: number;
	git: RepoState;
	warnings: Alert[];
	tag: string;
	since: number;
	bg: BackgroundTask[];
	scheduled: SessionCron[];
	marks: TurnMark[];
};

export const paneView = ({
	e,
	els,
	t,
	root,
	rain,
	hint,
	onToggle,
	list,
	runs,
	work,
	touched,
	uncommitted,
	git,
	warnings,
	tag,
	since,
	bg,
	scheduled,
	marks,
}: PaneValues) => {
	const { Box, Button, Text } = els;
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
	const typeWidth = Math.max(0, ...bg.map((b) => b.type.length));
	const spark = marks.slice(-(width - 4));
	const longest = Math.max(1, ...spark.map((m) => m.ms));
	// live agents first, then the latest finished
	const keep = new Set(
		[...list.filter(isLive), ...list.filter((a) => !isLive(a)).reverse()].slice(
			0,
			SHOWN,
		),
	);
	const shown = list.filter((a) => keep.has(a));
	const bgShown = bg.slice(0, SHOWN);
	const cronsShown = scheduled.slice(0, SHOWN - bgShown.length);
	const bgMore =
		bg.length + scheduled.length - bgShown.length - cronsShown.length;
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
	if ("Raster" in els) {
		rain.columns = width;
	}
	// docked, the pane fills its height so the rain sits on the bottom edge;
	// inline, the frame fits the tree and would grow to bodyRows instead
	const floor =
		e.props.placement === "dock" ? e.props.scroll.bodyRows : undefined;
	const keycap = (k: string) => (
		<Text backgroundColor={C.surface0} color={C.lavender}>{` ${k} `}</Text>
	);

	return (
		<Box
			flexDirection="column"
			width={width}
			{...(floor === undefined ? {} : { minHeight: floor })}
		>
			<Box paddingX={1} justifyContent="space-between">
				<Box gap={2}>
					<Text bold color={C.mauve}>
						<Text color={glow}>{busy ? PULSE[frame % PULSE.length] : "◆"}</Text>{" "}
						summary
					</Text>
					{since > 0 && (
						<Text color={C.peach}>{`● working ${elapsed(t - since)}`}</Text>
					)}
				</Box>
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
							<Text color={C.overlay}>{`${ago(t - a.at)} ago`.padEnd(7)}</Text>{" "}
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
						<Text color={modelColor(a.model)} dimColor={a.status !== "running"}>
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
				{list.length > shown.length && (
					<Text color={C.overlay}>{`+${list.length - shown.length} more`}</Text>
				)}
			</Box>
			<Box
				flexDirection="column"
				borderStyle="round"
				borderColor={C.surface1}
				paddingX={1}
			>
				<Text>
					<Text bold color={C.teal}>
						background
					</Text>
					<Text color={C.overlay}>
						{`  ${bg.length} running · ${scheduled.length} scheduled`}
					</Text>
				</Text>
				{bg.length === 0 && scheduled.length === 0 && (
					<Text color={C.overlay}>no background task or schedule</Text>
				)}
				{bgShown.map((b) => (
					<Text wrap="truncate-end">
						<Text color={b.status === "running" ? C.yellow : C.overlay}>
							{b.status === "running" ? "●" : "○"}
						</Text>{" "}
						<Text color={C.sky}>{b.type.padEnd(typeWidth)}</Text>{" "}
						<Text color={C.subtext}>{b.label}</Text>
					</Text>
				))}
				{cronsShown.map((c) => {
					const at = nextFire(c.schedule, t);
					return (
						<Text wrap="truncate-end">
							<Text color={C.lavender}>{c.recurring ? "↻" : "◷"}</Text>{" "}
							<Text color={C.text}>
								{at === undefined
									? c.schedule
									: `${hhmm(at, t)} in ${ago(at - t)}`}
							</Text>{" "}
							<Text color={C.subtext}>{c.prompt}</Text>
						</Text>
					);
				})}
				{bgMore > 0 && <Text color={C.overlay}>{`+${bgMore} more`}</Text>}
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
				{touched.slice(0, SHOWN).map((f) => (
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
				{touched.length > SHOWN && (
					<Text color={C.overlay}>{`+${touched.length - SHOWN} more`}</Text>
				)}
			</Box>
			<Box
				flexDirection="column"
				borderStyle="round"
				borderColor={C.surface1}
				paddingX={1}
			>
				<Text>
					<Text bold color={C.peach}>
						git
					</Text>
					<Text color={C.overlay}>
						{root === undefined
							? "  not a repository"
							: `  ${git.branch ?? "?"}${
									git.upstream === undefined
										? ` (no upstream) · ${uncommitted} uncommitted`
										: ` → ${git.upstream} · ${uncommitted} uncommitted · ↑${git.ahead} ↓${git.behind}`
								}`}
					</Text>
				</Text>
				{git.commits.length === 0 && (
					<Text color={C.overlay}>no commit yet</Text>
				)}
				{git.commits.map((c, i) => (
					<Text wrap="truncate-end">
						{git.upstream === undefined ? (
							<Text color={C.overlay}>·</Text>
						) : i < git.ahead ? (
							<Text color={C.yellow}>↑</Text>
						) : (
							<Text color={C.green}>✓</Text>
						)}{" "}
						<Text color={C.overlay}>{c.hash}</Text>{" "}
						<Text color={C.overlay} dimColor>
							{ago(t - c.at).padStart(3)}
						</Text>{" "}
						<Text color={i < git.ahead ? C.text : C.subtext}>{c.subject}</Text>
					</Text>
				))}
			</Box>
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
								{[r.model, r.effort].filter((v) => v !== undefined).join(" · ")}
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
					<Text bold color={C.sky}>
						turns
					</Text>
					{marks.length > 0 && (
						<Text color={C.overlay}>
							{`  ${marks.length} · avg ${elapsed(
								marks.reduce((n, m) => n + m.ms, 0) / marks.length,
							)} · max ${elapsed(Math.max(...marks.map((m) => m.ms)))}`}
						</Text>
					)}
				</Text>
				{spark.length === 0 ? (
					<Text color={C.overlay}>no turn yet</Text>
				) : (
					<Text>
						{spark.map((m) => (
							<Text color={m.ok ? C.green : C.red}>
								{SPARK[Math.max(0, Math.ceil((m.ms / longest) * 8) - 1)]}
							</Text>
						))}
					</Text>
				)}
			</Box>
			<Box paddingX={1} gap={2}>
				<Button plain key="toggle" action={TOGGLE_ACTION} onPress={onToggle}>
					{keycap(hint)}
					<Text color={C.subtext}> close</Text>
				</Button>
				<Text>
					{keycap("ctrl+x tab")}
					<Text color={C.subtext}> focus</Text>
				</Text>
			</Box>
			<Box flexGrow={1} />
			{"Raster" in els && (
				<els.Raster
					key={RAIN}
					columns={width}
					rows={RAIN_ROWS}
					cells={rainCells(
						rain.t,
						width,
						RAIN_ROWS,
						rain.pace === 0 ? rainMessage(width, rain.idleSince, t) : undefined,
					)}
				/>
			)}
		</Box>
	);
};
