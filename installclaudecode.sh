#!/bin/bash
# ysoftman personal settings for claude code
# claude code 관련 개인 설정 및 설명입니다.

set -euo pipefail

# claude code 설치
echo "Claude Code를 설치합니다..."
curl -fsSL https://claude.ai/install.sh | bash

# Claude Code 기본 설정
# .claude/settings.json 은 더 이상 dotfiles 로 관리하지 않으므로 jq 로 항목을 직접 설정한다.
mkdir -p "${HOME}/.claude"
SETTINGS_FILE="${HOME}/.claude/settings.json"
STATUSLINE_CMD="bash -c 'cat | bash ${HOME}/.claude/statusline-command.sh 2>/dev/null'"
SPINNER_VERBS='{"mode": "replace", "verbs": ["⏳ Working", "🔄 Processing", "🏃 Running", "🌀 Crunching", "🚧 Building"]}'
PERMISSIONS_ALLOW='[
      "Bash(/bin/bash *)",
      "Bash(/usr/bin/ruby *)",
      "Bash(air *)",
      "Bash(awk *)",
      "Bash(basename *)",
      "Bash(bash *)",
      "Bash(biome *)",
      "Bash(brew *)",
      "Bash(bun *)",
      "Bash(bunx *)",
      "Bash(cargo *)",
      "Bash(cat *)",
      "Bash(cd *)",
      "Bash(claude *)",
      "Bash(colima list *)",
      "Bash(curl *)",
      "Bash(cut *)",
      "Bash(date *)",
      "Bash(diff *)",
      "Bash(dirname *)",
      "Bash(docker *)",
      "Bash(docker ps *)",
      "Bash(echo *)",
      "Bash(env *)",
      "Bash(export *)",
      "Bash(false)",
      "Bash(fd *)",
      "Bash(file *)",
      "Bash(find *)",
      "Bash(fzf *)",
      "Bash(fzf-tmux *)",
      "Bash(gh *)",
      "Bash(git *)",
      "Bash(go *)",
      "Bash(gofmt *)",
      "Bash(golangci-lint *)",
      "Bash(grep *)",
      "Bash(head *)",
      "Bash(ioreg *)",
      "Bash(jq *)",
      "Bash(kubectl *)",
      "Bash(launchctl list *)",
      "Bash(litellm *)",
      "Bash(ls *)",
      "Bash(make *)",
      "Bash(mkdir *)",
      "Bash(mv *)",
      "Bash(npm *)",
      "Bash(nvim *)",
      "Bash(open *)",
      "Bash(perl *)",
      "Bash(pip *)",
      "Bash(pip3 *)",
      "Bash(plutil *)",
      "Bash(printenv *)",
      "Bash(printf *)",
      "Bash(pwd)",
      "Bash(python *)",
      "Bash(python3 *)",
      "Bash(readlink *)",
      "Bash(realpath *)",
      "Bash(rg *)",
      "Bash(rm *)",
      "Bash(ruff *)",
      "Bash(rumdl *)",
      "Bash(rustfmt *)",
      "Bash(sed *)",
      "Bash(shfmt *)",
      "Bash(sleep *)",
      "Bash(sort *)",
      "Bash(source *)",
      "Bash(stat *)",
      "Bash(sudo *)",
      "Bash(sysctl *)",
      "Bash(tail *)",
      "Bash(taplo *)",
      "Bash(tar *)",
      "Bash(tee *)",
      "Bash(test *)",
      "Bash(tmux *)",
      "Bash(top *)",
      "Bash(touch *)",
      "Bash(tr *)",
      "Bash(true)",
      "Bash(uniq *)",
      "Bash(unzip *)",
      "Bash(uv *)",
      "Bash(vm_stat *)",
      "Bash(wc *)",
      "Bash(which *)",
      "Bash(xargs *)",
      "Bash(xxd *)",
      "Bash(zellij *)",
      "Bash(zip *)",
      "Bash(zsh *)",
      "Bash(~/.local/share/nvim/mason/bin/taplo *)",
      "Edit",
      "Glob",
      "Grep",
      "Read",
      "Read(//Users/ysoftman/.local/share/nvim/mason/packages/taplo/**)",
      "Read(//tmp/**)",
      "Skill",
      "WebFetch",
      "WebSearch",
      "Write",
      "mcp__atlassian__getAccessibleAtlassianResources",
      "mcp__atlassian__getVisibleJiraProjects",
      "mcp__atlassian__searchJiraIssuesUsingJql"
]'
if [[ -f "${SETTINGS_FILE}" ]] && jq -e --argjson allow "${PERMISSIONS_ALLOW}" --argjson spinner "${SPINNER_VERBS}" '
    .statusLine
    and .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
    and (.permissions.allow | type == "array")
    and (($allow - .permissions.allow) | length == 0)
    and (.spinnerVerbs == $spinner)
