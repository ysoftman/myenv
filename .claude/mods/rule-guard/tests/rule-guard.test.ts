import type { On } from "claude-code";
import type { Engine } from "claude-code/testing";
import { expect, test } from "claude-code/testing";
import { shell } from "../hooks/register";

// ~/.claude/skills is a link into the repo, as in myenv
const LINKS: [string, string][] = [
	["/home/me/.claude/skills", "/repo/.claude/skills"],
];

const setup = async ($: Engine, on: On, failing: string[] = []) => {
	const toasts: string[] = [];
	const ran: string[] = [];
	const specs: { description: string; argumentHint?: string }[] = [];
	on("session.start", (_, e) => ({ cwd: e.cwd }));
	on("command.register", (_, e) => {
		specs.push(e);
		return { value: { command: e.name } };
	});
	on("session.cwd", () => ({ value: "/repo" }));
	on("env.get", () => ({ value: "/home/me" }));
	on("fs.stat", (_, e) => ({
		value: {
			kind: "file" as const,
			size: 0,
			mtimeMs: 0,
			isLink: false,
			realPath: LINKS.reduce(
				(p, [from, to]) => (p.startsWith(from) ? to + p.slice(from.length) : p),
				e.path,
			),
		},
	}));
	on("ui.toast", (_, e) => {
		toasts.push(e.text);
		return { value: undefined };
	});
	on("tool.call", (_, e) => {
		ran.push(e.tool === "Bash" ? e.command : String(e.tool));
		return failing.includes(String(e.tool))
			? { isError: true as const, result: null, text: "failed" }
			: { result: "ok" };
	});
	await $.session.start({ cwd: "/repo", surface: null, isInteractive: false });

	const bash = async (command: string) =>
		(await $.tool.call({ tool: "Bash", command })).deny;
	const write = async (file_path: string, content = "x") =>
		(await $.tool.call({ tool: "Write", file_path, content })).deny;
	const rules = async (args = "") =>
		(
			await $.command.run({
				command: "rule-guard",
				args,
				origin: { kind: "composer" },
				presentation: { isFullscreen: true, columns: 120 },
			})
		).text ?? "";
	return { toasts, ran, specs, bash, write, rules };
};

const heredoc = (body: string) =>
	`git commit -m "$(cat <<'EOF'\n${body}\nEOF\n)"`;

test("no-pr-merge blocks merges by gh, the API and MCP tools", async ($, on) => {
	const { bash, ran } = await setup($, on);
	for (const cmd of [
		"gh pr merge 12 --squash",
		"cd x && gh pr merge --auto 12",
		"gh api -X PUT repos/o/r/pulls/12/merge",
		'gh api "repos/{owner}/{repo}/pulls/12/merge" -f merge_method=squash',
		"curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge",
		"gh api graphql -f query='mutation { mergePullRequest(input: {pullRequestId: \"x\"}) { clientMutationId } }'",
	]) {
		expect(await bash(cmd)).toContain("rule-guard no-pr-merge");
	}
	const mcp = await $.tool.call({
		tool: "mcp__github__merge_pull_request",
		pull_number: 12,
	} as never);
	expect(mcp.deny).toContain("/rule-guard off no-pr-merge");
	for (const cmd of [
		"gh pr view 12 --json state",
		"gh pr list",
		"git merge feature",
		'echo "gh pr merge 12"',
		"gh api repos/o/r/pulls/12",
	]) {
		expect(await bash(cmd)).toBeUndefined();
	}
	expect(ran).toHaveLength(5);
});

test("no-ai-trailer blocks attribution in commits and PRs", async ($, on) => {
	const { bash } = await setup($, on);
	for (const cmd of [
		heredoc("fix x\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"),
		heredoc("fix x\n\nClaude-Session: https://claude.ai/code/session_abc"),
		'git commit -m "fix x" -m "co-authored-by: claude"',
		'git -c user.name=me commit --amend -m "x\n\nClaude-Session: y"',
		'gh pr create --title x --body "🤖 Generated with [Claude Code](https://claude.com/claude-code)"',
		'gh pr edit 3 --body "see https://claude.ai/code/session_abc"',
	]) {
		expect(await bash(cmd)).toContain("rule-guard no-ai-trailer");
	}
	for (const cmd of [
		heredoc("fix x\n\nCo-Authored-By: Alice <a@example.com>"),
		"git log -1 --format=%B | rg -i 'claude-session:'",
		'echo "Claude-Session: x"',
	]) {
		expect(await bash(cmd)).toBeUndefined();
	}
});

