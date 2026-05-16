---
name: team
description: Start a temporary agent team in tmux panes for collaborative work, with at most 5 total agents including the main agent. Keep the main agent focused on user interaction, coordination, monitoring, and final integration while delegating independent work to teammates whenever feasible. Use proactively when a task can be split across independent files, modules, or concerns. Also trigger when the user asks to work on multiple things at once, speed up a large task, or mentions "팀", "병렬", "parallel", "동시에", "나눠서".
allowed-tools: Agent, Bash(tmux:*), TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, TeamCreate, TeamDelete
---

# Agent Team Mode

병렬 작업을 위한 에이전트 팀을 생성하고 관리한다.

Input: $ARGUMENTS

## 작업 방침

- 작업 시 가능한 한 team 모드(병렬 에이전트)를 우선 사용한다. 단일 파일 작은 수정 등 분해가 의미 없는 경우만 예외.
- 사용자가 "병렬", "팀", "동시에" 같은 표현을 쓰지 않아도 작업이 독립 subtask로
  나뉘면 team 모드 사용을 우선 검토한다.
- 단일 파일의 작은 수정, 즉시 처리하는 편이 빠른 질문/명령, 작업 간 의존성이
  강해 병렬화가 오히려 위험한 경우에는 team 모드를 사용하지 않는다.
- 사용자가 "혼자 처리", "팀 쓰지 마", "서브에이전트 쓰지 마"처럼 team 모드
  비사용을 명시하면 그 요청을 우선한다.
- team 모드는 기본적으로 현재 top-level 사용자 요청에만 살아 있는 임시 팀이다.
  요청의 running/queued subtask가 모두 끝나면 idle teammate와 pane을 종료하고
  TeamDelete로 정리한다.
- 사용자가 "팀 유지", "keep alive", "persistent team", "다음 작업에도 재사용"처럼
  명시한 경우에만 요청 종료 후 팀을 유지한다.
- 메인 에이전트를 포함해 유지하거나 동시에 활동하는 에이전트는 최대 5개로 제한한다.
  즉 teammate는 최대 4명까지만 사용한다.
- team 모드를 사용하면 메인 에이전트의 기본 역할은 사용자 응답, 조율, 모니터링,
  최종 통합이다. 사용자의 추가 질문을 계속 받을 수 있도록 독립 subtask는 가능한
  한 teammate에게 위임한다.
- 메인 에이전트는 즉시 처리하는 편이 빠른 작은 작업, teammate 배정 전 필요한
  탐색, ownership 충돌이 없는 짧은 보조 작업, 최종 통합/검증, 사용자가 메인 직접
  처리를 요청한 경우에만 subtask를 직접 맡는다.
- 이미 teammate가 4명을 초과하면 새 teammate를 만들지 않는다. 이번 작업에는 최대
  4명만 선택하고, 초과 idle teammate는 정리한다.
- 이전 요청에서 남은 idle/stale 팀이나 pane이 있으면 새 작업에 재사용하지 말고
  진행 중 task가 없는지 확인한 뒤 먼저 정리한다. 진행 중 task가 있으면 사용자에게
  남은 작업을 보고하고 새 작업에 재배정하지 않는다.
- 현재 요청 안에서는 기존 idle teammate를 우선 재사용한다. 고정 슬롯 이름을
  유지하기보다 현재 작업 목적에 맞는 이름으로 변경해 사용한다.
- 런타임이 teammate 이름 변경을 지원하지 않으면 실제 이름은 유지하되, task owner,
  pane title, 브리프, 최종 보고에서 현재 목적/역할 이름이 명확히 드러나게 한다.

## 실행 절차

### 1. 작업 분석 및 분해

팀을 만들기 전에 작업을 어떻게 나눌지 먼저 결정한다. 잘못된 분해는 충돌과 재작업을 유발하므로 이 단계가 가장 중요하다.
사용자가 병렬 작업을 명시하지 않아도 독립 subtask로 나눌 수 있는지 먼저 판단한다.

**분해 전략:**

| 전략 | 적합한 상황 | 예시 |
|------|------------|------|
| 파일/모듈 기준 | 서로 다른 파일을 독립적으로 수정 | API 리팩토링 → routes, controllers, middleware 각각 |
| 관심사 기준 | 같은 코드를 다른 관점에서 분석 | 코드 리뷰 → security, performance, test-coverage |
| 파이프라인 기준 | 순차 단계를 병렬 준비 | 배포 준비 → lint 수정 + 테스트 작성 + 문서 업데이트 |

