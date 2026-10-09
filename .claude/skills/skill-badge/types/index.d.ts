export type SkillBadge = string

declare module 'claude-code' {
  interface PluginState {
    'skill-badge': { badge: SkillBadge }
  }
}
