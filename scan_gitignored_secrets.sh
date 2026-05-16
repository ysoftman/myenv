#!/bin/bash

# ~/workspace 아래 git 저장소에서 .gitignore 로 무시된 파일의 secret 의심 항목을 요약한다.
# 실제 값은 출력하지 않고 파일/라인/매칭 수만 표시한다.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=colors.sh
source "$SCRIPT_DIR/colors.sh"

ROOT="${HOME}/workspace"
MAX_BYTES=$((2 * 1024 * 1024))
MAX_DEPTH=4

FILE_RE='\.(conf|config|env|json|ya?ml|toml|ini|properties|cfg)(\.[a-z0-9_-]+)*$|(^|/)\.?[a-z0-9_-]*env(rc)?$'
SKIP_RE='(^|/)(node_modules|vendor|target|dist|build|\.next|\.cache|tmp|logs?)(/|$)'

# SECRET_RE 는 아래 패턴들을 '|' 로 합쳐 만든다.
SECRET_PATTERNS=(
    # key=value 형태: key 토큰 + 구분자(:|=) + 6자 이상의 값
    '(token|secret|password|passwd|pwd|credential|api[._-]?key|access[._-]?key|secret[._-]?key|private[._-]?key|client[._-]?secret|authorization|bearer|session|cookie|webhook)[A-Za-z0-9_. -]{0,50}["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[^"'"'"'[:space:]#,}\]]{6,}'
    # GitHub 토큰: ghp_/gho_/ghu_/ghs_/ghr_/ghpat_
    'gh[pousr]_[A-Za-z0-9_]{20,}'
    'github_pat_[A-Za-z0-9_]{20,}'
    # GitLab personal access token
    'glpat-[A-Za-z0-9_-]{20,}'
    # Slack 토큰: xoxb-/xoxa-/xoxp-/xoxr-/xoxs-
    'xox[baprs]-[A-Za-z0-9-]{20,}'
    # AWS access key id (long-term / temp)
    'AKIA[0-9A-Z]{16}'
    'ASIA[0-9A-Z]{16}'
    # OpenAI 류 sk- 시크릿
    'sk-[A-Za-z0-9_-]{20,}'
    # PEM 시작 마커
    '-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----'
)
SECRET_RE=$(
    IFS='|'
    printf '%s' "${SECRET_PATTERNS[*]}"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--max-bytes N] [--max-depth N] [root]

Scan git repositories found under root(default: ~/workspace) for
secret-like values in files matched by .gitignore. Secret values
are never printed.

Options:
  --max-bytes N   skip files larger than N bytes (default: $MAX_BYTES)
  --max-depth N   max directory depth from root to find .git (default: $MAX_DEPTH)
  -h, --help      show this help

Examples:
  $(basename "$0")
  $(basename "$0") --max-depth 6 ~/workspace
EOF
}

require_value() {
    [[ -n ${2:-} && $2 != -* ]] || {
        printf 'error: %s requires a value\n\n' "$1" >&2
        usage >&2
        exit 2
    }
    [[ $2 =~ ^[0-9]+$ ]] || {
        printf 'error: %s requires a non-negative integer (got: %s)\n\n' "$1" "$2" >&2
        usage >&2
        exit 2
    }
}

# 위치 인자(root)가 이미 들어왔는지 추적. 2개 이상 들어오면 에러 처리.
ROOT_SET=0
while (($# > 0)); do
    case "$1" in
        -h | --help)
            usage
            exit 0
            ;;
        --max-bytes)
            require_value "$1" "${2:-}"
            MAX_BYTES=$2
            shift
            ;;
        --max-depth)
            require_value "$1" "${2:-}"
            MAX_DEPTH=$2
            shift
            ;;
        -*)
            printf 'error: unknown flag: %s\n\n' "$1" >&2
            usage >&2
            exit 2
            ;;
        *)
            if ((ROOT_SET)); then
                printf 'error: unexpected argument: %s\n\n' "$1" >&2
                usage >&2
                exit 2
            fi
            ROOT=$1
            ROOT_SET=1
            ;;
    esac
    shift
done

