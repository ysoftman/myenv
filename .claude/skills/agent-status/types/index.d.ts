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

export type WorkItem = {
  id: string
  at: number
  durationMs: number
  tokens?: number
  text?: string
  ask?: string
  answer?: string
}

export type FileTouch = {
  path: string
  edits: number
  status?: string
}

export type Alert = {
  at: number
  tool: string
  reason: string
  agent?: string
}

declare module 'claude-code' {
  interface PluginState {
    'agent-status': {
      agents: AgentRow[]
      now: number
      recent: WorkItem[]
      files: FileTouch[]
      dirty: number
      alerts: Alert[]
    }
  }
}
