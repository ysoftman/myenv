export type BlockCounts = Record<string, number>;

export type ModHooks = Record<string, { tier: string; events: string[] }>;

declare module "claude-code" {
	interface PluginState {
		"rule-guard": {
			off: string[];
			blocked: BlockCounts;
			hookRuns: BlockCounts;
			mods: ModHooks;
			pending: string[];
			chord: string;
			tabs: string;
			autoOpened: boolean;
		};
	}
}
