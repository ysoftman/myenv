---
name: team
description: Start an agent team (3-5 teammates) in tmux panes for parallel collaborative work. Use when tasks can be parallelized across multiple files or concerns like review, testing, refactoring, or analysis. Also trigger when the user asks to work on multiple things at once, speed up a large task, or mentions "팀", "병렬", "parallel", "동시에", "나눠서".
allowed-tools: Agent, Bash(tmux:*), TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, TeamCreate
---

# Agent Team Mode

병렬 작업을 위한 에이전트 팀을 생성하고 관리한다.

Input: $ARGUMENTS

## 실행 절차

### 1. 작업 분석 및 분해

팀을 만들기 전에 작업을 어떻게 나눌지 먼저 결정한다. 잘못된 분해는 충돌과 재작업을 유발하므로 이 단계가 가장 중요하다.

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
- 인자가 비어있으면 사용자에게 어떤 작업을 병렬화할지 물어본다.

### 2. 기존 팀 확인 및 생성

기존 팀이 있으면 재사용한다. 없을 때만 **TeamCreate**로 새 팀을 생성한다 (team_name 지정).

### 3. 작업 생성 및 teammate 배정

각 teammate에 대해 순서대로:

1. **TaskCreate**로 작업을 생성한다
2. **Agent**로 teammate를 생성한다 — `team_name`과 `name` 파라미터를 반드시 지정해야 tmux pane에 표시된다
3. **TaskUpdate**로 task의 owner를 teammate name으로 할당한다

### 4. 모니터링 및 결과 통합

teammate의 메시지는 자동으로 전달된다. 모든 작업 완료 후 결과를 통합하여 사용자에게 보고한다.

## Teammate 프롬프트 작성법

teammate는 현재 대화 이력을 전혀 공유하지 않는다. 방금 합류한 동료에게 브리핑하듯 충분한 컨텍스트를 담아야 한다. 컨텍스트가 부족하면 teammate가 엉뚱한 방향으로 작업하거나 다시 질문하느라 시간을 낭비한다.

**포함할 내용:**

- **목표**: 무엇을 해야 하는지, 왜 하는지
- **범위**: 담당 파일/디렉토리 경로를 명시
- **제약사항**: 수정 금지 파일, 따라야 할 컨벤션
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
- teammate는 idle 상태가 정상이며, SendMessage로 메시지를 보내면 깨어난다
- pane은 종료하지 않는다. 사용자가 명시적으로 요청할 때만 shutdown_request를 사용한다
- 팀을 삭제하지 않는다. 재사용이 완전히 불가능한 경우에만 정리 후 새로 생성한다
