---
description: Start an agent team for parallel collaborative work
allowed-tools: Agent, Bash(tmux:*), TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, TeamCreate, TeamDelete
---

## Agent Team Mode

Create an agent team to work on the given task in parallel.

Input: $ARGUMENTS

Steps:

1. **TeamCreate** 도구로 팀을 먼저 생성한다 (team_name 지정)
2. Analyze the task and determine optimal team composition (3-5 teammates)
3. **TaskCreate** 로 각 teammate 에게 할당할 작업을 생성한다
4. **Agent** 도구로 teammate 를 생성한다. 반드시 `team_name` 과 `name` 파라미터를 지정해야 tmux pane 에 표시된다
5. **TaskUpdate** 로 각 task 의 owner 를 teammate name 으로 할당한다
6. teammate 의 메시지는 자동으로 전달되므로 진행 상황을 모니터링한다
7. 모든 작업 완료 후 **SendMessage** (type: "shutdown_request") 로 teammate 를 종료한다

Guidelines:

- Each teammate should have a focused role (e.g., security reviewer, performance analyzer, test writer)
- Provide sufficient context to each teammate since they don't inherit conversation history
- Ensure teammates work on different files to avoid conflicts
- Report consolidated findings when all teammates complete their work

Important:

- TeamCreate 없이 Agent 만 사용하면 in-process 로 실행되어 tmux pane 이 생성되지 않는다
- Agent 도구의 `team_name` 파라미터가 TeamCreate 에서 만든 team_name 과 일치해야 한다
- teammate 는 idle 상태가 정상이며, SendMessage 로 메시지를 보내면 깨어난다
