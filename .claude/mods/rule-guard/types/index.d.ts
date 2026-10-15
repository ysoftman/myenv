export type BlockCounts = Record<string, number>;

declare module "claude-code" {
	interface PluginState {
		"rule-guard": {
			off: string[];
			blocked: BlockCounts;
			pending: string[];
			chord: string;
			tabs: string;
			autoOpened: boolean;
		};
	}
}
