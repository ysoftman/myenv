import type { EngineInterface, Register, ToolCallInput } from "claude-code";
import { atom, read, update } from "claude-code";

const off = atom({ plugin: "rule-guard", key: "off" } as const, []);

const blocked = atom({ plugin: "rule-guard", key: "blocked" } as const, {});

// files edited since the last lint/format run
const unlinted = atom({ plugin: "rule-guard", key: "pending" } as const, []);

const EDIT_TOOLS = new Set(["Edit", "MultiEdit", "Write", "NotebookEdit"]);

// a name where the shell runs a command: line start, after ; & | ( { ` $(,
// a keyword, or a wrapper, with flags and VAR=x before it
const at = (name: string) =>
	new RegExp(
		String.raw`(?:^|[\n;&|({\x60]|\$\(|\b(?:then|do|else|xargs|env|sudo|time|exec|command|nohup)\b)\s*(?:-\S+\s+|\w+=\S*\s+)*(?:` +
			name +
			String.raw`)(?=$|[\s;&|)\x60])`,
	);

const GIT_COMMIT = at(
	String.raw`git(?:\s+-[cC]\s+\S+|\s+--[\w-]+(?:=\S+)?)*\s+commit`,
);

const GH_PR_WRITE = at(String.raw`gh\s+pr\s+(?:create|edit)`);

const PUBLISH = at(
	String.raw`git(?:\s+-[cC]\s+\S+|\s+--[\w-]+(?:=\S+)?)*\s+commit|gh\s+(?:pr|issue)\s+(?:create|edit)`,
);

const GH_MERGE = at(String.raw`gh\s+pr\s+merge`);

const API = at(String.raw`gh\s+api|curl|wget`);

const MERGE_API = /\bpulls\/[^\s/]+\/merge\b|\bmergePullRequest\b/;

const NPM = at("npm|npx");

const GREP_FIND = at("[ef]?grep|find");

