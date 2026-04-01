---
name: team
description: Start an agent team (3-5 teammates) in tmux panes for parallel collaborative work. Use when tasks can be parallelized across multiple files or concerns like review, testing, refactoring, or analysis.
allowed-tools: Agent, Bash(tmux:*), TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, TeamCreate
---

# Agent Team Mode

병렬 작업을 위한 에이전트 팀을 생성하고 관리한다.

Input: $ARGUMENTS

## 실행 절차

1. **기존 팀 확인**: 먼저 기존 팀이 있는지 확인한다. 있으면 해당 팀을 재사용한다. 재사용이 불가능한 경우에만 새로 생성한다.
2. 팀이 없으면 **TeamCreate** 도구로 팀을 생성한다 (team_name 지정).
3. 작업을 분석하여 최적의 팀 구성을 결정한다 (3-5명).
4. **TaskCreate** 로 각 teammate에게 할당할 작업을 생성한다.
5. **Agent** 도구로 teammate를 생성한다. 반드시 `team_name`과 `name` 파라미터를 지정해야 tmux pane에 표시된다.
6. **TaskUpdate** 로 각 task의 owner를 teammate name으로 할당한다.
7. teammate의 메시지는 자동으로 전달되므로 진행 상황을 모니터링한다.
8. 모든 작업 완료 후 결과를 통합하여 보고한다. pane은 유지한다.

## 가이드라인

- 각 teammate는 집중된 역할을 갖는다 (예: security reviewer, performance analyzer, test writer)
- teammate는 대화 이력을 공유하지 않으므로 충분한 컨텍스트를 제공한다
- 파일 충돌을 방지하기 위해 teammate가 서로 다른 파일을 작업하도록 한다
- 인자가 비어있으면 사용자에게 병렬화할 작업을 물어본다

## 주의사항

- TeamCreate 없이 Agent만 사용하면 in-process로 실행되어 tmux pane이 생성되지 않는다
- Agent 도구의 `team_name` 파라미터가 TeamCreate에서 만든 team_name과 일치해야 한다
- teammate는 idle 상태가 정상이며, SendMessage로 메시지를 보내면 깨어난다
- **pane은 종료하지 않는다.** 사용자가 명시적으로 종료를 요청할 때만 SendMessage (type: "shutdown_request")를 사용한다
- **팀을 삭제하지 않는다.** 재사용이 완전히 불가능한 경우에만 정리 후 새로 생성한다
