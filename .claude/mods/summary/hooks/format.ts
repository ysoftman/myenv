import type { ModelUsage } from "claude-code";

export const totalTokens = (u: ModelUsage) =>
	u.input_tokens +
	u.output_tokens +
	u.cache_read_input_tokens +
	u.cache_creation_input_tokens;

export const LABEL_MAX = 20;

export const elapsed = (ms: number) => {
	const s = Math.max(0, Math.round(ms / 1000));
	return s < 60
		? `${s}s`
		: `${Math.floor(s / 60)}m${String(s % 60).padStart(2, "0")}s`;
};

export const clip = (s: string) =>
	s.length > LABEL_MAX ? `${s.slice(0, LABEL_MAX - 1)}…` : s;

export const cut = (s: string, n: number) =>
	s.length > n ? `${s.slice(0, n - 1)}…` : s;

export const firstLine = (answer: string) =>
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

export const ago = (ms: number) => {
	const s = Math.max(0, Math.round(ms / 1000));
	return s < 60
		? `${s}s`
		: s < 3600
			? `${Math.floor(s / 60)}m`
			: `${Math.floor(s / 3600)}h`;
};

export const kilo = (n: number) =>
	n < 1000 ? `${n}` : `${Math.round(n / 1000)}k`;

export const tail = (s: string, n: number) =>
	s.length > n ? `…${s.slice(s.length - n + 1)}` : s;

export const pathOf = (e: object) => {
	const { file_path, notebook_path } = e as {
		file_path?: unknown;
		notebook_path?: unknown;
	};
	const path = file_path ?? notebook_path;
	return typeof path === "string" ? path : undefined;
};

export const short = (model: string) => model.replace(/^.*claude-/, "");
