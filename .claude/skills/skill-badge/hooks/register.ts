import type { EngineInterface, Register, TurnCompleteReason } from 'claude-code'
import { atom, read, update } from 'claude-code'

import type { SkillRun } from '../types'

const runs = atom({ plugin: 'skill-badge', key: 'runs' } as const, [])
const model = atom({ plugin: 'skill-badge', key: 'model' } as const, '')

const KEEP = 8

const RESULT: Record<TurnCompleteReason, SkillRun['result']> = {
  answer: 'done',
  aborted: 'aborted',
  refusal: 'failed',
  error: 'failed',
}

const short = (m: string) => m.replace(/^.*claude-/, '')

const isOpen = (r: SkillRun | undefined) => r !== undefined && r.result === undefined

const patchOpen = async ($: EngineInterface, fn: (r: SkillRun) => SkillRun) => {
  const list = await read($, runs)
  const last = list.at(-1)
  if (last !== undefined && isOpen(last) && JSON.stringify(fn(last)) !== JSON.stringify(last)) {
    await update($, runs, l => [...l.slice(0, -1), fn(last)])
  }
}

export const register: Register = on => {
  let loaded: string[] = []

  on('prompt.submit', async ($, e, next) => {
    if (e.turnId === undefined) {
      const name = /^\/([\w:.-]+)(?=\s|$)/.exec(e.text)?.[1]
      const isCommand = name !== undefined && (await $.command.list()).some(c => c.name === name)
      loaded = isCommand ? [name] : []
    }
    return next(e)
  })

  on('tool.call', { tool: 'Skill' }, async (_, e, next) => {
    const ran = await next(e)
    if (e.agentId === undefined && ran.deny === undefined && ran.isError !== true) {
      loaded = [...new Set([...loaded, e.skill])]
    }
    return ran
  })

  on('turn.step', async function* ($, e, next) {
    if (e.agentId !== undefined) {
      return yield* next(e)
    }
    const effort = e.effort === undefined ? {} : { effort: String(e.effort) }
    if (loaded.length > 0) {
      const skills = loaded
      if (isOpen((await read($, runs)).at(-1))) {
        await patchOpen($, r => ({ ...r, skills }))
      } else {
        const run = { skills, model: short(e.model), ...effort, startedAt: await $.clock.now() }
        await update($, runs, l => [...l, run].slice(-KEEP))
      }
    }
    const step = yield* next(e)
    const answered = short(step.usage?.model ?? e.model)
    if (loaded.length > 0) {
      await patchOpen($, r => ({ ...r, model: answered }))
    }
    const tag = [answered, effort.effort].filter(v => v !== undefined).join(' · ')
    if ((await read($, model)) !== tag) {
      await update($, model, () => tag)
    }
    return step
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined && loaded.length > 0) {
      const endedAt = await $.clock.now()
      await patchOpen($, r => ({ ...r, endedAt, result: RESULT[e.reason] }))
      loaded = []
    }
    return next(e)
  })
}
