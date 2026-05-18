---
name: html-diagram
description: Build dark-theme HTML documents with inline SVG diagrams (flow, sequence, timeline, mapping, architecture, state). Use whenever the user wants to draw/render/visualize a diagram as HTML, asks for "다이어그램", "diagram", "플로우", "타임라인", "시퀀스", "아키텍처", "도식", references an existing HTML diagram doc, or wants to add a new diagram section to such a doc. Also trigger when the user describes a process, pipeline, system, or migration steps and asks to visualize it — even if they don't explicitly say "HTML". Also trigger when the user asks for "example", "예시", "샘플", "모든 패턴", "showcase" of this skill — copy `examples/showcase.html` to the current working directory and open it.
---

# html-diagram

Render a diagram (or a whole diagram-centric HTML document) as a single self-contained HTML file with inline SVG. The output follows a consistent dark-theme convention — CSS variable tokens, `section.diagram` anatomy, semantic SVG node/arrow patterns — so multiple diagrams in one doc, or new diagrams added to an existing doc, stay visually coherent. Korean copy is the default; English is fine when the user writes in English.

The goal is not to invent a new diagramming framework. It is to produce dependable, accessible, theme-consistent diagrams that work offline, print well, and don't rely on client-side JS.

## When to use what output mode

Three output modes. Pick based on the user's intent — ask only if it's genuinely ambiguous after one careful read:

1. **Standalone HTML file** — when there's no existing doc, or when the user asks for "a new HTML diagram / new page / 새 HTML". Use the scaffold in `assets/base.html`.
2. **Insert into existing HTML** — when the user references an existing HTML diagram doc, or says "여기에 추가", "이 문서에 섹션 추가", "기존 doc 에 다이어그램 하나 더". Find the file, locate the right insertion point (typically right before the markdown-body section or after the latest `section.diagram`), and add a new `<section class="diagram">`. Also update the TOC `<nav class="toc">` if one exists.
3. **Showcase example** — when the user types just `example`, `예시`, `샘플`, `showcase`, `모든 패턴`, or asks "이 스킬의 예시 보여줘 / 어떤 다이어그램이 가능한지 보여줘". Copy `examples/showcase.html` to the current working directory (default filename `html-diagram-showcase.html`, but honor any path the user gives) and offer to `open` it. Do NOT regenerate from scratch — the showcase is the canonical reference for every pattern + component.

For the second mode: read the existing doc first to confirm conventions (CSS variables actually present, section id pattern, TOC structure). Don't overwrite shared `<style>` or `<defs>`; reuse them.

For the third mode: the showcase file already contains all 8 SVG patterns (flow, sequence, timeline, mapping, architecture, state, swimlane, dependency) plus palette, badges, callouts, legend, and mapping-table examples. It's self-contained (no external CSS/JS), so plain `cp` is enough. Don't edit the source `examples/showcase.html` in response to a user's example request — copy it. If the user later wants to tweak the copy, treat that as mode 2 (insert/edit existing).

## Diagram section anatomy

Every diagram lives in a `<section class="diagram" id="...">` with this exact skeleton:

```html
<section class="diagram" id="sec-something">
  <h2>N. 섹션 제목</h2>
  <div class="src">출처 / 날짜 / 참조 — e.g. "§4 파이프라인 · YYYY-MM-DD"</div>
  <p class="desc">한두 문장으로 이 다이어그램이 답하는 질문을 적는다.</p>
  <div class="svgwrap">
    <svg viewBox="0 0 W H" xmlns="http://www.w3.org/2000/svg"
         role="img" aria-labelledby="sec-something-title sec-something-desc">
      <title id="sec-something-title">짧은 한 줄 제목 (스크린리더 노출)</title>
      <desc id="sec-something-desc">2-3 문장으로 다이어그램의 핵심 내용 서술 (노드/관계 요약).</desc>
      <!-- defs, style, content -->
    </svg>
  </div>
  <div class="legend">…</div>   <!-- optional -->
  <div class="callout">…</div>  <!-- optional -->
</section>
```

The `src` line is small grey metadata. The `desc` paragraph is the human takeaway — write it like a caption a reader can read in 5 seconds and know what the diagram is for.

