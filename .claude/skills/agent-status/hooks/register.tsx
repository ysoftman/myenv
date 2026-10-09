import type { AgentStatus, EngineInterface, Register } from 'claude-code'
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

const elapsed = (ms: number) => {
  const s = Math.max(0, Math.round(ms / 1000))
  return s < 60 ? `${s}s` : `${Math.floor(s / 60)}m${String(s % 60).padStart(2, '0')}s`
}

const patch = ($: EngineInterface, id: string, fn: (a: AgentRow) => AgentRow) =>
  update($, agents, list => list.map(a => (a.id === id ? fn(a) : a)))

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    $.clock.every(1000, async () => {
      const rows = await read($, agents)
      if (!rows.some(a => a.status === 'running' || a.status === 'idle')) {
        return
      }
      const t = await $.clock.now()
      const live = new Map((await $.agent.list()).map(a => [a.id, STATUS[a.status]]))
      await update($, agents, list =>
        list.map(a => {
          if (a.status !== 'running' && a.status !== 'idle') {
            return a
          }
          const status = live.get(a.id) ?? 'done'
          if (status === a.status) {
            return a
          }
          return status === 'running' ? { ...a, status } : { ...a, status, endedAt: t }
        }),
      )
      await update($, now, () => t)
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
      label: e.name ?? e.subagentType,
      model: ran.model.replace(/^.*claude-/, ''),
      description: e.description,
      startedAt: await $.clock.now(),
      status: 'running',
    }
    await update($, agents, list => [...list.filter(a => a.id !== row.id), row])
    await update($, now, () => row.startedAt)

    return ran
  })

  on('tool.call', async ($, e, next) => {
    if (e.agentId !== undefined) {
      await patch($, e.agentId, a => ({ ...a, status: 'running', tool: String(e.tool) }))
    }

    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.origin.kind === 'composer' || e.origin.kind === 'bridge') {
      await update($, agents, list =>
        list.filter(a => a.status === 'running' || a.status === 'idle'),
      )
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
