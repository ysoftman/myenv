---
description: Search and manage Jira issues
allowed-tools: mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__getJiraIssue, mcp__atlassian__createJiraIssue, mcp__atlassian__editJiraIssue, mcp__atlassian__addCommentToJiraIssue, mcp__atlassian__getTransitionsForJiraIssue, mcp__atlassian__transitionJiraIssue, mcp__atlassian__getVisibleJiraProjects, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__lookupJiraAccountId, mcp__atlassian__getJiraProjectIssueTypesMetadata
---

## Jira Command

Atlassian Jira 이슈를 조회, 생성, 수정한다.

- Cloud ID: `<your-cloud-id>`

Input: $ARGUMENTS

### 인자 파싱 규칙

첫 번째 인자가 대문자 프로젝트 키(예: PROJ, DUMMY, FOO)이면 해당 프로젝트를 대상으로 한다.
이슈 키(예: PROJ-1234)가 주어지면 프로젝트는 이슈 키에서 추출한다.
프로젝트를 지정하지 않으면 사용자에게 프로젝트를 물어본다.

### 사용 예시

- `/jira PROJ` — PROJ 프로젝트 최근 이슈 목록 (진행 중 우선)
- `/jira DUMMY` — DUMMY 프로젝트 최근 이슈 목록
- `/jira PROJ-1234` — 특정 이슈 상세 조회
- `/jira PROJ 내 이슈` — PROJ 프로젝트에서 나에게 할당된 이슈
- `/jira PROJ 생성 [제목]` — 새 이슈 생성 (상세 내용은 대화로 확인)
- `/jira PROJ 검색 [키워드]` — 키워드로 이슈 검색
- `/jira PROJ 상태변경 PROJ-1234 [상태]` — 이슈 상태 전환
- `/jira PROJ 댓글 PROJ-1234 [내용]` — 이슈에 댓글 추가

### 처리 규칙

1. 프로젝트만 지정하면 해당 프로젝트의 In Progress / In Test 이슈를 우선 표시한다
2. 이슈 키가 주어지면 해당 이슈 상세 정보를 조회한다
3. 이슈 생성 시 프로젝트, 이슈 유형, 제목, 설명을 사용자에게 확인한다
4. 결과는 테이블 형태로 간결하게 표시한다
5. JQL 쿼리를 직접 입력할 수도 있다 (예: `/jira project = PROJ AND status = "In Progress"`)
