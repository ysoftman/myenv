export type AgentRow = {
	id: string;
	label: string;
	name?: string;
	model: string;
	description: string;
	startedAt: number;
	endedAt?: number;
	status: "running" | "idle" | "done" | "failed" | "killed";
	tool?: string;
	listed?: boolean;
};

export type WorkItem = {
	id: string;
	at: number;
	durationMs: number;
	tokens?: number;
	text?: string;
	ask?: string;
	answer?: string;
};

export type FileTouch = {
	path: string;
	edits: number;
	status?: string;
};

export type Alert = {
	at: number;
	tool: string;
	reason: string;
	agent?: string;
};

export type SkillRun = {
	skills: string[];
	model: string;
	effort?: string;
	startedAt: number;
	endedAt?: number;
	result?: "done" | "failed" | "aborted";
};

export type BackgroundTask = {
	id: string;
	type: string;
	status: string;
	label: string;
};

export type SessionCron = {
	id: string;
	schedule: string;
	recurring: boolean;
	prompt: string;
};

export type Commit = {
	hash: string;
	at: number;
	subject: string;
};

export type RepoState = {
	branch?: string;
	upstream?: string;
	ahead: number;
	behind: number;
	commits: Commit[];
};

export type TurnMark = {
	ms: number;
	ok: boolean;
};

declare module "claude-code" {
	interface PluginState {
		summary: {
			agents: AgentRow[];
			now: number;
			recent: WorkItem[];
			files: FileTouch[];
			dirty: number;
			alerts: Alert[];
			runs: SkillRun[];
			model: string;
			shown: boolean;
			chord: string;
			seen: string[];
			working: number;
			tasks: BackgroundTask[];
			crons: SessionCron[];
			turns: TurnMark[];
			repo: RepoState;
		};
	}
}
