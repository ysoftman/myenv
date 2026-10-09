import type { AgentStatus, On } from 'claude-code'
import type { Engine } from 'claude-code/testing'
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

const spawn = (description: string, subagentType: string, extra: object = {}) =>
  ({
    tool_use_id: `tu-${description}`,
    prompt: 'do it',
    description,
    subagentType,
    provider: { plugin: 'engine', tier: 'core' },
    parentModel: 'claude-opus-5-5',
    background: true,
    fork: false,
    ...extra,
  }) as const

const setup = async ($: Engine, on: On) => {
  const clock = mock.clock(on, { now: 1_000_000 })
  const live: Record<string, AgentStatus> = {}
  let n = 0
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('agent.spawn', (_, e) => {
    const id = `a${++n}`
    if (e.workflow === undefined) {
      live[id] = 'running'
    }
    return {
      model: e.subagentType === 'reviewer' ? 'claude-sonnet-5-5' : 'claude-haiku-5-5',
      agentId: id,
    }
  })
  on('agent.list', () => ({
    value: Object.entries(live).map(([id, status]) => ({ id, status, description: '', type: '' })),
  }))
  on('tool.call', () => ({ result: 'ok' }))
  on('turn.complete', (_, e) => ({ text: e.answer }))
  on('prompt.submit', (_, e) => ({ text: e.text }))
  const writes: string[] = []
  on('state.set', (_, e, next) => {
    writes.push(e.key)
    return next(e)
  })
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  const shows = async (text: RegExp) => {
    const ui = await $.ui.mount({ plugin: 'agent-status', surface: 'terminal', ...BAND })
    const found = await ui.find({ text })
    await ui.unmount()
    return found !== undefined
  }
  return { clock, live, shows, writes }
}

test('tracks status, name, model and elapsed time per agent', async ($, on) => {
  const { clock, live, shows } = await setup($, on)
  await $.agent.spawn(spawn('PR 리뷰', 'reviewer'))
  await $.agent.spawn(spawn('오타 검사', 'typo-checker', { name: 'typo' }))
  // the engine's own call site carries agentId; the kit's $.tool.call types leave it out
  await $.tool.call({ tool: 'Read', file_path: '/x', agentId: 'a1' } as never)
  await clock.advance(42_000)
  live.a2 = 'completed'
  await clock.advance(23_000)

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'agent-status', surface, ...BAND })
    expect(await ui.find({ text: /^agents {2}● 1 running {2}✓ 1 done$/ })).toBeDefined()
    expect(await ui.find({ text: /● reviewer sonnet-5-5 +1m05s PR 리뷰 · Read/ })).toBeDefined()
    expect(await ui.find({ text: /✓ typo +haiku-5-5 +43s 오타 검사/ })).toBeDefined()
    const part = async (text: RegExp) => (await ui.find({ type: 'Text', text }))?.props
    expect(await part(/^sonnet-5-5 *$/)).toMatchObject({ color: 'suggestion', dimColor: false })
    expect(await part(/^haiku-5-5 *$/)).toMatchObject({ color: 'planMode', dimColor: true })
    expect(await part(/^reviewer *$/)).toMatchObject({ dimColor: false })
    expect(await part(/^typo *$/)).toMatchObject({ dimColor: true })
    await ui.unmount()
  }

  await $.prompt.submit({ text: 'done', wait: false, origin: { kind: 'task-notification' } })
  expect(await shows(/typo/)).toBe(true)

  await $.prompt.submit({ text: 'next', wait: false, origin: { kind: 'composer' } })
  expect(await shows(/typo/)).toBe(false)
  expect(await shows(/reviewer/)).toBe(true)
})

test('a workflow agent the engine never lists runs until its turn completes', async ($, on) => {
  const { clock, shows } = await setup($, on)
  await $.agent.spawn(
    spawn('워크플로', 'general-purpose', { workflow: { runId: 'wf_1', agentIndex: 1 } }),
  )
  await clock.advance(5_000)
  expect(await shows(/● general-purpose +haiku-5-5 +5s 워크플로/)).toBe(true)

  await $.turn.complete({
    answer: 'ok',
    durationMs: 5_000,
    isAborted: false,
    turnId: 't1',
    agentId: 'a1',
    reason: 'answer',
  })
  await clock.advance(3_000)
  expect(await shows(/✓ general-purpose +haiku-5-5 +5s 워크플로/)).toBe(true)
})

test('idle teammates, untracked and repeated tool calls write no state', async ($, on) => {
  const { clock, live, shows, writes } = await setup($, on)
  await $.agent.spawn(spawn('취약점 검사', 'vulnerability-package-checker'))
  await clock.advance(2_000)
  live.a1 = 'idle'
  await clock.advance(1_000)
  expect(await shows(/○ vulnerability-packa… haiku-5-5 +3s 취약점 검사/)).toBe(true)

  const before = writes.length
  await clock.advance(5_000)
  await $.tool.call({ tool: 'Read', file_path: '/x', agentId: 'zz' } as never)
  expect(writes.length).toBe(before)

  live.a1 = 'running'
  await $.tool.call({ tool: 'Read', file_path: '/x', agentId: 'a1' } as never)
  const afterFirst = writes.length
  await $.tool.call({ tool: 'Read', file_path: '/y', agentId: 'a1' } as never)
  expect(writes.length).toBe(afterFirst)
})

test('a stopped or vanished teammate keeps the time it worked', async ($, on) => {
  const { clock, live, shows } = await setup($, on)
  await $.agent.spawn(spawn('대기 후 종료', 'general-purpose', { name: 'idler' }))
  await $.agent.spawn(spawn('대기 후 사라짐', 'general-purpose', { name: 'scout' }))
  await $.tool.call({ tool: 'Read', file_path: '/x', agentId: 'a2' } as never)
  await $.tool.call({ tool: 'SubagentHandback', agentId: 'a2' } as never)
  expect(await shows(/● scout +haiku-5-5 +0s 대기 후 사라짐 · Read/)).toBe(true)

  await clock.advance(2_000)
  live.a1 = 'idle'
  live.a2 = 'idle'
  await clock.advance(31_000)
  await $.tool.call({ tool: 'TaskStop', task_id: 'idler' })
  delete live.a1
  delete live.a2
  await clock.advance(2_000)
  expect(await shows(/■ idler +haiku-5-5 +3s/)).toBe(true)
  expect(await shows(/✓ scout +haiku-5-5 +3s/)).toBe(true)
  expect(await shows(/^agents {2}✓ 1 done {2}■ 1 killed$/)).toBe(true)
})
