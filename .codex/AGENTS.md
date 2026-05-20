# Global Instructions

Codex 공통 지침은 `~/.claude/CLAUDE.md`를 기준으로 따른다.

## Codex 적용 규칙

- 작업을 시작하기 전에 `~/.claude/CLAUDE.md`와 요청에 해당하는
  `~/.claude/skills/**/SKILL.md` 명세를 먼저 읽고, 그 명세의 도구/절차를 우선
  적용한다.
- `~/.claude/CLAUDE.md`의 "Claude Code" 명칭은 Codex 환경에서는 "Codex"로
  해석한다.
- PR, issue, 커밋 등 GitHub 액션에 Codex 사용 문구(예: "Generated with
  Codex")를 추가하지 않는다.
- Claude 전용 도구, 에이전트, 런타임 지침은 현재 Codex 런타임에서 사용 가능한
  동등 기능이 있을 때 적용한다.
- 현재 세션의 시스템/개발자 지침, 사용자 요청, 이 파일의 지침이 충돌하면 더
  높은 우선순위의 지침을 따른다.
