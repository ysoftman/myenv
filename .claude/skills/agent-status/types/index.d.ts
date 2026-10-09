export type AgentRow = {
  id: string
  label: string
  model: string
  description: string
  startedAt: number
  endedAt?: number
  status: 'running' | 'idle' | 'done' | 'failed' | 'killed'
  tool?: string
}

declare module 'claude-code' {
  interface PluginState {
    'agent-status': { agents: AgentRow[]; now: number }
  }
}
