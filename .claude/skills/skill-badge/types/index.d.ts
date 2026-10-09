export type SkillRun = {
  skills: string[]
  model: string
  effort?: string
  startedAt: number
  endedAt?: number
  result?: 'done' | 'failed' | 'aborted'
}

declare module 'claude-code' {
  interface PluginState {
    'skill-badge': { runs: SkillRun[]; model: string }
  }
}
