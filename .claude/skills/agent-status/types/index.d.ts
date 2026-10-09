export type AgentRow = {
  id: string
  label: string
  name?: string
  model: string
  description: string
  startedAt: number
  endedAt?: number
  status: 'running' | 'idle' | 'done' | 'failed' | 'killed'
  tool?: string
  listed?: boolean
}

declare module 'claude-code' {
  interface PluginState {
    'agent-status': { agents: AgentRow[]; now: number }
  }
}
