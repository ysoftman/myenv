import type { On } from "claude-code";
import type { Engine } from "claude-code/testing";
import { expect, mock, test } from "claude-code/testing";

const COMMANDS = ["commit", "team", "clear"].map((name) => ({
	name,
	description: "",
	source: "user" as const,
}));

const usage = (model: string) => ({
	input_tokens: 0,
	output_tokens: 0,
	cache_creation_input_tokens: 0,
	cache_read_input_tokens: 0,
	model,
});

const setup = ($: Engine, on: On) => {
	mock.clock(on, { now: 1_000_000 });
	const answered: Record<string, string> = {};
	const state: Record<string, unknown> = {};
	on("state.set", (_, e, next) => {
		state[e.key] = e.value;
		return next(e);
	});
	on("command.list", () => ({ value: COMMANDS }));
	on("prompt.submit", (_, e) => ({ text: e.text }));
	// biome-ignore lint/correctness/useYield: a streaming hook must be a generator; this one streams nothing
	on("turn.step", async function* (_, e) {
		return {
			turnId: e.turnId,
			index: e.index,
			answer: "",
			toolUses: [],
			stopReason: "end_turn",
			usage: usage(answered[e.turnId] ?? e.model),
		};
	});
	on("turn.complete", (_, e) => ({ text: e.answer }));
	on("tool.call", { tool: "Skill" }, (_, e) =>
		e.skill === "nope"
			? { deny: "no such skill" }
			: { result: { success: true, commandName: e.skill } },
	);

	const type = (text: string) =>
		$.prompt.submit({ text, wait: false, origin: { kind: "composer" } });
	const step = async (
		turnId: string,
		index: number,
		model: string,
		effort?: "low" | "max",
	) => {
		for await (const _ of $.turn.step({
			turnId,
			index,
			model,
			effort,
			messageCount: 1,
		})) {
		}
	};
	const complete = (turnId: string, reason: "answer" | "aborted" = "answer") =>
		$.turn.complete({
			answer: "",
			durationMs: 1,
			isAborted: reason === "aborted",
			turnId,
			reason,
		});
	const runs = async () => (state.runs ?? []) as { result?: string }[];
	const model = async () => state.model;

	return { answered, type, step, complete, runs, model };
};

test("records a typed skill turn with the model that answered, then closes it", async ($, on) => {
	const { answered, type, step, complete, runs, model } = setup($, on);

	answered.t1 = "claude-sonnet-5-5";
	await type("/commit");
	await step("t1", 0, "claude-opus-5-5", "low");
	await step("t1", 1, "claude-opus-5-5", "low");
	expect(await runs()).toMatchObject([
		{ skills: ["commit"], model: "sonnet-5-5", effort: "low" },
	]);
	expect((await runs())[0]?.result).toBeUndefined();
	expect(await model()).toBe("sonnet-5-5 · low");

	await complete("t1");
	expect(await runs()).toMatchObject([{ skills: ["commit"], result: "done" }]);

	await type("ok");
	await step("t2", 0, "claude-opus-5-5", "max");
	expect(await runs()).toHaveLength(1);
	expect(await model()).toBe("opus-5-5 · max");
});

test("an interrupted skill turn is not marked done", async ($, on) => {
	const { type, step, complete, runs } = setup($, on);

	await type("/team split this");
	await step("t1", 0, "claude-opus-5-5", "max");
	await complete("t1", "aborted");
	expect(await runs()).toMatchObject([{ skills: ["team"], result: "aborted" }]);
});

test("paths and commands that start no turn are not skills", async ($, on) => {
	const { type, step, runs } = setup($, on);

	for (const text of [
		"/Users/ysoftman/x/README.md 읽어줘",
		"/tmp 정리해줘",
		"/clear",
	]) {
		await type(text);
	}
	await type("hello");
	await step("t1", 0, "claude-opus-5-5", "max");
	await type("/tmp 정리해줘");
	await step("t2", 0, "claude-opus-5-5", "max");
	expect(await runs()).toEqual([]);
});

test("records a skill the main loop loads, not a subagent one or a denied one", async ($, on) => {
	const { type, step, runs } = setup($, on);

	await type("lint this");
	await step("t1", 0, "claude-opus-5-5", "max");
	await $.tool.call({
		tool: "Skill",
		skill: "lint-formatting",
		agentId: "a1",
	} as never);
	await $.tool.call({ tool: "Skill", skill: "nope" });
	await step("t1", 1, "claude-opus-5-5", "max");
	expect(await runs()).toEqual([]);

	await $.tool.call({ tool: "Skill", skill: "commit" });
	await step("t1", 2, "claude-sonnet-5-5", "low");
	expect(await runs()).toMatchObject([
		{ skills: ["commit"], model: "sonnet-5-5", effort: "low" },
	]);
});
