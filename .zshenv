# 모든 zsh 세션에서 항상 첫 번째로 로드(로그인/인터랙티브 여부 무관하게 항상 로드)
# .zshenv → .zprofile → .zshrc → .zlogin
. "$HOME/.cargo/env"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

