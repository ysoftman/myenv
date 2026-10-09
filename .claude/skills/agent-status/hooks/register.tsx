import type {
  AgentStatus,
  EngineInterface,
  PluginState,
  Register,
  TurnCompleteReason,
} from 'claude-code'
import { atom, read, update } from 'claude-code'

import type { AgentRow } from '../types'

type SkillRun = PluginState['skill-badge']['runs'][number]

const agents = atom({ plugin: 'agent-status', key: 'agents' } as const, [])
const now = atom({ plugin: 'agent-status', key: 'now' } as const, 0)
const skillRuns = atom({ plugin: 'skill-badge', key: 'runs' } as const, [])
const mainModel = atom({ plugin: 'skill-badge', key: 'model' } as const, '')

const PANE = 'summary'
const TOGGLE_ACTION = 'app:toggleDiffPreSession'
const TOGGLE_KEY = 'ctrl+x s'

const C = {
  text: '#cdd6f4',
  subtext: '#a6adc8',
  overlay: '#7f849c',
  surface2: '#585b70',
  surface1: '#45475a',
  surface0: '#313244',
  mauve: '#cba6f7',
  pink: '#f5c2e7',
  lavender: '#b4befe',
  blue: '#89b4fa',
  sky: '#89dceb',
  teal: '#94e2d5',
  green: '#a6e3a1',
  yellow: '#f9e2af',
  peach: '#fab387',
  red: '#f38ba8',
}

const SPINNER = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
const SPARK = '✦✧✶✷✸✹✸✷✶✧'
const GLOW = [C.mauve, C.pink, C.lavender, C.blue, C.sky, C.blue, C.lavender, C.pink]

