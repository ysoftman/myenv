import type { EngineInterface } from "claude-code";
import type { PullRequest } from "../types";

const QUERY = `query($owner: String!, $name: String!, $branch: String!) {
  viewer { login }
  repository(owner: $owner, name: $name) {
    pullRequests(headRefName: $branch, states: [OPEN], first: 5, orderBy: {field: CREATED_AT, direction: DESC}) {
      nodes {
        number url isDraft reviewDecision isCrossRepository
        headRepositoryOwner { login }
        latestReviews(first: 20) { nodes { state } }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
        reviewThreads(first: 100) { nodes { isResolved } }
      }
    }
  }
}`;

type Node = {
	number: number;
	url: string;
	isDraft: boolean;
	reviewDecision: string | null;
	isCrossRepository: boolean;
	headRepositoryOwner: { login: string } | null;
	latestReviews: { nodes: { state: string }[] };
	commits: {
		nodes: { commit: { statusCheckRollup: { state: string } | null } }[];
	};
	reviewThreads: { nodes: { isResolved: boolean }[] };
};

type Reply = {
	data?: {
		viewer?: { login: string };
		repository?: { pullRequests: { nodes: Node[] } } | null;
	};
};

const CI: Record<string, PullRequest["ci"]> = {
	SUCCESS: "success",
	FAILURE: "failure",
	ERROR: "failure",
	PENDING: "pending",
	EXPECTED: "pending",
};

// gh picks the repository the same way: upstream, github, then origin
const REMOTES = ["upstream", "github", "origin"];

export const remoteRepo = (config: string) => {
	const urls = new Map(
		config
			.split("\n")
			.map((l) => /^remote\.(.+)\.url (.+)$/.exec(l))
			.filter((m) => m !== null)
			.map((m) => [m[1], m[2]] as const),
	);
	const url = [...REMOTES.map((r) => urls.get(r)), ...urls.values()].find(
		(u) => u !== undefined,
	);
	const m =
		/^(?:[\w+.-]+:\/\/)?(?:[^@/]+@)?([^/:]+)(?::\d+)?[:/]([^/]+)\/([^/]+?)(?:\.git)?\/?$/.exec(
			url ?? "",
		);
	if (m === null) {
		return undefined;
	}
	const [, host = "", owner = "", name = ""] = m;
	return { host, owner, name };
};

// a fork's PR with the same branch name is someone else's, unless it is ours
export const toPullRequest = (
	branch: string,
	stdout: string,
): PullRequest | null => {
	const { data } = JSON.parse(stdout) as Reply;
	const me = data?.viewer?.login;
	const pr = data?.repository?.pullRequests.nodes.find(
		(n) => !n.isCrossRepository || n.headRepositoryOwner?.login === me,
	);
	if (pr === undefined) {
		return null;
	}
	const reviews = pr.latestReviews.nodes.map((r) => r.state);
	const decision =
		pr.reviewDecision ??
		(reviews.includes("CHANGES_REQUESTED")
			? "CHANGES_REQUESTED"
			: reviews.includes("APPROVED")
				? "APPROVED"
				: undefined);
	const ci = CI[pr.commits.nodes[0]?.commit.statusCheckRollup?.state ?? ""];
	return {
		branch,
		number: pr.number,
		url: pr.url,
		isDraft: pr.isDraft,
		review:
			decision === "APPROVED"
				? "approved"
				: decision === "CHANGES_REQUESTED"
					? "changes"
					: "pending",
		...(ci === undefined ? {} : { ci }),
		unresolved: pr.reviewThreads.nodes.filter((t) => !t.isResolved).length,
	};
};

export const isMergeable = (pr: PullRequest) =>
	pr.review === "approved" &&
	!pr.isDraft &&
	(pr.ci === undefined || pr.ci === "success");

export async function readPullRequest(
	$: EngineInterface,
	root: string,
	branch: string,
) {
	const config = await $.process
		.run(["git", "-C", root, "config", "--get-regexp", "^remote\\..*\\.url$"], {
			timeoutMs: 5_000,
		})
		.catch(() => undefined);
	const repo = remoteRepo(config?.exitCode === 0 ? config.stdout : "");
	if (repo === undefined) {
		return null;
	}
	const run = await $.process
		.run(
			[
				"gh",
				"api",
				"graphql",
				"--hostname",
				repo.host,
				"-f",
				`owner=${repo.owner}`,
				"-f",
				`name=${repo.name}`,
				"-f",
				`branch=${branch}`,
				"-f",
				`query=${QUERY}`,
			],
			{ cwd: root, timeoutMs: 15_000 },
		)
		.catch(() => undefined);
	if (run?.exitCode !== 0) {
		return null;
	}
	try {
		return toPullRequest(branch, run.stdout);
	} catch {
		return null;
	}
}
