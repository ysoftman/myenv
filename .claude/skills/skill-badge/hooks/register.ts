import type { EngineInterface, Register, TurnStepInput } from 'claude-code'
import { atom, read, update } from 'claude-code'

import type { SkillBadge } from '../types'

const badge = atom({ plugin: 'skill-badge', key: 'badge' } as const, '')

const tagOf = (e: TurnStepInput) =>
  [e.model.replace(/^.*claude-/, ''), e.effort].filter(v => v !== undefined).join(' · ')

const show = async ($: EngineInterface, text: SkillBadge) => {
  if ((await read($, badge)) !== text) {
    await update($, badge, () => text)
  }
}

export const register: Register = on => {
  let loaded: string[] = []
  let tag = ''
  let done: { skills: string; tag: string } | undefined

  on('prompt.submit', async ($, e, next) => {
    if (e.turnId === undefined) {
      const name = /^\/([\w:.-]+)(?=\s|$)/.exec(e.text)?.[1]
      const isCommand = name !== undefined && (await $.command.list()).some(c => c.name === name)
      loaded = isCommand ? [name] : []
    }
    return next(e)
  })

  on('tool.call', { tool: 'Skill' }, (_, e, next) => {
    if (e.agentId === undefined) {
      loaded = [...new Set([...loaded, e.skill])]
    }
    return next(e)
  })

  on('turn.step', async function* ($, e, next) {
    if (e.agentId === undefined) {
      tag = tagOf(e)
      if (loaded.length > 0) {
        await show($, `▶ skill ${loaded.join(', ')} · ${tag}`)
      } else if (e.index === 0) {
        await show(
          $,
          done !== undefined && done.tag !== tag ? `↩ skill ${done.skills} ended · now ${tag}` : '',
        )
        done = undefined
      }
    }
    return yield* next(e)
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined && loaded.length > 0) {
      done = { skills: loaded.join(', '), tag }
      await show($, `✓ skill ${done.skills} · ${tag}`)
      loaded = []
    }
    return next(e)
  })

  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const text = await read($, badge)
    return next(text === '' ? e : { ...e, props: { ...e.props, modes: [...e.props.modes, text] } })
  })
}