**핵심 원칙:**

- 각 teammate의 작업이 다른 teammate 결과에 의존하지 않도록 한다. 의존성이 있으면 순서를 정해 선행 작업 완료 후 후속 teammate에게 SendMessage로 결과를 전달한다.
- 같은 파일을 두 명 이상이 수정하면 git 충돌이 발생한다. 파일 소유권을 명확히 나눈다.
- 작업량을 균등하게 분배한다. 한 명이 파일 10개, 다른 한 명이 1개면 비효율적이다.
- 서로 다른 파일/모듈/관심사로 나눌 수 있는 작업은 team 모드 적용을 기본값으로
  한다.
- subtask 수가 많아도 이번 작업에 배정하는 teammate는 최대 4명으로 제한한다.
  나머지 subtask는 backlog에 두고, teammate가 끝나는 즉시 다음 독립 subtask를
  재배정한다. 메인 에이전트는 backlog를 직접 맡기보다 idle teammate 재배정과
  통합 판단을 우선한다.
- 인자가 비어있으면 사용자에게 어떤 작업을 병렬화할지 물어본다.

작업을 배정하기 전에 파일 소유권 표를 만든다. 표에는 최소한 `subtask`,
`teammate`, `edit scope`, `no-touch scope`, `done criteria`를 포함한다.
소유권이 겹치거나 불명확하면 teammate에게 배정하기 전에 메인 에이전트가 먼저
범위를 조정한다.
표에는 `status`와 `depends on`도 포함해 `queued`, `running`, `done`,
`blocked` 상태를 추적한다. `teammate`가 아직 정해지지 않은 항목은 backlog로
간주한다. 메인 에이전트가 직접 맡는 항목은 `teammate`를 `main`으로 표시하고,
직접 처리해야 하는 이유를 `done criteria`나 별도 메모에 남긴다.

### 2. 팀 생성 및 teammate 상태 점검

기본값은 요청 단위 임시 팀이다. 새 요청을 시작할 때 이전 요청에서 남은 팀이 있으면
**TaskList**, **TaskGet**, tmux pane 상태를 확인한다. running task가 없으면 먼저
**TeamDelete**로 정리하고 새 **TeamCreate**를 실행한다 (team_name 지정).
running task가 있으면 해당 teammate를 새 작업에 재사용하지 않고 사용자에게 남은
작업을 보고한다.

사용자가 명시적으로 팀 유지를 요청한 경우에만 기존 팀을 재사용한다. 이 경우에도
새 작업을 배정하기 전에 **TaskList**, **TaskGet**, tmux pane 상태를 확인해
teammate를 분류한다.

| 상태 | 기준 | 처리 |
|------|------|------|
| idle | 현재 요청 안에서 pane이 살아 있고 진행 중 task가 없거나 마지막 task가 완료됨 | backlog가 있으면 즉시 재사용, 없으면 정리 후보 |
| busy | task가 진행 중이거나 응답을 기다리는 중 | 재사용하지 않음 |
| failed | 직전 task가 실패했거나 오류 상태 | 원인 확인 전 재사용하지 않음 |
| stale | 상태가 오래되었거나 현재 작업 맥락과 맞는지 불명확함 | 재브리핑 후에만 재사용 |
| dead pane | pane이 죽었거나 접근 불가 | 재사용하지 않고 필요 시 정리 |

상태 표시는 가능하면 pane title과 task owner에 `[idle] name`, `[busy] name`,
`[failed] name`, `[stale] name` 형식으로 맞춘다. 런타임이 직접 상태 변경을
지원하지 않으면 최종 보고와 다음 배정 브리프에 같은 표기를 사용한다.

idle이 아닌 teammate에는 새 작업을 보내지 않는다. 단, stale teammate를 재사용해야
하면 이전 작업 맥락을 폐기하고 현재 브리프 기준으로 시작하라는 메시지를 먼저 보낸다.

### 3. 작업 생성 및 teammate 배정

각 subtask에 대해 순서대로:

1. **TaskCreate**로 작업을 생성한다
2. 기존 idle teammate가 있으면 우선 재사용한다
3. 재사용할 teammate는 현재 subtask 목적에 맞는 이름으로 변경한다. 이름 변경이
   지원되지 않으면 task owner/pane title/브리프에 현재 역할명을 반영한다
4. **SendMessage**로 새 작업 브리프를 전달한다. 이전 작업 컨텍스트에 의존하지
   말고 현재 브리프와 파일 상태를 기준으로 시작하라고 명시한다
