#!/usr/bin/env python3
"""ASCII 다이어그램 조립·검증 헬퍼.

  python3 draw.py check < diagram.txt   # 폭 + 세로 문자 컬럼 리포트, 1칸 밀림 경고
  python3 draw.py check 70 < ...        # 폭 한계를 바꿔서 검증 (기본 100)
  python3 draw.py demo                  # 자기 검증 (정렬 assert)

조립 예 (좌우 비교 패턴) — 컬럼은 절대값으로 넘기고, 결과는 stdout 으로 print 한다:

  import sys; sys.path.insert(0, '<이 파일의 디렉토리>')
  from draw import box, merge, cross, flow, place, at, ctr

  CB, CL, CR = 49, 22, 75                     # 경계 / 좌 흐름 / 우 흐름 컬럼
  lines  = [ctr('공통 진입점 (VIP)', CB), at('│', CB)]
  lines += [merge(l, r, CB) for l, r in zip(box(['기존 A', '설정 x'], 40),
                                            box(['신규 A', '설정 y'], 44))]
  lines += flow([CL, CB, CR], tips=[CL, CR], labels={CL: '소비', CR: '소비'})
  print('\\n'.join(lines))

함수 요약:
  box(lines, width)              내부폭 width 인 박스 (리스트 반환)
  merge(좌, 우, CB)              두 조각을 CB 컬럼 경계선으로 이음
  cross(좌박스줄, 우박스줄, CB)  경계 관통 가로 화살표 (├───┼──▶)
  flow(cols, tips, labels)       세로 흐름 2줄 (선 + 꼭지, 컬럼 일치 보장)
  place([(컬럼, 문자열), ...])   절대 컬럼 배치 (컬럼 뺄셈 불필요)
  at(문자, 컬럼) / ctr(문자열, 컬럼)   단독 배치 / 가운데 정렬
  w(문자열) / columns(줄) / check(텍스트)   표시폭 / 세로문자 컬럼 / 문제 목록
"""

import sys
import unicodedata as u
from collections import Counter

VERT = "│┼▼▲├┤┐┘┬┴"


def w(s):
    """표시 폭. 한글/CJK(W,F)=2, 박스 드로잉(A)·ASCII=1."""
    return sum(2 if u.east_asian_width(c) in "WF" else 1 for c in s)


def place(items):
    """(컬럼, 문자열) 목록을 절대 컬럼에 배치한 한 줄. 컬럼 뺄셈이 필요 없다."""
    line, prev = "", 0
    for col, s in sorted(items):
        line += " " * max(col - prev - 1, 1 if prev else 0) + s
        prev = col + w(s) - 1
    return line


def at(ch, col):
    """단독 배치. 여러 개면 place() 를 쓴다 (이어붙이기 뺄셈 실수 방지)."""
    return place([(col, ch)])


def ctr(s, col):
    """s 의 가운데가 col 컬럼에 오도록 왼쪽을 채운다."""
    return " " * (col - w(s) // 2 - 1) + s


def box(lines, width):
    """내부폭 width 인 박스. lines 는 제목 + 핵심 2~4줄."""
    return (
        ["┌" + "─" * width + "┐"]
        + ["│ " + t + " " * (width - 2 - w(t)) + " │" for t in lines]
        + ["└" + "─" * width + "┘"]
    )


def merge(left, right, sep_col, sep="│", fill=" ", gap="   "):
    """좌우 두 조각을 sep_col 컬럼의 경계선으로 잇는다 (좌우 비교 패턴)."""
    s = "  " + left
    return s + fill * (sep_col - 1 - w(s)) + sep + gap + right


def cross(left, right, sep_col):
    """경계를 관통하는 가로 화살표 줄. left 는 박스 줄(오른쪽 변이 ├ 로 바뀐다).
    화살표 라벨은 폭이 좁으므로 이 줄이 아니라 바로 위 줄에 둔다."""
    return merge(left[:-1] + "├", right, sep_col, sep="┼", fill="─", gap="──▶")


def flow(cols, tips=None, labels=None):
    """세로 흐름 2줄(선 줄 + 꼭지 줄)을 만든다. 꼭지는 항상 선과 같은 컬럼에 놓인다.

    cols   : 세로선 컬럼들 (예: [22, 49, 75])
    tips   : 꼭지(▼)로 그릴 컬럼. 생략하면 cols 전체 (경계선은 빼는 것이 보통)
    labels : {컬럼: 라벨} — 꼭지 오른쪽에 붙는다
    """
    tips = cols if tips is None else tips
    labels = labels or {}
    bar = place([(c, "│") for c in cols])
    tip = place([(c, ("▼" if c in tips else "│") + ("  " + labels[c] if c in labels else "")) for c in cols])
    return [bar, tip]


def columns(line):
    """그 줄에 있는 세로 문자들의 컬럼 집합."""
    return sorted({w(line[:k]) + 1 for k, c in enumerate(line) if c in VERT})


def check(text, max_width=100):
    """폭 초과와 '1칸 밀린 세로 문자'를 찾아 문제 목록으로 돌려준다."""
    lines = text.rstrip("\n").split("\n")
    problems = [
        f"{i}행: 폭 {w(ln.rstrip())} > {max_width}" for i, ln in enumerate(lines, 1) if w(ln.rstrip()) > max_width
    ]
    # 2회 이상 등장한 컬럼을 '정상 컬럼'으로 보고, 그 ±1 에만 있는 것은 밀림으로 본다
    cnt = Counter(c for ln in lines for c in columns(ln))
    common = {c for c, n in cnt.items() if n >= 2}
    for i, ln in enumerate(lines, 1):
        for c in columns(ln):
            if c not in common and ({c - 1, c + 1} & common):
                near = sorted({c - 1, c + 1} & common)[0]
                problems.append(f"{i}행: 세로 문자 컬럼 {c} — {near} 에서 1칸 밀림")
    return problems


def report(text, max_width=100):
    for i, line in enumerate(text.rstrip("\n").split("\n"), 1):
        print(f"{i:3d}  폭 {w(line.rstrip()):3d}  세로 {columns(line)}")
    for p in check(text, max_width):
        print("!!", p)


def demo():
    """자기 검증 — 꼭지 정렬과 밀림 검출이 동작하는지 확인한다."""
    CB, CL, CR = 49, 22, 75
    lines = [
        ctr("공통 진입점", CB),
        at("│", CB),
        merge("┌ 기존 (PM)", "┌ 신규 (k8s)", CB),
        merge("└ 컴포넌트 A", "└ 컴포넌트 A'", CB),
    ]
    lines += flow([CL, CB, CR], tips=[CL, CR], labels={CL: "소비", CR: "소비"})
    for line in lines:
        print(line)
    assert columns(lines[-2]) == [CL, CB, CR], columns(lines[-2])
    assert columns(lines[-1]) == [CL, CB, CR], columns(lines[-1])
    assert not check("\n".join(lines)), check("\n".join(lines))

    # 일부러 1칸 밀린 줄을 넣으면 check 가 잡아야 한다
    broken = lines + [place([(CL, "│"), (CB, "│"), (CR - 1, "▼")])]
    assert any("1칸 밀림" in p for p in check("\n".join(broken))), check("\n".join(broken))
    print("\nOK: 꼭지 정렬 일치, 폭 정상, 밀림 검출 동작")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "demo":
        demo()
    else:
        widths = [int(a) for a in sys.argv[1:] if a.isdigit()]
        report(sys.stdin.read(), widths[0] if widths else 100)