## Accessibility

Every SVG must be reachable by screen readers. The pattern above is the contract — don't skip it:

- `role="img"` tells AT to treat the SVG as a single image rather than recursing into shapes.
- `aria-labelledby="<title-id> <desc-id>"` links both elements; `aria-label` alone is unreliable and `<title>` alone has spotty AT support in 2025.
- Use distinct, page-unique IDs (e.g. derived from the section id) so multiple diagrams on one page don't collide.
- `<title>` is a short label (≤80 chars). `<desc>` is 1–3 sentences explaining structure and meaning — not a verbose walkthrough.
- Both elements must be the *first* children of `<svg>`, before `<defs>`/`<style>`/content. AT relies on this ordering.

## Design tokens

Don't invent colors. Reuse the existing CSS variables defined in the host document (or in `assets/base.html` for standalone). The semantic palette:

| Variable | Hex | Use |
|---|---|---|
| `--bg` | `#0f1116` | page background |
| `--panel` | `#161a22` | section background |
| `--panel-2` | `#1d2230` | inner panels (svgwrap, code, table th) |
| `--border` | `#2a3142` | borders |
| `--fg` | `#e6e8ee` | primary text |
| `--muted` | `#98a2b3` | secondary text, arrows |
| `--accent` | `#6ea8fe` | links, headings, focus |
| `--accent-2` | `#4ade80` | secondary accent |
| `--ok` | `#22c55e` | success / DONE |
| `--warn` | `#f59e0b` | warning / WIP |
| `--err` | `#ef4444` | error / FAIL |
| `--skip` | `#64748b` | skipped / dropped |

For SVG content, the same colors appear with alpha for fills:

- ok fill `rgba(34,197,94,.18)` stroke `rgba(34,197,94,.5)`
- wip fill `rgba(245,158,11,.18)` stroke `rgba(245,158,11,.5)`
- todo fill `rgba(100,116,139,.18)` stroke `rgba(100,116,139,.5)`
- skip fill `rgba(100,116,139,.10)` stroke `rgba(100,116,139,.4)` `stroke-dasharray: 4 3`
- callout-style fill `rgba(<color>,.08)` stroke `rgba(<color>,.5)`

See `references/design-tokens.md` for the full token list including `.badge`, `.callout`, and `legend` patterns.

## SVG diagramming patterns

Don't use external libraries. Inline SVG with a small embedded `<style>` block inside the SVG keeps everything portable and theme-consistent. Each pattern below is documented with a working snippet in `references/svg-patterns.md` — read that file when you actually need to render one.

| Pattern | Use it for |
|---|---|
| **flow** | linear or branching step graphs (pipelines, migration steps) |
| **sequence** | actor → actor messages over time (API calls, RPC, load test) |
| **timeline** | events on a horizontal date axis (milestones, releases) |
| **mapping** | left column → right column with arrows (AS-IS → TO-BE, repo→job) |
| **architecture** | boxed components with grouped regions (deploy stack, service topology) |
| **state** | nodes + labeled transitions (verdict gate, status machine) |
| **swimlane** | actors as rows, steps flow left-to-right within each lane |
| **dependency** | DAG with fan-in/fan-out (job dependencies) |

For each pattern, prefer:

- viewBox sized so the diagram renders crisp at typical container widths (~1100×H for full-width, ~700×H for compact).
- One `<defs>` arrowhead marker per SVG with a **section-scoped id** like `arr-<section>` (e.g. `arr-flow`, `arr-seq`). SVG marker IDs are document-scoped in HTML, so `id="arr1"` reused across sections is invalid and breaks `url(#…)` resolution when fills differ. For multiple arrow colors in one SVG, suffix the color (`arr-flow-ok`, `arr-flow-warn`).
- An SVG-scoped `<style>` block instead of inline `fill=` on every shape, so semantic classes (`.ok`, `.wip`, …) stay consistent.
- Grouped nodes via `<g class="step ok" transform="translate(x,y)">` so one transform moves the whole node.

## Writing Korean and English in SVG

SVG `<text>` does not wrap and `foreignObject` rendering is unreliable across browsers, print engines, and SVG-to-image converters — don't use it for labels. Multi-line text is done by hand with one of two patterns:

**Pattern A: multiple `<text>` rows** (simplest; use when each line has different styling)

```html
<text x="65" y="22">Step 4</text>
<text x="65" y="40" class="sub">subtitle line</text>
<text x="65" y="58" class="sub">subtitle line 2</text>
```

**Pattern B: `<tspan>` inside one `<text>`** (use when lines share styling, e.g. wrapping a single label)

```html
<text x="65" y="22" text-anchor="middle">
  <tspan x="65" dy="0">긴 한국어 라벨의 첫 줄</tspan>
  <tspan x="65" dy="1.2em">두 번째 줄</tspan>
</text>
```

Repeat `x` on each `<tspan>` so the line restarts at the same horizontal origin; `dy="1.2em"` advances the baseline.

**Length rules of thumb:**

- Korean: keep a single visual line to ≤ ~14 characters at 13–15px font; otherwise wrap.
- English: keep ≤ ~22 characters per line at the same size.
- If the label still won't fit after wrapping to 2 lines, the node box is too small — enlarge it or move detail into a `<desc>` / callout below the SVG.

Korean characters render fine in `sans-serif`; no explicit font needed. Avoid font stacks with non-system fonts unless the host doc loads them — missing fonts cause layout shifts that the user only catches in production.

## Workflow

1. **Read the source.** If the user pointed at an existing HTML doc, read it first to learn its conventions and avoid duplicating styles.
2. **Pick the pattern.** Match the user's description to one of the patterns above. If the request mixes patterns (e.g. "timeline with sequence callouts"), use the dominant pattern and add the other as callouts/legend.
3. **Sketch the layout.** Decide viewBox, node grid (e.g. 7 boxes × 130px wide + 20px gap → width 1070), arrow paths. It's fine to compute coordinates in comments inside the SVG to make later edits easy.
4. **Write the section.** Follow the anatomy above. Reuse existing `<style>`/`<defs>` if inserting into a host doc.
5. **Update navigation.** If the host doc has a `<nav class="toc">`, add the new entry. Update the "최근 갱신" date in the header if there is one.
6. **Verify in browser** if the user wants visual confirmation: `open path/to/file.html`. Don't claim "rendered fine" without actually opening it when the user asks for visual confirmation.

## Common mistakes to avoid

- **Inventing colors** that don't appear in the existing token set — diagrams look off and merge requests get review comments. Always pull from the tokens above.
- **Wrapping SVG text** with `\n` — SVG ignores it. Use multiple `<text>` rows.
- **Forgetting `viewBox`** — the SVG won't scale responsively. Always set viewBox; let CSS handle width/height.
- **Duplicate marker IDs across SVGs.** Marker IDs (`id="arr1"`) are document-scoped — using the same ID in multiple `<defs>` is invalid HTML and the browser will resolve every `url(#arr1)` to the first match, breaking color variants. Always section-scope: `arr-flow`, `arr-seq`, `arr-state`, …
- **Overstuffing one diagram.** If the diagram is getting > 14 nodes or > 1200px wide, split into two related sections with shared legend.
- **Light-theme contrast.** This palette is dark-only. Don't insert light backgrounds inside dark panels.
- **Letting wide SVGs shrink unreadably on mobile.** When a SVG is dense (≥ 7 nodes or `viewBox` width ≥ 1000), add `class="wide"` to the `<div class="svgwrap">` so it scrolls horizontally below ~880px instead of collapsing past legibility. The base template's `@media print` block then restores fit-to-page so prints aren't clipped.

## Reference files

- `references/design-tokens.md` — full CSS variable list, badge/callout/legend HTML.
- `references/svg-patterns.md` — working snippets for each diagram pattern (flow, sequence, timeline, mapping, architecture, state, swimlane, dependency).
- `assets/base.html` — standalone HTML scaffold: head with style block, body with `<div class="wrap">` + sticky TOC + `<main>` ready for `section.diagram` blocks.
- `examples/showcase.html` — end-to-end example page rendering every pattern + every component (palette, badges, callouts, legend, mapping table). Copy this verbatim when the user asks for `example` / `예시` / `샘플` / `showcase`.