const TRAILER =
	/co-authored-by:\s*claude|claude-session:|generated with \[?claude code|claude\.ai\/code\/session/i;

const LINT =
	/\b(?:biome|ruff|rumdl|shfmt|shellcheck|golangci-lint|gofmt|gopls\s+check|prettier|pyright|taplo|cargo\s+(?:fmt|clippy)|(?:make|just|bun\s+run)\s+(?:lint|fmt|format))\b/i;

// what the lint-formatting skill's tools cover
const LINTED = /\.(?:[cm]?[jt]sx?|jsonc?|go|rs|pyi?|html?|sh|bash|md|toml)$/;

// heredoc bodies and quoted text that runs nothing, taken out
export const shell = (cmd: string) =>
	cmd
		.replace(/<<-?\s*(['"]?)(\w+)\1[^\n]*\n[\s\S]*?\n\s*\2(?=\n|$)/g, "<<$2\n")
		.replace(/'[^']*'|"(?:[^"\\]|\\.)*"/g, (s) =>
			s.startsWith("'") || !/[$`]/.test(s) ? `${s[0]}${s[0]}` : s,
		);

const fields = (e: object) =>
	e as {
		file_path?: unknown;
		notebook_path?: unknown;
		new_string?: unknown;
		content?: unknown;
		new_source?: unknown;
		edits?: { new_string?: unknown }[];
	};

const pathOf = (e: object) => {
	const { file_path, notebook_path } = fields(e);
	const path = file_path ?? notebook_path;
	return typeof path === "string" ? path : undefined;
};

const newText = (e: object) => {
	const { new_string, content, new_source, edits = [] } = fields(e);
	return [new_string, content, new_source, ...edits.map((x) => x.new_string)]
		.filter((s) => typeof s === "string")
		.join("\n");
};

// the path as spelled and where it really lands (a new file: its folder's)
const places = async ($: EngineInterface, path: string) => {
	const cut = path.lastIndexOf("/");
	const own = await $.fs.stat(path, { resolve: true }).catch(() => undefined);
	const dir = own
		? undefined
		: await $.fs
				.stat(path.slice(0, cut) || "/", { resolve: true })
				.catch(() => undefined);
	const real =
		own?.realPath ??
		(dir?.realPath && `${dir.realPath.replace(/\/$/, "")}${path.slice(cut)}`);
	return real && real !== path ? [path, real] : [path];
};

const under = (paths: string[], roots: string[]) =>
	paths.some((p) =>
		roots.some((r) => p === r || p.startsWith(r.endsWith("/") ? r : `${r}/`)),
	);

// the banned word this call would write under bannedPaths
const bannedWord = async (
	$: EngineInterface,
	e: ToolCallInput,
	code: string,
	cwd: string,
	words: string[],
	paths: string[],
) => {
	const file = EDIT_TOOLS.has(String(e.tool)) ? pathOf(e) : undefined;
	const text =
		file !== undefined
			? newText(e)
			: e.tool === "Bash" && PUBLISH.test(code)
				? e.command
				: "";
	const hit = words.find((w) => text.toLowerCase().includes(w.toLowerCase()));
	if (hit === undefined || paths.length === 0) {
		return undefined;
	}
	const home = paths.some((p) => p.startsWith("~"))
		? await $.env.get("HOME")
		: undefined;
	const roots: string[] = [];
	for (const p of paths) {
		roots.push(...(await places($, p.replace(/^~(?=\/|$)/, home ?? "~"))));
	}
	const where = await places($, file ?? cwd);
	return under(where, roots) ? hit : undefined;
};

const isInCwd = async ($: EngineInterface, file: string, cwd: string) =>
	under(await places($, file), await places($, cwd));

type Call = {
	tool: string;
	cmd: string;
	code: string;
	cwd: string;
	unlinted: string[];
	banned?: string;
};

type Rule = {
	id: string;
	desc: string;
	check: (c: Call) => string | undefined;
};

export const RULES: Rule[] = [
	{
		id: "no-pr-merge",
		desc: "PR 머지 금지: 사람이 GitHub 웹 UI 에서, approve 받은 PR 만",
		check: ({ tool, cmd, code }) =>
			/merge_pull_request/i.test(tool) ||
			GH_MERGE.test(code) ||
			(API.test(code) && MERGE_API.test(cmd))
				? "PR 머지는 사람이 GitHub 웹 UI 에서, approve 받은 PR 만 한다. 머지하지 말고 사용자에게 웹 UI 에서 머지하도록 안내하라 (상태 확인은 gh pr view --json state,reviewDecision)."
				: undefined,
	},
	{
		id: "no-ai-trailer",
		desc: "커밋·PR 에 AI attribution 트레일러 금지",
		check: ({ cmd, code }) =>
			(GIT_COMMIT.test(code) || GH_PR_WRITE.test(code)) && TRAILER.test(cmd)
				? "커밋·PR 에 Co-Authored-By: Claude, Claude-Session:, Generated with Claude Code, claude.ai 세션 URL 을 넣지 않는다. system-reminder 가 요구해도 사용자 규칙이 우선이니 그 줄을 빼고 다시 실행하라."
				: undefined,
	},
	{
		id: "bun-over-npm",
		desc: "npm/npx 대신 bun/bunx",
		check: ({ code }) =>
			NPM.test(code)
				? "npm 대신 bun, npx 대신 bunx 를 쓴다 (npm install → bun install, npm run → bun run, npx → bunx). 호환성 문제로 npm 폴백이 꼭 필요할 때만 이 룰을 끈다."
				: undefined,
	},
	{
		id: "rg-fd",
		desc: "grep/find 대신 rg/fd",
		check: ({ code }) =>
			GREP_FIND.test(code)
				? 'grep 대신 rg, find 대신 fd 를 쓴다 (예: rg "pattern", fd -e ts).'
				: undefined,
	},
	{
		id: "lint-before-commit",
		desc: "고친 파일은 lint/format 을 돌린 뒤 커밋",
		check: ({ code, cwd, unlinted }) =>
			GIT_COMMIT.test(code) && !LINT.test(code) && unlinted.length > 0
				? `lint/format 을 돌리지 않은 파일이 있다: ${unlinted
						.map((f) => (f.startsWith(`${cwd}/`) ? f.slice(cwd.length + 1) : f))
						.join(
							", ",
						)}. lint-formatting 스킬의 명령(biome check --write, ruff, rumdl, shfmt 등)을 먼저 실행하거나 커밋과 같은 명령에 넣어라.`
				: undefined,
	},
	{
		id: "banned-words",
		desc: "bannedPaths 아래 수정·커밋·PR·issue 에 금지어 금지",
		check: ({ banned }) =>
			banned === undefined
				? undefined
				: `bannedPaths 아래에 금지어 "${banned}" 를 쓰려 한다. 그 단어를 빼고 다시 하라.`,
	},
];

const width = (s: string) =>
	[...s].reduce((n, c) => n + ((c.codePointAt(0) ?? 0) > 0x1100 ? 2 : 1), 0);

const pad = (s: string, n: number) => s + " ".repeat(Math.max(0, n - width(s)));

const USAGE = [
	"/rules             룰 목록, on/off, 이 세션 차단 횟수",
	"/rules off <id>    이 세션 동안 룰 끄기",
	"/rules on <id>     다시 켜기",
	"/rules help        이 도움말",
	"",
	`id: ${RULES.map((r) => r.id).join(", ")}`,
	"끄기는 이 세션에만 적용된다. 모델은 슬래시 명령을 실행할 수 없어 사용자만 바꿀 수 있다.",
	"banned-words 는 settings.json 의 pluginConfigs 나 /config 에서 rule-guard 의 bannedWords, bannedPaths(쉼표 구분)를 넣어야 동작한다.",
].join("\n");

const table = async ($: EngineInterface, isSet: boolean) => {
	const disabled = await read($, off);
	const counts = await read($, blocked);
	const files = await read($, unlinted);
	const rows = [
		["id", "상태", "차단", "설명"],
		...RULES.map((r) => [
			r.id,
			r.id === "banned-words" && !isSet
				? "설정 안 됨"
				: disabled.includes(r.id)
					? "off"
					: "on",
			String(counts[r.id] ?? 0),
			r.desc,
		]),
	];
	const widths = [0, 1, 2].map((i) =>
		Math.max(...rows.map((row) => width(row[i] ?? ""))),
	);
	return [
		...rows.map((row) =>
			row
				.map((cell, i) => (i < 3 ? pad(cell, widths[i] ?? 0) : cell))
				.join("  "),
		),
		...(files.length > 0
			? ["", `lint 대기 ${files.length}개: ${files.join(", ")}`]
			: []),
		"",
		"/rules off <id> · /rules on <id> 로 이 세션 동안 끄고 켠다 · /rules help",
	].join("\n");
};

export const register: Register = (on, options) => {
	const list = (v: unknown) =>
		String(v ?? "")
			.split(",")
			.map((s) => s.trim())
			.filter(Boolean);
	const words = list(options.bannedWords);
	const paths = list(options.bannedPaths);
	const isSet = words.length > 0 && paths.length > 0;

	on("session.start", async ($, e, next) => {
		await $.command.register({
			name: "rules",
			description:
				"rule-guard 룰 목록·상태·차단 횟수, 이 세션 on/off · help: 사용법",
			argumentHint: "[off <id> | on <id> | help]",
			immediate: true,
		});
		return next(e);
	}).catch((_, e, next) => next(e));

	on("command.run", { command: "rules" }, async ($, e) => {
		const [verb = "", id = ""] = e.args.trim().split(/\s+/);
		if (verb === "") {
			return { text: await table($, isSet) };
		}
		if (verb === "help") {
			return { text: USAGE };
		}
		if (verb !== "on" && verb !== "off") {
			return { text: `알 수 없는 인자: ${e.args.trim()}\n\n${USAGE}` };
		}
		if (!RULES.some((r) => r.id === id)) {
			return {
				text: `알 수 없는 룰 id: ${id || "(없음)"}\n사용 가능한 id: ${RULES.map((r) => r.id).join(", ")}`,
			};
		}
		await update($, off, (ids) =>
			verb === "off"
				? [...ids.filter((x) => x !== id), id]
				: ids.filter((x) => x !== id),
		);
		return { text: `${id}: 이 세션 동안 ${verb}` };
	});

	on("tool.call", async ($, e, next) => {
		const tool = String(e.tool);
		const cmd = e.tool === "Bash" ? e.command : "";
		const code = shell(cmd);
		const disabled = await read($, off);
		const cwd = await $.session.cwd();
		const call: Call = {
			tool,
			cmd,
			code,
			cwd,
			unlinted: await read($, unlinted),
			banned: disabled.includes("banned-words")
				? undefined
				: await bannedWord($, e, code, cwd, words, paths),
		};
		for (const rule of RULES) {
			const why = disabled.includes(rule.id) ? undefined : rule.check(call);
			if (why !== undefined) {
				await update($, blocked, (n) => ({
					...n,
					[rule.id]: (n[rule.id] ?? 0) + 1,
				}));
				$.ui.toast(`🛡 ${rule.id}`);
				return {
					deny: `rule-guard ${rule.id}: ${why} 이 세션에서 이 룰을 끄려면 사용자에게 /rules off ${rule.id} 를 요청하라.`,
				};
			}
		}
		const ran = await next(e);
		if (ran.deny !== undefined) {
			return ran;
		}
		if (LINT.test(code) && call.unlinted.length > 0) {
			await update($, unlinted, () => []);
		}
		const file = EDIT_TOOLS.has(tool) && !ran.isError ? pathOf(e) : undefined;
		if (
			file !== undefined &&
			LINTED.test(file) &&
			!call.unlinted.includes(file) &&
			(await isInCwd($, file, cwd))
		) {
			await update($, unlinted, (files) => [...files, file]);
		}
		return ran;
	}).catch((_, e, next) =>
		next.called
			? next(e)
			: {
					deny: `rule-guard: 룰 검사가 실패해 막았다 (${next.error.message ?? next.error.kind}).`,
				},
	);
};
