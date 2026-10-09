import type { AgentStatus } from 'claude-code'
import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  component: 'AbovePrompt',
  requestId: 'band',
  props: {
    hasSurvey: false,
    isWorking: true,
    maxRows: 20,
    bodyColumns: 100,
    scroll: { offset: 0, bodyRows: 20 },
    view: {},
  },
} as const

const spawn = (description: string, subagentType: string, name?: string) =>
  ({
    tool_use_id: `tu-${description}`,
    prompt: 'do it',
    description,
    subagentType,
    provider: { plugin: 'engine', tier: 'core' },
    parentModel: 'claude-opus-5-5',
    background: true,
    fork: false,
    name,
  }) as const

test('tracks status, name, model and elapsed time per agent', async ($, on) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  const live: Record<string, AgentStatus> = {}
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('agent.spawn', (_, e) => {
    const id = `a${Object.keys(live).length + 1}`
    live[id] = 'running'
    return {
      model: e.subagentType === 'reviewer' ? 'claude-sonnet-5-5' : 'claude-haiku-5-5',
      agentId: id,
    }
  })
  on('agent.list', () => ({
    value: Object.entries(live).map(([id, status]) => ({ id, status, description: '', type: '' })),
  }))
  on('tool.call', () => ({ result: 'ok' }))
  on('prompt.submit', (_, e) => ({ text: e.text }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await $.agent.spawn(spawn('PR 리뷰', 'reviewer'))
  await $.agent.spawn(spawn('오타 검사', 'typo-checker', 'typo'))
  // the engine's own call site carries agentId; the kit's $.tool.call types leave it out
  await $.tool.call({ tool: 'Read', file_path: '/x', agentId: 'a1' } as never)
  await clock.advance(42_000)
  live.a2 = 'completed'
  await clock.advance(23_000)

  const shows = async (text: RegExp) => {
    const ui = await $.ui.mount({ plugin: 'agent-status', surface: 'terminal', ...BAND })
    const found = await ui.find({ text })
    await ui.unmount()
    return found !== undefined
  }

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'agent-status', surface, ...BAND })
    expect(await ui.find({ text: /agents 1 running \/ 2/ })).toBeDefined()
    expect(await ui.find({ text: /● reviewer sonnet-5-5 +1m05s PR 리뷰 · Read/ })).toBeDefined()
    expect(await ui.find({ text: /✓ typo +haiku-5-5 +43s 오타 검사/ })).toBeDefined()
    await ui.unmount()
  }

  await $.prompt.submit({ text: 'done', wait: false, origin: { kind: 'task-notification' } })
  expect(await shows(/typo/)).toBe(true)

  await $.prompt.submit({ text: 'next', wait: false, origin: { kind: 'composer' } })
  expect(await shows(/typo/)).toBe(false)
  expect(await shows(/reviewer/)).toBe(true)
})
