#!/usr/bin/env python3

"""
AI 코딩 도구 사용량 조회
- 한도: codex / claude / agy 의 사용률, 리셋까지 남은 시간
- 사용량: opencode / crush 의 최근 N일 메시지·토큰·비용 (한도·리셋은 provider 쪽 정보라 로컬에서 알 수 없다)
색상은 터미널 출력일 때만 쓴다. NO_COLOR 로 끄고, CLICOLOR_FORCE=1 로 강제한다(watch -c, less -R 등).

- codex: 최근 세션 로그(~/.codex/sessions)의 rate_limits 스냅샷. 마지막 codex 실행 시점 값이라 다른 기기·웹 사용분이 빠질 수 있다.
  리셋 시각이 지난 창은 0% 로 보고, limit_id "premium" 처럼 창 정보가 없는 스냅샷은 건너뛴다.
- claude: `claude -p /usage` 실시간 조회 (로컬 명령이라 모델 호출 없음). 구조화된 출력이 없어 텍스트를 파싱한다.
  MCP 서버와 settings(hooks 포함)를 끄고 세션도 저장하지 않는다. --bare 는 OAuth 를 읽지 않아 구독 사용량이 안 나온다.
  세션을 저장하지 않아도 cwd 별 ~/.claude/projects/<cwd> 디렉토리를 만들어서 홈에서 실행한다.
- agy: `agy -p /usage` 실시간 조회 (모델 호출 없음). agy 1.2.2+ 는 내장 language server 에 CSRF 토큰을 강제해서 직접 호출할 수 없다.
  아직 안 쓴 bucket(남은 100%)의 reset_time 은 호출할 때마다 "지금 + 창 길이"라 표시하지 않는다.
- opencode / crush: 로컬 SQLite 를 읽기 전용으로 집계한다. MSGS 는 assistant 메시지 수다.
  crush 세션의 prompt/completion_tokens 는 누적값이 아니라 마지막 턴 값이라 토큰은 표시하지 않는다.
  crush 비용은 세션 누적값을 updated_at 기준으로 거른다(서브에이전트 비용은 부모 세션에 합산돼 있다).
"""

import argparse
import json
import os
import re
import sqlite3
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
from pathlib import Path

HOME = Path.home()
DATA_HOME = Path(os.environ.get("XDG_DATA_HOME") or HOME / ".local/share")
NOW = time.time()
COLOR = os.environ.get("CLICOLOR_FORCE", "0") != "0" or (sys.stdout.isatty() and not os.environ.get("NO_COLOR"))
TOOL_COLOR = {"codex": "38;5;80", "claude": "38;5;209", "agy": "38;5;75", "opencode": "38;5;105", "crush": "38;5;211"}
CLAUDE_LINE = re.compile(r"^Current (?P<name>.+): (?P<used>[\d.]+)% used(?: · resets (?P<at>.+) \()?", re.M)
# "Oct 13 at 2pm", "Jan 2, 2027 at 2:30pm"(올해와 다를 때만 연도), "Oct 13, 2pm"(node 로 실행될 때)
CLAUDE_AT = re.compile(r"^(?P<md>[A-Z][a-z]+ \d+)(?:, (?P<y>\d{4}))?(?:,| at) (?P<h>\d+)(?::(?P<m>\d+))?(?P<p>[ap]m)$")


# provider 출력 형식이 바뀌어도 나머지 행은 보여 주고, 에러는 spinner 를 지운 뒤 표 다음에 출력한다.
ERRORS = []


def safe(fn, *args):
    try:
        return fn(*args)
    except Exception as e:
        ERRORS.append(f"{fn.__name__}: {e!r}")
        return []


def run(cmd, cwd=None):
    """명령 stdout. 없는 명령이거나 60초를 넘기면 빈 문자열."""
    try:
        return subprocess.run(cmd, cwd=cwd, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=60).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def query(db, sql, *params):
    con = sqlite3.connect(Path(db).absolute().as_uri() + "?mode=ro", uri=True)
    try:
        return con.execute(sql, params).fetchone()
    finally:
        con.close()


def iso(s):
    # Python 3.9/3.10 fromisoformat 은 소수점 아래 3/6자리만 받아서 6자리로 맞춘다.
    s = re.sub(r"\.(\d+)", lambda m: "." + m[1][:6].ljust(6, "0"), s.replace("Z", "+00:00"))
    return datetime.fromisoformat(s).timestamp()


