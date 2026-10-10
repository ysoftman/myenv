import type { AgentRow, SkillRun } from "../types";

export const PANE = "summary";

export const TOGGLE_ACTION = "app:toggleDiffPreSession";

// rows each box lists at most, so the pane fits a terminal's height
export const SHOWN = 3;

export const SPARK = "▁▂▃▄▅▆▇█";

export const C = {
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

export const SPINNER = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏";

export const PULSE = "◇◈◆◈";

export const GLOW = [
	C.mauve,
	C.pink,
	C.lavender,
	C.blue,
	C.sky,
	C.blue,
	C.lavender,
	C.pink,
];

// head first; a drop's trail always ends on the last color
export const rgb = (hex: string) => Number.parseInt(hex.slice(1), 16);

export const ICON: Record<AgentRow["status"], string> = {
	running: "●",
	idle: "○",
	done: "✓",
	failed: "✗",
	killed: "■",
};

export const COLOR: Record<AgentRow["status"], string> = {
	running: C.yellow,
	idle: C.overlay,
	done: C.green,
	failed: C.red,
	killed: C.red,
};

export const GIT_COLOR: Record<string, string> = {
	M: C.yellow,
	A: C.green,
	D: C.red,
	R: C.blue,
	"??": C.teal,
};

export const RUN: Record<
	NonNullable<SkillRun["result"]>,
	{ icon: string; color: string }
> = {
	done: { icon: "✓", color: C.green },
	failed: { icon: "✗", color: C.red },
	aborted: { icon: "■", color: C.overlay },
};

export const ORDER: AgentRow["status"][] = [
	"running",
	"idle",
	"done",
	"failed",
	"killed",
];

export const modelColor = (model: string) =>
	model.startsWith("opus")
		? C.peach
		: model.startsWith("haiku")
			? C.teal
			: C.blue;