ROOT=${ROOT/#\~/$HOME}
[[ -d $ROOT ]] || {
    printf 'error: root path does not exist: %s\n\n' "$ROOT" >&2
    usage >&2
    exit 2
}

command -v git >/dev/null 2>&1 || {
    echo "error: git is required" >&2
    exit 1
}
command -v fd >/dev/null 2>&1 || {
    echo "error: fd is required" >&2
    exit 1
}
command -v rg >/dev/null 2>&1 || {
    echo "error: rg is required" >&2
    exit 1
}

is_candidate_file() {
    local path=${1,,}
    [[ $path =~ $FILE_RE ]] || return 1
    [[ $path =~ $SKIP_RE ]] && return 1
    return 0
}

if [[ $OSTYPE == darwin* ]]; then
    file_size() { stat -f%z "$1"; }
else
    file_size() { stat -c%s "$1"; }
fi

find_repos() {
    # ROOT 아래 최대 MAX_DEPTH 까지의 .git 을 찾는다 (예: ~/workspace/<group>/<repo>/.git).
    fd -H -I --prune --max-depth "$MAX_DEPTH" '^\.git$' "$ROOT" \
        -E node_modules \
        -E vendor \
        -E target \
        -E dist \
        -E build |
        sed 's|/\.git/*$||' |
        sort -u
}

gitignored_files() {
    # --directory: 무시된 디렉터리는 내부를 열거하지 않고 디렉터리 한 줄로 출력.
    git -C "$1" ls-files --others --ignored --exclude-standard --directory -z 2>/dev/null
}

scan_file() {
    local repo=$1
    local file=$2
    local fullpath="${repo%/}/$file"
    local size
    local matches
    local count

    [[ -f $fullpath ]] || return
    is_candidate_file "$file" || return

    candidate_files=$((candidate_files + 1))
    size=$(file_size "$fullpath")
    if ((size > MAX_BYTES)); then
        skipped_large=$((skipped_large + 1))
        return
    fi

    matches=$(rg -nI --color=never --no-heading -i -e "$SECRET_RE" -- "$fullpath" 2>/dev/null)
    [[ -n $matches ]] || return

    count=$(printf '%s\n' "$matches" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')
    hit_files=$((hit_files + 1))
    hit_lines=$((hit_lines + count))
    HIT_PATHS+=("$fullpath:$count")

    if [[ $repo_printed -eq 0 ]]; then
        printf '\n[%s]\n' "$repo"
        repo_printed=1
        repos_with_hits=$((repos_with_hits + 1))
    fi

    printf '  - %b%s%b (%s match lines)\n' "$yellow" "$file" "$reset_color" "$count"

    while IFS= read -r line; do
        [[ -n $line ]] || continue
        printf '      line %s: matched secret pattern (content hidden)\n' "${line%%:*}"
    done <<<"$matches"
}

repo_count=0
repos_with_hits=0
candidate_files=0
hit_files=0
hit_lines=0
skipped_large=0
HIT_PATHS=()

print_green_msg ".gitignore 에 등록된 민감성 정보 파일을 스캔합니다..."
printf 'root: %s\n' "$ROOT"
printf 'scan: files matched by .gitignore\n'
printf 'max_bytes: %s\n' "$MAX_BYTES"

if [[ -t 2 ]]; then
    PROGRESS_TTY=1
else
    PROGRESS_TTY=0
fi

progress() {
    ((PROGRESS_TTY)) || return 0
    printf '\r\033[2K[%s/%s] scanning: %s' "$1" "$2" "$3" >&2
}

progress_clear() {
    ((PROGRESS_TTY)) || return 0
    printf '\r\033[2K' >&2
}

printf 'discovering repos...\n' >&2
mapfile -t REPOS < <(find_repos)
total_repos=${#REPOS[@]}
printf 'found %s repo(s)\n' "$total_repos" >&2

for repo in "${REPOS[@]}"; do
    [[ -n $repo ]] || continue
    repo_count=$((repo_count + 1))
    repo_printed=0
    progress "$repo_count" "$total_repos" "$repo"

    while IFS= read -r -d '' file; do
        scan_file "$repo" "$file"
    done < <(gitignored_files "$repo")
done
progress_clear

printf '\n== summary ==\n'
printf 'repos_scanned=%s repos_with_hits=%s candidate_files=%s hit_files=%s hit_lines=%s skipped_large=%s\n' \
    "$repo_count" "$repos_with_hits" "$candidate_files" "$hit_files" "$hit_lines" "$skipped_large"

if ((${#HIT_PATHS[@]} > 0)); then
    printf '\nhit files:\n'
    for entry in "${HIT_PATHS[@]}"; do
        path=${entry%:*}
        count=${entry##*:}
        printf '  - %b%s%b (%s match lines)\n' "$yellow" "$path" "$reset_color" "$count"
    done
fi
