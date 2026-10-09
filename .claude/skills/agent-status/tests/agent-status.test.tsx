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

const PANE = {
  component: 'Pane',
  requestId: 'summary',
  props: {
    title: 'summary',
    isFocused: false,
    bodyColumns: 100,
    placement: 'dock',
    scroll: { offset: 0, bodyRows: 40 },
    view: {},
  },
} as const

const SPIN = '[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]'

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
    value: Object.entries(live).map(([id, status]) => ({
      id,
      status,
      description: '',
      type: 'fork',
    })),
  }))
  on('tool.call', () => ({ result: 'ok' }))
  on('turn.complete', (_, e) => ({ text: e.answer }))
  on('prompt.submit', (_, e) => ({ text: e.text }))
  // biome-ignore lint/correctness/useYield: a streaming hook must be a generator; this one streams nothing
  on('turn.step', async function* (_, e) {
    return {
      turnId: e.turnId,
      index: e.index,
      answer: '',
      toolUses: [],
      stopReason: 'end_turn',
      usage: null,
    }
  })
  const skill: Record<string, unknown> = { runs: [], model: '' }
  let version = 0
  on('state.get', (_, e, next) =>
    e.plugin === 'skill-badge'
      ? { value: { value: skill[e.key] as never, version: ++version } }
      : next(e),
  )
  const panes: string[] = []
  on('ui.open', (_, e) => {
    panes.push(e.id)
    return { value: { isPlaced: true } }
  })
  on('ui.close', (_, e) => {
    panes.splice(panes.indexOf(e.id), 1)
    return { value: undefined }
  })
  on('ui.panes', () => ({
    value: panes.map(id => ({ id, title: id, isShown: true, isFocused: false, isPlaced: true })),
  }))
  on('ui.render', { component: 'AbovePrompt' }, ($$, e) => {
    const { Text } = $$.ui.resolve(e)
    return <Text>below</Text>
  })
  const writes: string[] = []
  on('state.set', (_, e, next) => {
    writes.push(e.key)
    return next(e)
  })
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  const shows = async (text: RegExp) => {
    const ui = await $.ui.mount({ plugin: 'agent-status', surface: 'terminal', ...PANE })
    const found = await ui.find({ text })
    await ui.unmount()
    return found !== undefined
  }
  return { clock, live, panes, skill, shows, writes }
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
    const ui = await $.ui.mount({ plugin: 'agent-status', surface, ...PANE })
    expect(await ui.find({ text: /^agents {2}● 1 running {2}✓ 1 done$/ })).toBeDefined()
    expect(
      await ui.find({ text: new RegExp(`${SPIN} reviewer sonnet-5-5 +1m05s PR 리뷰 · Read`) }),
    ).toBeDefined()
    expect(await ui.find({ text: /✓ typo +haiku-5-5 +43s 오타 검사/ })).toBeDefined()
    const part = async (text: RegExp) => (await ui.find({ type: 'Text', text }))?.props
    expect(await part(/^sonnet-5-5 *$/)).toMatchObject({ color: '#89b4fa', dimColor: false })
    expect(await part(/^haiku-5-5 *$/)).toMatchObject({ color: '#94e2d5', dimColor: true })
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
  expect(await shows(new RegExp(`${SPIN} general-purpose +haiku-5-5 +5s 워크플로`))).toBe(true)

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
  expect(await shows(new RegExp(`${SPIN} scout +haiku-5-5 +0s 대기 후 사라짐 · Read`))).toBe(true)

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

test('the band only offers the summary toggle and keeps the band beneath', async ($, on) => {
  const { panes } = await setup($, on)
  await $.agent.spawn(spawn('PR 리뷰', 'reviewer'))
  const ui = await $.ui.mount({ plugin: 'agent-status', surface: 'terminal', ...BAND })
  expect((await ui.find({ key: 'toggle' }))?.props).toMatchObject({
    action: 'app:toggleDiffPreSession',
  })
  expect(await ui.find({ text: /^below$/ })).toBeDefined()
  expect(await ui.find({ text: /reviewer/ })).toBeUndefined()

  await ui.press({ key: 'toggle' })
  expect(panes).toEqual(['summary'])
  await ui.press({ key: 'toggle' })
  expect(panes).toEqual([])
  await ui.unmount()
})

test('a forked skill the engine runs with no agent.spawn shows once it steps', async ($, on) => {
  const { clock, live, shows } = await setup($, on)
  live.f1 = 'running'
  for await (const _ of $.turn.step({
    turnId: 't1',
    index: 0,
    model: 'claude-opus-5-5',
    messageCount: 1,
    agentId: 'f1',
  })) {
  }
  expect(await shows(new RegExp(`${SPIN} fork +opus-5-5`))).toBe(true)

  live.f1 = 'completed'
  await clock.advance(2_000)
  expect(await shows(/✓ fork +opus-5-5 +1s/)).toBe(true)
})

test('the pane lists skill runs with the model each ran on', async ($, on) => {
  const { skill, shows } = await setup($, on)
  skill.runs = [
    {
      skills: ['jira'],
      model: 'sonnet-5-5',
      effort: 'low',
      startedAt: 977_000,
      endedAt: 1_000_000,
      result: 'done',
    },
    { skills: ['commit'], model: 'sonnet-5-5', effort: 'low', startedAt: 1_000_000 },
  ]
  skill.model = 'sonnet-5-5 · low'
  expect(await shows(new RegExp(`^${SPIN} commit sonnet-5-5 · low 0s$`))).toBe(true)
  expect(await shows(/^✓ jira sonnet-5-5 · low 23s$/)).toBe(true)
  expect(await shows(/^sonnet-5-5 · low$/)).toBe(true)
})

test('the shimmer sweeps a full cycle without breaking the pane', async ($, on) => {
  const { clock, shows } = await setup($, on)
  await $.agent.spawn(spawn('PR 리뷰', 'reviewer'))
  for (let i = 0; i < 110; i++) {
    await clock.advance(100)
    expect(await shows(/^━+$/)).toBe(true)
  }
})
