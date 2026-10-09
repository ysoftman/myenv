import type { On } from 'claude-code'
import type { Engine } from 'claude-code/testing'
import { expect, test } from 'claude-code/testing'

const COMMANDS = ['commit', 'team', 'clear'].map(name => ({
  name,
  description: '',
  source: 'user' as const,
}))

const setup = ($: Engine, on: On) => {
  const writes: unknown[] = []
  on('state.set', (_, e, next) => {
    writes.push(e.value)
    return next(e)
  })
  on('command.list', () => ({ value: COMMANDS }))
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
  on('turn.complete', (_, e) => ({ text: e.answer }))
  on('tool.call', { tool: 'Skill' }, (_, e) => ({
    result: { success: true, commandName: e.skill },
  }))
  on('ui.render', { component: 'SessionMode' }, ($$, e) => {
    const { Text } = $$.ui.resolve(e)
    return <Text>{e.props.modes.join(' & ')}</Text>
  })

  const type = (text: string) =>
    $.prompt.submit({ text, wait: false, origin: { kind: 'composer' } })
  const step = async (turnId: string, index: number, model: string, effort?: 'low' | 'max') => {
    for await (const _ of $.turn.step({ turnId, index, model, effort, messageCount: 1 })) {
    }
  }
  const complete = (turnId: string) =>
    $.turn.complete({ answer: '', durationMs: 1, isAborted: false, turnId, reason: 'answer' })
  const last = () => writes.at(-1)
  const footer = async () => {
    const ui = await $.ui.mount({
      plugin: 'skill-badge',
      surface: 'terminal',
      component: 'SessionMode',
      requestId: 'mode',
      props: { modes: ['Debug'] },
    })
    const text = (await ui.find({ type: 'Text' }))?.text
    await ui.unmount()
    return text
  }

  return { type, step, complete, last, writes, footer }
}

test('shows a typed skill turn in the footer, then flags the fallback model', async ($, on) => {
  const { type, step, complete, last, writes, footer } = setup($, on)

  await type('/commit')
  await step('t1', 0, 'claude-sonnet-5-5', 'low')
  await step('t1', 1, 'claude-sonnet-5-5', 'low')
  await step('t1', 2, 'claude-sonnet-5-5', 'low')
  expect(writes).toEqual(['▶ skill commit · sonnet-5-5 · low'])
  expect(await footer()).toBe('Debug & ▶ skill commit · sonnet-5-5 · low')
  await complete('t1')
  expect(last()).toBe('✓ skill commit · sonnet-5-5 · low')

  await type('ok')
  await step('t2', 0, 'claude-opus-5-5', 'max')
  expect(last()).toBe('↩ skill commit ended · now opus-5-5 · max')
  await complete('t2')
  await type('next')
  await step('t3', 0, 'claude-opus-5-5', 'max')
  expect(last()).toBe('')
  expect(await footer()).toBe('Debug')
})

test('clears quietly when the next turn keeps the same model', async ($, on) => {
  const { type, step, complete, last } = setup($, on)

  await type('/team split this')
  await step('t1', 0, 'claude-opus-5-5', 'max')
  await complete('t1')
  await type('ok')
  await step('t2', 0, 'claude-opus-5-5', 'max')
  expect(last()).toBe('')
})

test('paths and commands that start no turn are not skills', async ($, on) => {
  const { type, step, writes } = setup($, on)

  for (const text of ['/Users/ysoftman/x/README.md 읽어줘', '/tmp 정리해줘', '/clear']) {
    await type(text)
  }
  await type('hello')
  await step('t1', 0, 'claude-opus-5-5', 'max')
  await type('/tmp 정리해줘')
  await step('t2', 0, 'claude-opus-5-5', 'max')
  expect(writes).toEqual([])
})

test('shows a skill the main loop calls, not one a subagent calls', async ($, on) => {
  const { type, step, writes } = setup($, on)

  await type('lint this')
  await step('t1', 0, 'claude-opus-5-5', 'max')
  await $.tool.call({ tool: 'Skill', skill: 'lint-formatting', agentId: 'a1' } as never)
  await step('t1', 1, 'claude-opus-5-5', 'max')
  expect(writes).toEqual([])

  await $.tool.call({ tool: 'Skill', skill: 'commit' })
  await step('t1', 2, 'claude-sonnet-5-5', 'low')
  expect(writes).toEqual(['▶ skill commit · sonnet-5-5 · low'])
})