5. idle teammate가 부족하거나 역할상 재사용이 부적절한 경우에만 **Agent**로 새
   teammate를 생성한다 — `team_name`과 `name` 파라미터를 반드시 지정해야 tmux
   pane에 표시된다
6. **TaskUpdate**로 task의 owner를 현재 작업 목적에 맞는 teammate name으로 할당한다

SendMessage 브리프는 아래 구조를 따른다.

```text
역할:
목표:
담당 범위:
수정 금지:
필수 사전 확인:
완료 조건:
이전 작업 맥락은 무시:
완료 보고 형식:
```

### 4. 연속 스케줄링

subtask가 teammate 한도보다 많으면 한 번에 teammate 4명 이하만 배정하고 나머지는
backlog에 둔다. batch 전체가 끝날 때까지 기다리지 않는다. teammate 하나가
완료될 때마다 변경 파일, 실패 여부, ownership 충돌 가능성만 짧게 확인한 뒤,
backlog에서 의존성이 없고 ownership이 겹치지 않는 다음 subtask를 즉시
SendMessage로 배정한다.

초기 teammate 배정이 끝나면 메인 에이전트는 장시간 구현에 들어가지 않고 사용자
응답, 진행 모니터링, backlog 재배정, 짧은 통합 작업을 수행한다. 메인은 아래
경우에만 subtask를 직접 맡는다.

- idle teammate가 없고, 대기 중인 작업이 작고 독립적이며 main이 처리해도 사용자
  응답성이 크게 떨어지지 않는 경우
- teammate 배정 전에 필요한 짧은 탐색이나 범위 정리가 필요한 경우
- 실패, 충돌, 의존성 변경 때문에 backlog를 재계획하거나 부분 통합해야 하는 경우
- 모든 running/queued subtask가 끝나 최종 통합이나 검증이 필요한 경우

작업 중에는 TaskList/TaskGet과 pane 상태를 주기적으로 확인해 idle teammate가
queued subtask 없이 놀지 않게 한다. idle teammate가 있고 queued subtask가 있는데
재배정하지 않는 것은 예외 상황으로 보고, 충돌/의존성/실패 같은 구체적 이유를
사용자에게 설명한다.

완료된 subtask 결과가 다음 subtask의 입력이 되는 경우에는 결과 요약과 변경 파일을
SendMessage에 포함한다. 충돌 위험이 있으면 후속 subtask를 시작하지 말고 메인
에이전트가 먼저 통합 판단을 한다.

### 5. 재사용 금지 조건

다음 조건에서는 idle로 보이더라도 teammate를 재사용하지 않는다.

- 직전 작업이 실패했거나, 실패 원인이 아직 정리되지 않은 경우
- 현재 작업과 전문 agent 성격이 크게 달라 이전 시스템/역할 지침이 방해될 수 있는 경우
- 보안 검토, 최종 리뷰처럼 독립 판단이 중요해 이전 맥락 오염이 위험한 경우
- 같은 파일 또는 같은 ownership 범위를 다른 teammate가 이미 수정 중인 경우
- top-level 사용자 요청이 바뀌었고 사용자가 명시적으로 팀 유지를 요청하지 않은 경우
- 사용자가 새 agent 사용, 단독 처리, 또는 team 모드 비사용을 명시한 경우
- pane이 죽었거나, 상태 확인 결과 dead/stale로 분류되고 재브리핑이 실패한 경우

### 6. 모니터링 및 결과 통합

teammate의 메시지는 자동으로 전달된다. teammate가 작업을 마치면 task를 완료
상태로 갱신하고, backlog에 배정 가능한 subtask가 있으면 즉시 같은 teammate에게
다음 브리프를 보낸다. 추가 배정할 subtask가 없을 때만 teammate를 idle 상태로
표시한다. 런타임이 idle 상태 표시를 직접 지원하지 않으면 pane title, task owner,
최종 보고 중 가능한 위치에 `idle`을 표시한다.

teammate는 작업 종료 시 아래 형식으로 보고해야 한다.

```text
상태: done / blocked / failed
변경 파일:
실행한 검증:
남은 리스크:
메인 통합 시 주의점:
```

모든 teammate 작업이 끝나면 메인 에이전트가 최종 통합을 담당한다. 최종 보고 전에
반드시 `git diff`/`git status`로 변경 범위를 확인하고, 파일 ownership 충돌,
중복 수정, 누락된 후속 작업, 실행한 검증 결과를 점검한다. 코드가 변경된 경우에는
관련 lint/format/test 결과 또는 실행하지 못한 이유를 함께 보고한다.

