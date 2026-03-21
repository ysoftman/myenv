#!/bin/bash
# ysoftman personal settings for claude code
# claude code 관련 개인 설정 및 설명입니다.

set -euo pipefail

# claude code 설치
echo "Claude Code를 설치합니다..."
curl -fsSL https://claude.ai/install.sh | bash

# mcp 설치
# 인증은 claude code > mcp > atlassian > 웹 로그인
if claude mcp list 2>&1 | grep -q "atlassian"; then
    echo "Atlassian MCP 서버가 이미 설정되어 있습니다. 스킵합니다."
else
    echo "Atlassian MCP 서버를 설치합니다..."
    claude mcp add -s user --transport sse atlassian https://mcp.atlassian.com/v1/sse
    echo "완료. claude code > mcp > atlassian 에서 웹 로그인하세요."
fi

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