test("bun-over-npm blocks npm and npx where a command runs", async ($, on) => {
	const { bash } = await setup($, on);
	for (const cmd of [
		"npm install",
		"npx prettier --check .",
		"cd web && npm run build",
		"FOO=1 npm test",
		"echo $(npx tsc -v)",
		"ls | xargs npm view",
		"sudo npm i -g x",
	]) {
		expect(await bash(cmd)).toContain("rule-guard bun-over-npm");
	}
	for (const cmd of [
		"bun install",
		"bunx prettier --check .",
		"echo npm install",
		"pnpm install",
		'git commit -m "bump npm deps"',
		heredoc("bump deps\n\nnpm audit was noisy"),
		heredoc("don't pin\n\nnpm's lockfile stays"),
		"rg npm package.json",
	]) {
		expect(await bash(cmd)).toBeUndefined();
	}
	expect(await bash("npm install")).toContain(
		"호환성 문제로 npm 폴백이 꼭 필요할 때만",
	);
});

test("rg-fd blocks grep and find, not git grep or --find-renames", async ($, on) => {
	const { bash, toasts } = await setup($, on);
	for (const cmd of [
		"grep -r foo .",
		"find . -name '*.ts'",
		"rg -l foo | grep bar",
		"rg -l foo | xargs grep -n bar",
		"egrep 'a|b' x",
		"if true; then find . ; fi",
	]) {
		expect(await bash(cmd)).toContain("rule-guard rg-fd");
	}
	expect(toasts).toContain("🛡 rg-fd");
	for (const cmd of [
		"git grep foo",
		"git diff --find-renames HEAD~1",
		"git log --grep=fix",
		"rg foo",
		"fd -e ts",
		'echo "grep it"',
		heredoc("tidy\n\nfind callers faster"),
	]) {
		expect(await bash(cmd)).toBeUndefined();
	}
});

test("lint-before-commit holds a commit until lint runs", async ($, on) => {
	const { bash, write, rules } = await setup($, on);
	expect(await bash("git commit -m x")).toBeUndefined();

	await write("/repo/src/a.ts");
	await write("/repo/img.png");
	await write("/home/me/.claude/projects/p/memory/m.md");
	await write("/private/tmp/scratch/s.ts");
	const held = await bash("git -C /repo commit -m x");
	expect(held).toContain("rule-guard lint-before-commit");
	expect(held).toContain("src/a.ts");
	expect(held).not.toContain("img.png");
	expect(held).not.toContain("m.md");
	expect(held).not.toContain("s.ts");
	expect(await bash("git commit-graph write")).toBeUndefined();
	expect(await rules()).toContain("lint 대기 1개");

	expect(await bash("biome check --write src/a.ts")).toBeUndefined();
	expect(await bash("git commit -m x")).toBeUndefined();

	await write("/home/me/.claude/skills/s/SKILL.md");
	expect(await bash("git commit -m x")).toContain(
		"/home/me/.claude/skills/s/SKILL.md",
	);
	expect(
		await bash("rumdl fmt --extend-disable MD013 . && git commit -m x"),
	).toBeUndefined();
	expect(await bash("git commit -m x")).toBeUndefined();

	await write("/repo/b.py");
	expect(await bash('git commit -m "run ruff later"')).toContain("b.py");
	expect(await bash("bunx pyright b.py")).toBeUndefined();
	expect(await bash("git commit -m x")).toBeUndefined();
});

test("a failed edit is not held for lint", async ($, on) => {
	const { bash } = await setup($, on, ["Edit"]);
	await $.tool.call({
		tool: "Edit",
		file_path: "/repo/a.ts",
		old_string: "a",
		new_string: "b",
	});
	expect(await bash("git commit -m x")).toBeUndefined();
});

test("banned-words is unset and blocks nothing by default", async ($, on) => {
	const { bash, write, rules } = await setup($, on);
	expect(await write("/repo/a.txt", "secretword")).toBeUndefined();
	expect(await bash('git commit -m "secretword" -- a.txt')).toBeUndefined();
	expect(await rules()).toMatch(/banned-words\s+설정 안 됨/);
});

test(
	"banned-words blocks edits under bannedPaths",
	{ options: { bannedWords: "secretword, other", bannedPaths: "~/pub" } },
	async ($, on) => {
		const { bash, write, rules } = await setup($, on);
		expect(await write("/home/me/pub/a.md", "has SecretWord")).toContain(
			'rule-guard banned-words: bannedPaths 아래에 금지어 "secretword"',
		);
		const edit = await $.tool.call({
			tool: "Edit",
			file_path: "/home/me/pub/b.ts",
			old_string: "a",
			new_string: "OTHER",
		});
		expect(edit.deny).toContain("rule-guard banned-words");
		expect(await write("/home/me/pub/a.md", "clean")).toBeUndefined();
		expect(await write("/repo/a.txt", "secretword")).toBeUndefined();
		expect(await bash('git commit -m "secretword"')).toBeUndefined();
		expect(await rules()).toMatch(/banned-words\s+on\s+2/);
	},
);