### 7. 팀 정리

기본값은 요청 종료 시 정리다. 현재 top-level 요청의 queued/running subtask가 모두
끝나면 진행 중인 task가 없는지 확인한 뒤 idle teammate와 pane을 종료하고
**TeamDelete**를 실행한다. 진행 중 작업이 있으면 종료하지 않고 대상 teammate와
남은 작업을 먼저 보고한다.

사용자가 "팀 유지", "keep alive", "persistent team", "다음 작업에도 재사용"처럼
명시한 경우에만 정리를 생략한다. 이 경우 최종 보고에 유지 중인 teammate와 idle
상태를 명확히 적고, 다음 요청에서 재사용 전 상태 점검을 다시 수행한다.

## Teammate 프롬프트 작성법

teammate는 현재 대화 이력을 전혀 공유하지 않는다. 방금 합류한 동료에게 브리핑하듯 충분한 컨텍스트를 담아야 한다. 컨텍스트가 부족하면 teammate가 엉뚱한 방향으로 작업하거나 다시 질문하느라 시간을 낭비한다.

**포함할 내용:**

- **목표**: 무엇을 해야 하는지, 왜 하는지
- **범위**: 담당 파일/디렉토리 경로를 명시
- **제약사항**: 수정 금지 파일, 따라야 할 컨벤션
- **필수 사전 확인**: 관련 CLAUDE/AGENTS/README/CONTRIBUTING, issue/PR/설계 문서,
  해당 skill 명세를 읽고 시작하라는 지시
- **완료 보고 형식**: `상태`, `변경 파일`, `실행한 검증`, `남은 리스크`,
  `메인 통합 시 주의점`
- **완료 조건**: 어떤 상태가 되면 작업 완료인지

**좋은 예시:**

```text
src/api/handlers/ 디렉토리의 Go 핸들러 에러 처리를 개선해줘.

배경: 현재 에러 시 500만 반환하고 로그가 없어 디버깅이 어렵다.
담당 범위: src/api/handlers/*.go 파일만
수정 금지: src/api/middleware/, src/api/routes.go
컨벤션: 에러 로깅은 slog 사용, HTTP 응답은 기존 errorResponse() 헬퍼 사용
완료 조건: 모든 핸들러에서 에러 시 적절한 로그와 HTTP 상태 코드 반환
```

## 팀 구성 패턴

### 코드 리뷰 (3명)

- **security-reviewer**: 보안 취약점 (injection, auth, secrets 노출)
- **quality-reviewer**: 코드 품질 (복잡도, 중복, 네이밍, 에러 처리)
- **test-reviewer**: 테스트 커버리지와 품질

### 리팩토링 (모듈 수에 따라)

각 teammate가 독립된 모듈/패키지를 담당한다. 모듈 간 인터페이스가 변경되는 경우, 인터페이스 정의를 먼저 합의한 뒤 각자 구현하도록 프롬프트에 인터페이스 명세를 포함한다.

### 기능 개발 (3-4명)

- **backend**: API/비즈니스 로직
- **frontend**: UI 컴포넌트
- **tester**: 테스트 작성
- **docs** (선택): 문서 업데이트

### 분석/조사 (2-3명)

각자 다른 관점에서 동일 코드베이스를 분석하고, 결과를 종합하여 보고한다.

## 문제 상황 대응

### teammate 작업 실패

SendMessage로 추가 컨텍스트를 제공하거나 작업 범위를 조정한다. 새 teammate를 만들지 말고 기존 teammate를 안내한다.

### 파일 충돌 발생

한 teammate의 작업을 먼저 완료시킨 후, 다른 teammate에게 변경된 상태를 SendMessage로 알려준다.

### 작업 간 의존성 발견

선행 작업이 완료되면 SendMessage로 후속 teammate에게 결과와 필요한 정보를 전달한다.

## 주의사항

- TeamCreate 없이 Agent만 사용하면 in-process로 실행되어 tmux pane이 생성되지 않는다
- Agent의 `team_name`이 TeamCreate의 team_name과 일치해야 한다
- teammate의 idle 상태는 현재 요청 안에서만 정상이다. 요청 종료 후에는 명시적
  keep-alive 요청이 없는 한 정리한다
- 팀 수명주기와 재사용 규칙은 `작업 방침`과 `팀 정리` 섹션 참고