' "${SETTINGS_FILE}" &>/dev/null; then
    echo "Claude Code 설정이 이미 적용되어 있습니다. 스킵합니다."
else
    echo "Claude Code 설정을 적용합니다..."
    tmp=$(mktemp)
    if [[ -f "${SETTINGS_FILE}" ]]; then
        jq --arg cmd "${STATUSLINE_CMD}" --argjson allow "${PERMISSIONS_ALLOW}" --argjson spinner "${SPINNER_VERBS}" '
            .statusLine = {type: "command", command: $cmd}
            | .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
            | .permissions.allow = ((.permissions.allow // []) + $allow | unique)
            | .spinnerVerbs = $spinner
        ' "${SETTINGS_FILE}" >"${tmp}" && mv "${tmp}" "${SETTINGS_FILE}"
    else
        jq -n --arg cmd "${STATUSLINE_CMD}" --argjson allow "${PERMISSIONS_ALLOW}" --argjson spinner "${SPINNER_VERBS}" '{
            statusLine: {type: "command", command: $cmd},
            env: {CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"},
            permissions: {allow: $allow},
            spinnerVerbs: $spinner
        }' >"${SETTINGS_FILE}"
    fi
fi

# Atlassian mcp 설치
# 인증은 claude code > mcp > atlassian > 웹 로그인
if claude mcp list 2>&1 | grep -q "atlassian"; then
    echo "Atlassian MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
else
    echo "Atlassian MCP 서버를 설치합니다..."
    claude mcp add -s user --transport http atlassian https://mcp.atlassian.com/v1/mcp
    echo "완료. claude code > mcp > atlassian 에서 웹 로그인하세요."
fi

# Serena MCP 설치 (https://github.com/oraios/serena)
# 코드 심볼 검색/편집을 위한 의미론적 코딩 도구
# 시작 시 브라우저 탭 자동 열기 비활성화: ~/.serena/serena_config.yml 에서
# web_dashboard_open_on_launch: false 로 변경한다.
if claude mcp list 2>&1 | grep -q "serena"; then
    echo "Serena MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
else
    echo "Serena MCP 서버를 설치합니다..."
    claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant
fi

# Jenkins mcp 설치
# HTTP transport 로 직접 연결하면 사내 proxy/LB의 idle timeout(수십 초~수 분)으로 MCP 연결이 자주 끊긴다.
# mcp-remote를 로컬 stdio 프로세스로 중간에 두면 Claude Code↔mcp-remote 구간은 항상 연결된 상태를 유지한다.
# 실행 시 Jenkins URL, 사용자 ID, API Token 을 입력받는다.
# 토큰 입력 단계는 stty -echo 로 키 입력을 숨긴다 (bash/zsh 공통 — zsh 의 read -p 는 의미가 달라 호환되지 않는다).
# 중간의 Auth check 는 토큰 검증(200 이면 OK)이고, claude mcp remove ... 는 이전 HTTP 방식 등록이 있으면 정리한다.
if claude mcp list 2>&1 | grep -q "^jenkins-"; then
    echo "Jenkins MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
else
    printf 'Jenkins URL (예: https://ysoftman.test): '
    read -r JENKINS_URL
    JENKINS_URL="${JENKINS_URL%/}"
    printf 'Jenkins User ID: '
    read -r JENKINS_USER
    printf 'Jenkins API Token: '
    stty -echo
    read -r JENKINS_TOKEN
    stty echo
    echo
    TOKEN_B64=$(printf '%s' "${JENKINS_USER}:${JENKINS_TOKEN}" | base64)
    echo -n 'Auth check: '
    curl -s -o /dev/null -w "%{http_code}\n" -u "${JENKINS_USER}:${JENKINS_TOKEN}" "${JENKINS_URL}/me/api/json"
    JENKINS_HOST="${JENKINS_URL#*://}"
    JENKINS_MCP_NAME="jenkins-$(printf '%s' "${JENKINS_HOST}" | tr -c 'a-zA-Z0-9' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')"
    claude mcp add -s user "${JENKINS_MCP_NAME}" -- npx -y mcp-remote "${JENKINS_URL}/mcp-server/mcp" --header "Authorization: Basic ${TOKEN_B64}"
    unset JENKINS_URL JENKINS_HOST JENKINS_MCP_NAME JENKINS_USER JENKINS_TOKEN TOKEN_B64
fi

# marketplace 추가
# claude-plugins-official 은 기본 포함
USER_MARKETPLACES=(
    "backnotprop/plannotator"
    "anthropics/skills"
    "simple10/agents-observe"
    "nextlevelbuilder/ui-ux-pro-max-skill"
    "forrestchang/andrej-karpathy-skills"
)
for mp in "${USER_MARKETPLACES[@]}"; do
    mp_name="${mp##*/}"
    if claude plugin marketplace list 2>&1 | grep -q "${mp_name}"; then
        echo "Marketplace ${mp}이(가) 이미 설정되어 있습니다. 스킵합니다."
    else
        echo "Marketplace ${mp}을(를) 추가합니다..."
        claude plugin marketplace add "${mp}"
    fi
done

# 플러그인 설치 (user scope)
USER_PLUGINS=(
    "gopls-lsp@claude-plugins-official"
    "rust-analyzer-lsp@claude-plugins-official"
    "ralph-loop@claude-plugins-official"
    "plannotator@plannotator"
    "skill-creator@claude-plugins-official"
    "example-skills@anthropic-agent-skills"
    "agents-observe"
    "ui-ux-pro-max@ui-ux-pro-max-skill"
    "andrej-karpathy-skills@karpathy-skills"
)
for plugin in "${USER_PLUGINS[@]}"; do
    if claude plugins list 2>&1 | grep -q "${plugin%%@*}"; then
        echo "플러그인 ${plugin}이(가) 이미 설치되어 있습니다. 스킵합니다."
    else
        echo "플러그인 ${plugin}을(를) 설치합니다..."
        claude plugins install -s user "${plugin}"
    fi
done

# local LLM 연결해서 사용할 경우
# 환경변수 파일 생성
ENV_FILE=".local_llm_env_for_claude_code"
if [[ -f "${ENV_FILE}" ]]; then
    echo "로컬 LLM 환경변수 파일이 이미 존재합니다: ${ENV_FILE}. 스킵합니다."
else
    echo "로컬 LLM 환경변수 파일을 생성합니다: ${ENV_FILE}"
    cat >"${ENV_FILE}" <<'EOF'
# 로컬 llm URL
export ANTHROPIC_BASE_URL="http://localhost:8001"

# 더미값으로 설정하면 된다.(sk:SecretKey)
export ANTHROPIC_API_KEY="sk-dummy-key"

# Claude Code의 외부 통신을 최소화하기 위해 다음 환경변수도 설정하자.
# 텔레메트리(사용 통계 수집)를 비활성화
export CLAUDE_CODE_ENABLE_TELEMETRY=0

# 핵심 API 호출 외의 불필요한 네트워크 트래픽 차단
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# API 요청 시 Claude Code가 보내는 attribution 헤더(어떤 클라이언트에서 요청했는지 식별하는 정보)를 비활성화
export CLAUDE_CODE_ATTRIBUTION_HEADER=0
EOF
fi

# claude code 에서는 openAI api 호환이 되지 않아 중간에 litellm(proxy) 서버를 둬야 한다.
# litellm[proxy] 로 기본 + 프록시 실행에 필요한 추가 패키지들(backoff, uvicorn, fastapi 등)을 함께 설치
if python3 -c "import litellm" &>/dev/null; then
    echo "litellm이 이미 설치되어 있습니다. 스킵합니다."
else
    echo "litellm[proxy]를 설치합니다..."
    uv pip install 'litellm[proxy]' --system
fi

echo "모든 설치가 완료되었습니다."
echo ""
echo "로컬 LLM 사용 시:"
echo "  litellm --model qwen-coder3 --api_base http://localhost:11434/v1 --port 8001 &"
echo "  source ${ENV_FILE} && claude --model qwen3-coder"