const ICON: Record<AgentRow['status'], string> = {
  running: '●',
  idle: '○',
  done: '✓',
  failed: '✗',
  killed: '■',
}
const COLOR: Record<AgentRow['status'], string> = {
  running: C.yellow,
  idle: C.overlay,
  done: C.green,
  failed: C.red,
  killed: C.red,
}
const RUN: Record<NonNullable<SkillRun['result']>, { icon: string; color: string }> = {
  done: { icon: '✓', color: C.green },
  failed: { icon: '✗', color: C.red },
  aborted: { icon: '■', color: C.overlay },
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

const ORDER: AgentRow['status'][] = ['running', 'idle', 'done', 'failed', 'killed']

const modelColor = (model: string) =>
  model.startsWith('opus') ? C.peach : model.startsWith('haiku') ? C.teal : C.blue

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

const isPaneOpen = async ($: EngineInterface) => (await $.ui.panes()).some(p => p.id === PANE)

const toggle = async ($: EngineInterface) => {
  if (await isPaneOpen($)) {
    await $.ui.close({ id: PANE })
  } else {
    await $.ui.open({ id: PANE, title: 'summary', columns: 60 })
  }
}

const isBusy = (list: AgentRow[], runs: SkillRun[]) =>
  list.some(a => a.status === 'running') || (runs.length > 0 && runs.at(-1)?.result === undefined)

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    $.clock.every(100, async () => {
      if (isBusy(await read($, agents), await read($, skillRuns)) && (await isPaneOpen($))) {
        $.ui.invalidate('ui.render')
      }
    })
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

  on('turn.step', async function* ($, e, next) {
    const id = e.agentId
    if (id !== undefined && !(await read($, agents)).some(a => a.id === id)) {
      const info = (await $.agent.list()).find(a => a.id === id)
      if (info !== undefined) {
        const row: AgentRow = {
          id,
          label: clip(info.name ?? info.type),
          model: e.model.replace(/^.*claude-/, ''),
          description: info.description,
          startedAt: await $.clock.now(),
          status: 'running',
          listed: true,
          ...(info.name === undefined ? {} : { name: info.name }),
        }
        await update($, agents, list => (list.some(a => a.id === id) ? list : [...list, row]))
        await update($, now, () => row.startedAt)
      }
    }

    return yield* next(e)
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
    if (e.props.hasSurvey) {
      return next(e)
    }
    const below = await next(e)
    const { Box, Button, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        <Button plain key="toggle" action={TOGGLE_ACTION} onPress={() => toggle($)}>
          <Text backgroundColor={C.surface0} color={C.lavender}>{` ${TOGGLE_KEY} `}</Text>
          <Text color={C.overlay}> summary</Text>
        </Button>
        {below}
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Button, Text } = $.ui.resolve(e)
    const list = await read($, agents)
    const runs = await read($, skillRuns)
    const tag = await read($, mainModel)
    const t = await $.clock.now()
    const frame = Math.floor(t / 100)
    const spin = SPINNER[frame % SPINNER.length]
    const busy = isBusy(list, runs)
    const glow = busy ? (GLOW[frame % GLOW.length] ?? C.mauve) : C.mauve
    const width = Math.max(30, e.props.bodyColumns)
    const rule = width - 2
    const at = busy ? (frame % (rule + 6)) - 3 : -3
    const lit = [at, at + 3].map(n => Math.min(rule, Math.max(0, n))) as [number, number]
    const labelWidth = Math.max(0, ...list.map(a => a.label.length))
    const modelWidth = Math.max(0, ...list.map(a => a.model.length))
    const counts = ORDER.map(s => [s, list.filter(a => a.status === s).length] as const)
    const keycap = (k: string) => (
      <Text backgroundColor={C.surface0} color={C.lavender}>{` ${k} `}</Text>
    )

    return (
      <Box flexDirection="column" width={width}>
        <Box borderStyle="round" borderColor={glow} paddingX={1} justifyContent="space-between">
          <Text bold color={C.mauve}>
            <Text color={glow}>{busy ? SPARK[frame % SPARK.length] : '✦'}</Text> summary
          </Text>
          <Text color={modelColor(tag)}>{tag}</Text>
        </Box>
        <Box paddingX={1}>
          <Text>
            <Text color={C.surface0}>{'━'.repeat(lit[0])}</Text>
            <Text color={C.lavender}>{'━'.repeat(lit[1] - lit[0])}</Text>
            <Text color={C.surface0}>{'━'.repeat(rule - lit[1])}</Text>
          </Text>
        </Box>
        <Box flexDirection="column" borderStyle="round" borderColor={C.surface1} paddingX={1}>
          <Text bold color={C.blue}>
            skills
          </Text>
          {runs.length === 0 ? (
            <Text color={C.overlay}>no skill yet</Text>
          ) : (
            [...runs].reverse().map(r => (
              <Text wrap="truncate-end">
                {r.result === undefined ? (
                  <Text color={C.peach}>{spin}</Text>
                ) : (
                  <Text color={RUN[r.result].color}>{RUN[r.result].icon}</Text>
                )}{' '}
                <Text
                  bold={r.result === undefined}
                  color={r.result === undefined ? C.text : C.subtext}
                >
                  {r.skills.join(', ')}
                </Text>{' '}
                <Text color={modelColor(r.model)}>
                  {[r.model, r.effort].filter(v => v !== undefined).join(' · ')}
                </Text>{' '}
                <Text color={C.overlay}>{elapsed((r.endedAt ?? t) - r.startedAt)}</Text>
              </Text>
            ))
          )}
        </Box>
        <Box flexDirection="column" borderStyle="round" borderColor={C.surface1} paddingX={1}>
          <Text>
            <Text bold color={C.mauve}>
              agents
            </Text>
            {counts
              .filter(([, n]) => n > 0)
              .map(([s, n]) => (
                <Text color={COLOR[s]}>{`  ${ICON[s]} ${n} ${s}`}</Text>
              ))}
          </Text>
          {list.length === 0 && <Text color={C.overlay}>no agent running</Text>}
          {list.map(a => (
            <Text wrap="truncate-end">
              <Text color={COLOR[a.status]}>{a.status === 'running' ? spin : ICON[a.status]}</Text>{' '}
              <Text color={C.text} dimColor={a.status !== 'running'}>
                {a.label.padEnd(labelWidth)}
              </Text>{' '}
              <Text color={modelColor(a.model)} dimColor={a.status !== 'running'}>
                {a.model.padEnd(modelWidth)}
              </Text>{' '}
              <Text color={C.overlay} dimColor={a.status !== 'running'}>
                {elapsed(end(a, t) - a.startedAt).padStart(6)}
              </Text>{' '}
              <Text color={C.subtext} dimColor>
                {a.description}
                {a.status === 'running' && a.tool !== undefined ? ` · ${a.tool}` : ''}
              </Text>
            </Text>
          ))}
        </Box>
        <Box paddingX={1} gap={2}>
          <Button plain key="toggle" action={TOGGLE_ACTION} onPress={() => toggle($)}>
            {keycap(TOGGLE_KEY)}
            <Text color={C.subtext}> close</Text>
          </Button>
          <Text>
            {keycap('ctrl+x tab')}
            <Text color={C.subtext}> focus</Text>
          </Text>
        </Box>
      </Box>
    )
  })
}