def codex_snapshot(f):
    """창 정보가 있는 마지막 rate_limits 스냅샷"""
    with f.open() as fp:
        snaps = [json.loads(line) for line in fp if '"rate_limits":{' in line]
    return next(
        (s for s in reversed(snaps) if (s["payload"]["rate_limits"].get("primary") or {}).get("window_minutes")), None
    )


def codex_rows():
    files = sorted((HOME / ".codex/sessions").glob("*/*/*/*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    snap = next(filter(None, map(codex_snapshot, files[:20])), None)
    if not snap:
        return []
    rows = []
    for w in (snap["payload"]["rate_limits"].get(k) for k in ("primary", "secondary")):
        if not w or not w.get("window_minutes"):
            continue
        m = w["window_minutes"]
        reset = w.get("resets_at")
        expired = reset is not None and reset < NOW  # 스냅샷 이후 창이 리셋됐다.
        rows.append(
            {
                "tool": "codex",
                "name": f"{m // 1440}d" if m >= 1440 else f"{m // 60}h",
                "used": 0 if expired else w["used_percent"],
                "reset": None if expired else reset,
                "asof": iso(snap["timestamp"]),
            }
        )
    return rows


def claude_reset(at):
    m = CLAUDE_AT.match(at)
    if not m:
        return None
    t = f"{m['y'] or datetime.now().year} {m['md']} {m['h']}:{m['m'] or '00'}{m['p']}"
    return datetime.strptime(t, "%Y %b %d %I:%M%p").timestamp()


# "Current week (all models): 76% used · resets Oct 13 at 2pm (Asia/Seoul)", resets_at 이 없으면 " · resets ..." 가 빠진다.
def claude_rows(text):
    return [
        {
            "tool": "claude",
            "name": m["name"],
            "used": float(m["used"]),
            "reset": m["at"] and claude_reset(m["at"]),
            "asof": None,
        }
        for m in CLAUDE_LINE.finditer(text)
    ]


def agy_rows(text):
    if not text:
        return []
    rows = []
    for g in json.loads(text)["command"]["data"]["groups"]:
        for b in g.get("buckets") or []:
            r = b.get("remaining_fraction", 0)  # 0 이면 필드가 빠진다(omitempty).
            reset = iso(b["reset_time"]) if r < 1 else None
            rows.append(
                {
                    "tool": "agy",
                    "name": f"{g['name']} {b.get('window', '')}",
                    "used": (1 - r) * 100,
                    "reset": reset,
                    "asof": None,
                }
            )
    return rows


def opencode_row(since):
    db = Path(os.environ.get("OPENCODE_DB") or DATA_HOME / "opencode/opencode.db")
    if not db.is_file():
        return []
    msgs, inp, out, cost, last = query(
        db,
        """SELECT COUNT(*),
            COALESCE(SUM(json_extract(data, '$.tokens.input')), 0),
            COALESCE(SUM(json_extract(data, '$.tokens.output')), 0),
            COALESCE(SUM(json_extract(data, '$.cost')), 0),
            (SELECT MAX(time_created) FROM message) / 1000
        FROM message WHERE time_created >= ? AND json_extract(data, '$.role') = 'assistant'""",
        since * 1000,
    )
    return [{"tool": "opencode", "msgs": msgs, "input": inp, "output": out, "cost": cost, "last": last}]


def crush_row(since):
    reg = Path(os.environ.get("CRUSH_GLOBAL_DATA") or DATA_HOME / "crush") / "projects.json"
    if not reg.is_file():
        return []
    msgs, cost, last = 0, 0.0, None
    for p in json.loads(reg.read_text())["projects"]:
        db = Path(p["path"]) / (p.get("data_dir") or ".crush") / "crush.db"  # data_dir 가 절대경로면 그대로 쓰인다.
        if not db.is_file():
            continue
        # 깨진 DB 하나 때문에 나머지 프로젝트 집계까지 버리지 않는다.
        try:
            m, c, t = query(
                db,
                """SELECT (SELECT COUNT(*) FROM messages WHERE role = 'assistant' AND created_at >= ?),
                    (SELECT TOTAL(cost) FROM sessions WHERE parent_session_id IS NULL AND updated_at >= ?),
                    (SELECT MAX(updated_at) FROM sessions)""",
                since,
                since,
            )
        except sqlite3.Error as e:
            ERRORS.append(f"crush_row: {db}: {e!r}")
            continue
        msgs, cost = msgs + m, cost + c
        if t:
            last = max(last or 0, t)
    return [{"tool": "crush", "msgs": msgs, "input": None, "output": None, "cost": cost, "last": last}]


def paint(code, s):
    return f"\033[{code}m{s}\033[0m" if COLOR else s


def dim(s):
    return paint("2", s)


def level(u):
    """statusline-command.sh 의 make_bar 와 같은 기준"""
    return "38;5;203" if u >= 80 else "38;5;221" if u >= 50 else "38;5;114"


def dur(sec):
    sec = int(sec)
    if sec <= 0:
        return "now"
    if sec < 3600:
        return f"{sec // 60}m"
    if sec < 86400:
        return f"{sec // 3600}h{sec % 3600 // 60}m"
    return f"{sec // 86400}d{sec % 86400 // 3600}h"


def human(n):
    if n is None:
        return "-"
    if n >= 1e6:
        return f"{n / 1e6:.1f}M"
    if n >= 1e3:
        return f"{n / 1e3:.0f}k"
    return str(n)


def local(ts, fmt="%m-%d %H:%M"):
    return datetime.fromtimestamp(ts).strftime(fmt)


def print_limits(rows):
    w = max([len(r["name"]) for r in rows] + [5]) + 2
    print(dim(f"{'TOOL':<8}{'LIMIT':<{w}}{'USED':<17}RESETS IN"))
    for r in rows:
        u = round(r["used"])
        f = min(max(u // 10, 0), 10)
        line = paint(TOOL_COLOR[r["tool"]] + ";1", f"{r['tool']:<8}") + f"{r['name']:<{w}}"
        line += paint(level(u), "█" * f) + dim("░" * (10 - f)) + paint(level(u), f"{u}%".rjust(5)) + "  "
        line += (f"{dur(r['reset'] - NOW):<7}" + dim(local(r["reset"]))) if r["reset"] else dim("-")
        if r["asof"]:
            line += "  " + dim(f"({dur(NOW - r['asof'])} ago)")
        print(line)


def print_usage(rows, days):
    print(dim(f"{'TOOL':<10}{'MSGS':>7}{'IN':>8}{'OUT':>8}{'COST':>9}   LAST USED   (last {days}d)"))
    for r in rows:
        cost = f"${r['cost']:.2f}"
        nums = f"{r['msgs']:>7}{human(r['input']):>8}{human(r['output']):>8}{cost:>9}"
        last = local(r["last"], "%Y-%m-%d") if r["last"] else "-"
        print(
            paint(TOOL_COLOR[r["tool"]] + ";1", f"{r['tool']:<10}")
            + (nums if r["msgs"] else dim(nums))
            + "   "
            + dim(last)
        )


def spin(stop):
    """결과를 모으는 동안 stderr 에 spinner 를 보여 준다. (zellij codex 훅과 같은 프레임)"""
    frames = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    i = 0
    while not stop.wait(0.1):
        print(f"\r{frames[i % len(frames)]} loading...", end="", file=sys.stderr, flush=True)
        i += 1
    print("\r\033[K", end="", file=sys.stderr, flush=True)


def main():
    parser = argparse.ArgumentParser(description="codex / claude / agy 한도와 opencode / crush 사용량 조회")
    parser.add_argument("days", nargs="?", type=int, default=7, help="opencode / crush 집계 기간(일), 기본 7")
    days = parser.parse_args().days
    if days < 0:
        parser.error("days must be >= 0")
    since = int(NOW) - days * 86400

    stop = threading.Event()
    spinner = threading.Thread(target=spin, args=(stop,), daemon=True)
    if sys.stderr.isatty():
        spinner.start()
    try:
        # claude / agy 는 각각 수 초 걸려서 먼저 띄워 두고 나머지를 처리한다.
        with ThreadPoolExecutor() as ex:
            claude = ex.submit(
                run,
                ["claude", "-p", "/usage", "--no-session-persistence", "--strict-mcp-config", "--setting-sources", ""],
                HOME,
            )
            agy = ex.submit(run, ["agy", "-p", "/usage", "--output-format", "json", "--print-timeout", "60s"])
            usage = safe(opencode_row, since) + safe(crush_row, since)
            limits = safe(codex_rows) + safe(claude_rows, claude.result()) + safe(agy_rows, agy.result())
    finally:
        stop.set()
        if spinner.is_alive():
            spinner.join()

    print_limits(limits)
    print()
    print_usage(usage, days)
    sys.stdout.flush()  # 파이프로 받을 때(2>&1 | less) 에러가 표보다 먼저 나오지 않게 한다.
    for e in ERRORS:
        print(e, file=sys.stderr)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