test(
	"banned-words follows links and the session cwd",
	{ options: { bannedWords: "secretword", bannedPaths: "/repo" } },
	async ($, on) => {
		const { bash, write } = await setup($, on);
		expect(
			await write("/home/me/.claude/skills/s/SKILL.md", "secretword"),
		).toContain("rule-guard banned-words");
		expect(await bash('git commit -m "add secretword"')).toContain(
			"rule-guard banned-words",
		);
		expect(await bash("gh issue create --title secretword")).toContain(
			"rule-guard banned-words",
		);
		expect(await bash("gh pr edit 3 --body secretword")).toContain(
			"rule-guard banned-words",
		);
		expect(await bash("echo secretword")).toBeUndefined();
		expect(await bash('git commit -m "clean"')).toBeUndefined();
	},
);

test("/rule-guard lists, toggles and explains the rules", async ($, on) => {
	const { bash, rules } = await setup($, on);
	const list = await rules();
	expect(list).toMatch(/^\nid\s+상태\s+차단\s+설명/);
	for (const id of [
		"no-pr-merge",
		"no-ai-trailer",
		"bun-over-npm",
		"rg-fd",
		"lint-before-commit",
		"banned-words",
	]) {
		expect(list).toContain(id);
	}
	expect(list).toMatch(/rg-fd\s+on\s+0\s+grep\/find 대신 rg\/fd/);

	expect(await bash("grep x y")).toBeDefined();
	expect(await rules()).toMatch(/rg-fd\s+on\s+1/);

	expect(await rules("off rg-fd")).toBe("rg-fd: 이 세션 동안 off");
	expect(await bash("grep x y")).toBeUndefined();
	expect(await rules()).toMatch(/rg-fd\s+off\s+1/);
	expect(await rules("on rg-fd")).toBe("rg-fd: 이 세션 동안 on");
	expect(await bash("grep x y")).toBeDefined();

	const bad = await rules("off nope");
	expect(bad).toContain("알 수 없는 룰 id: nope");
	expect(bad).toContain("no-pr-merge, no-ai-trailer");
	expect(await rules("off")).toContain("알 수 없는 룰 id: (없음)");

	const help = await rules("help");
	expect(help).toMatch(/^\n\/rule-guard\s/);
	expect(help).toContain("/rule-guard off <id>");
	expect(help).toContain("bannedWords, bannedPaths");
	expect(await rules("what")).toContain("알 수 없는 인자: what");
});

test("/rule-guard output colors status, counts and commands", async ($, on) => {
	const { bash, rules } = await setup($, on);
	await bash("grep x y");
	await rules("off bun-over-npm");
	for (const surface of ["terminal", "desktop"] as const) {
		const ui = await $.ui.mount({
			plugin: "rule-guard",
			surface,
			component: "CommandOutput",
			props: {
				command: "rule-guard",
				args: "",
				text: `${await rules()}\n${await rules("help")}`,
				isErrored: false,
			},
		});
		const props = async (text: RegExp) =>
			(await ui.find({ type: "Text", text }))?.props;
		expect(await props(/^rg-fd$/)).toMatchObject({ color: "suggestion" });
		expect(await props(/^on$/)).toMatchObject({ color: "success" });
		expect(await props(/^off$/)).toMatchObject({ color: "warning" });
		expect(await props(/^설정 안 됨$/)).toMatchObject({ color: "inactive" });
		expect(await props(/^1$/)).toMatchObject({ color: "error" });
		expect(await props(/^\/rule-guard help$/)).toMatchObject({
			color: "suggestion",
		});
		await ui.unmount();
	}
});

test("/rule-guard is registered with a help hint", async ($, on) => {
	const { specs } = await setup($, on);
	expect(specs[0]?.description).toMatch(/· help: 사용법$/);
	expect(specs[0]?.argumentHint).toBe("[off <id> | on <id> | help]");
});

test("shell drops quoted text and heredoc bodies", () => {
	expect(shell(`echo 'a; npm' "b; grep" && ls`)).toBe(`echo '' "" && ls`);
	expect(shell(`echo "$(grep x)"`)).toBe(`echo "$(grep x)"`);
	expect(shell(heredoc("subject\n\nnpm and grep"))).not.toMatch(/npm|grep/);
});
