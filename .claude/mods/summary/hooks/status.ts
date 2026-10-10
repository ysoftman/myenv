import type { AgentStatus, TurnCompleteReason } from "claude-code";
import type { AgentRow, SkillRun, WorkItem } from "../types";

export const STATUS: Record<AgentStatus, AgentRow["status"]> = {
	pending: "running",
	running: "running",
	waiting: "running",
	idle: "idle",
	completed: "done",
	failed: "failed",
	killed: "killed",
};

export const TURN_END: Record<TurnCompleteReason, AgentRow["status"]> = {
	answer: "done",
	aborted: "killed",
	refusal: "failed",
	error: "failed",
};

export const RUN_END: Record<TurnCompleteReason, SkillRun["result"]> = {
	answer: "done",
	aborted: "aborted",
	refusal: "failed",
	error: "failed",
};

export const isLive = (a: AgentRow) =>
	a.status === "running" || a.status === "idle";

export const end = (a: AgentRow, t: number) =>
	a.status === "running" ? t : (a.endedAt ?? t);

export const sync = (
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

export const isOpenRun = (r: SkillRun | undefined) =>
	r !== undefined && r.result === undefined;

export const isBusy = (list: AgentRow[], runs: SkillRun[], work: WorkItem[]) =>
	list.some((a) => a.status === "running") ||
	(runs.length > 0 && runs.at(-1)?.result === undefined) ||
	work.some((w) => w.text === undefined);
