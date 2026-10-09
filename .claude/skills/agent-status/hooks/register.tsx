import type { AgentStatus, EngineInterface, Register, TurnCompleteReason } from 'claude-code'
import { atom, read, update } from 'claude-code'

import type { AgentRow } from '../types'

const agents = atom({ plugin: 'agent-status', key: 'agents' } as const, [])
const now = atom({ plugin: 'agent-status', key: 'now' } as const, 0)

const ICON: Record<AgentRow['status'], string> = {
  running: '●',
  idle: '○',
  done: '✓',
  failed: '✗',
  killed: '■',
}
const COLOR: Record<AgentRow['status'], string> = {
  running: 'warning',
  idle: 'inactive',
  done: 'success',
  failed: 'error',
  killed: 'error',
}

const STATUS: Record<AgentStatus, AgentRow['status']> = {
  pending: 'running',
  running: 'running',
  waiting: 'running',
  idle: 'idle',
  completed: 'done',
  failed: 'failed',
  killed: 'killed',
}
const TURN_END: Record<TurnCompleteReason, AgentRow['status']> = {
  answer: 'done',
  aborted: 'killed',
  refusal: 'failed',
  error: 'failed',
}

const LABEL_MAX = 20

const elapsed = (ms: number) => {
  const s = Math.max(0, Math.round(ms / 1000))
  return s < 60 ? `${s}s` : `${Math.floor(s / 60)}m${String(s % 60).padStart(2, '0')}s`
}

const clip = (s: string) => (s.length > LABEL_MAX ? `${s.slice(0, LABEL_MAX - 1)}…` : s)

const isLive = (a: AgentRow) => a.status === 'running' || a.status === 'idle'

const end = (a: AgentRow, t: number) => (a.status === 'running' ? t : (a.endedAt ?? t))

const sync = (a: AgentRow, live: AgentRow['status'] | undefined, t: number): AgentRow => {
  if (!isLive(a) || (live === undefined && !a.listed) || (live === a.status && a.listed)) {
    return a
  }
  const status = live ?? 'done'
  return { ...a, listed: true, status, ...(status === 'running' ? {} : { endedAt: end(a, t) }) }
}

const patch = async ($: EngineInterface, id: string, fn: (a: AgentRow) => AgentRow | undefined) => {
  if ((await read($, agents)).some(a => a.id === id && fn(a) !== undefined)) {
    await update($, agents, list => list.map(a => (a.id === id ? (fn(a) ?? a) : a)))
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    $.clock.every(1000, async () => {
      const rows = await read($, agents)
      if (!rows.some(isLive)) {
        return
      }
      const t = await $.clock.now()
      const live = new Map((await $.agent.list()).map(a => [a.id, STATUS[a.status]]))
      if (rows.some(a => sync(a, live.get(a.id), t) !== a)) {
        await update($, agents, list => list.map(a => sync(a, live.get(a.id), t)))
      }
      if ((await read($, agents)).some(a => a.status === 'running')) {
        await update($, now, () => t)
      }
    })

    return next(e)
  })

  on('agent.spawn', async ($, e, next) => {
    const ran = await next(e)
    if (ran.agentId === undefined) {
      return ran
    }
    const row: AgentRow = {
      id: ran.agentId,
      label: clip(e.name ?? e.subagentType),
      model: ran.model.replace(/^.*claude-/, ''),
      description: e.description,
      startedAt: await $.clock.now(),
      status: 'running',
      ...(e.name === undefined ? {} : { name: e.name }),
    }
    await update($, agents, list => [...list.filter(a => a.id !== row.id), row])
    await update($, now, () => row.startedAt)

    return ran
  })

  on('tool.call', async ($, e, next) => {
    const tool = String(e.tool)
    if (e.agentId === undefined || tool === 'SubagentHandback') {
      return next(e)
    }
    const [, ran] = await Promise.all([
      patch($, e.agentId, a =>
        a.status === 'running' && a.tool === tool ? undefined : { ...a, status: 'running', tool },
      ),
      next(e),
    ])

    return ran
  })

  on('tool.call', { tool: 'TaskStop' }, async ($, e, next) => {
    const ran = await next(e)
    const task = e.task_id ?? e.shell_id
    if (ran.deny !== undefined || ran.isError === true || task === undefined) {
      return ran
    }
    const t = await $.clock.now()
    const hit = (a: AgentRow) => a.status !== 'killed' && (a.id === task || a.name === task)
    if ((await read($, agents)).some(hit)) {
      await update($, agents, list =>
        list.map(a => (hit(a) ? { ...a, status: 'killed', endedAt: end(a, t) } : a)),
      )
    }

    return ran
  })

  on('turn.complete', async ($, e, next) => {
    const id = e.agentId
    if (id !== undefined && !(await $.agent.list()).some(a => a.id === id)) {
      const endedAt = await $.clock.now()
      await patch($, id, a =>
        isLive(a) && !a.listed ? { ...a, status: TURN_END[e.reason], endedAt } : undefined,
      )
    }

    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.origin.kind === 'composer' || e.origin.kind === 'bridge') {
      await update($, agents, list => list.filter(isLive))
    }

    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const list = await read($, agents)
    if (e.props.hasSurvey || list.length === 0) {
      return next(e)
    }
    const t = await read($, now)
    const { Box, Text } = $.ui.resolve(e)
    const labelWidth = Math.max(...list.map(a => a.label.length))
    const modelWidth = Math.max(...list.map(a => a.model.length))
    const running = list.filter(a => a.status === 'running').length

    return (
      <Box flexDirection="column">
        <Text dimColor>
          agents {running} running / {list.length}
        </Text>
        {list.map(a => (
          <Text wrap="truncate-end">
            <Text color={COLOR[a.status]}>{ICON[a.status]}</Text> {a.label.padEnd(labelWidth)}{' '}
            <Text color="suggestion">{a.model.padEnd(modelWidth)}</Text>{' '}
            {elapsed((a.status === 'running' ? t : (a.endedAt ?? t)) - a.startedAt).padStart(6)}{' '}
            <Text dimColor>
              {a.description}
              {a.status === 'running' && a.tool !== undefined ? ` · ${a.tool}` : ''}
            </Text>
          </Text>
        ))}
      </Box>
    )
  })
}
