# Design Tokens

Single source for the dark-theme palette and shared components. Reuse these instead of inventing equivalents — consistency matters more than micro-optimization, and PR reviewers will flag off-palette colors.

## CSS variables

Declared on `:root`. Drop this block verbatim into the host doc's `<style>` (or rely on `assets/base.html`).

```css
:root {
  --bg: #0f1116;        /* page background */
  --panel: #161a22;     /* section background */
  --panel-2: #1d2230;   /* inner panel: svgwrap, code, table th */
  --border: #2a3142;
  --fg: #e6e8ee;        /* primary text */
  --muted: #98a2b3;     /* secondary text, arrow strokes */
  --accent: #6ea8fe;    /* links, h1/h2 accents, focus */
  --accent-2: #4ade80;  /* secondary accent */
  --warn: #f59e0b;
  --err: #ef4444;
  --ok: #22c55e;
  --skip: #64748b;
  /* domain-specific (optional, drop if unused) */
  --base: #60a5fa;
  --comp: #a78bfa;
  --diff: #f472b6;
  --report: #34d399;
}
```

## Status fills for SVG

When painting boxes inside SVG, use rgba with the same hue but lower alpha so backgrounds don't compete with text:

```text
.ok    fill rgba(34,197,94,.18)   stroke rgba(34,197,94,.5)
.wip   fill rgba(245,158,11,.18)  stroke rgba(245,158,11,.5)
.todo  fill rgba(100,116,139,.18) stroke rgba(100,116,139,.5)
.skip  fill rgba(100,116,139,.10) stroke rgba(100,116,139,.4) stroke-dasharray: 4 3
.err   fill rgba(239,68,68,.18)   stroke rgba(239,68,68,.5)
```

For callout-style boxes inside SVG (background tints, not nodes), drop alpha further to `.08`:

```text
fill rgba(34,197,94,.08) stroke rgba(34,197,94,.5)    /* ok callout */
fill rgba(245,158,11,.08) stroke rgba(245,158,11,.5)  /* warn callout */
fill rgba(239,68,68,.08) stroke rgba(239,68,68,.5)    /* err callout */
```

## section.diagram styling

```css
section.diagram {
  margin-bottom: 56px;
  padding: 24px;
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: 8px;
}
section.diagram h2 { margin: 0 0 4px; font-size: 20px; }
section.diagram .src { color: var(--muted); font-size: 14px; margin-bottom: 12px; }
section.diagram p.desc { color: var(--fg); font-size: 16px; margin: 0 0 18px; }

.svgwrap {
  background: var(--panel-2);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 16px;
  overflow-x: auto;
}
.svgwrap svg { display: block; max-width: 100%; height: auto; }
```

## Badges (inline status pills)

```html
<span class="badge ok">DONE</span>
<span class="badge wip">진행</span>
<span class="badge todo">TODO</span>
<span class="badge skip">SKIP</span>
<span class="badge err">FAIL</span>
```

```css
.badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 600;
}
.badge.ok   { background: rgba(34,197,94,.15);   color: var(--ok);   border: 1px solid rgba(34,197,94,.35); }
.badge.wip  { background: rgba(245,158,11,.15);  color: var(--warn); border: 1px solid rgba(245,158,11,.35); }
.badge.todo { background: rgba(100,116,139,.15); color: var(--skip); border: 1px solid rgba(100,116,139,.35); }
.badge.skip { background: rgba(100,116,139,.15); color: var(--skip); border: 1px solid rgba(100,116,139,.35); text-decoration: line-through; }
.badge.err  { background: rgba(239,68,68,.15);   color: var(--err);  border: 1px solid rgba(239,68,68,.35); }
```

## Callouts (attention boxes outside SVG)

```html
<div class="callout"><strong>주의:</strong> 본문 한 줄.</div>
<div class="callout ok"><strong>결과:</strong> …</div>
<div class="callout err"><strong>장애:</strong> …</div>
```

```css
.callout {
  margin-top: 14px;
  padding: 12px 14px;
  border-left: 3px solid var(--warn);
  background: rgba(245,158,11,.08);
  font-size: 15px;
  border-radius: 4px;
}
.callout.err { border-left-color: var(--err); background: rgba(239,68,68,.08); }
.callout.ok  { border-left-color: var(--ok);  background: rgba(34,197,94,.08); }
.callout strong { color: var(--warn); }
.callout.err strong { color: var(--err); }
.callout.ok strong  { color: var(--ok); }
```

## Legend (color key under a diagram)

```html
<div class="legend">
  <span class="item"><span class="sw" style="background:rgba(34,197,94,.4)"></span>완료</span>
  <span class="item"><span class="sw" style="background:rgba(245,158,11,.4)"></span>진행</span>
  <span class="item"><span class="sw" style="background:rgba(100,116,139,.4)"></span>대기</span>
  <span class="item"><span class="sw" style="background:rgba(100,116,139,.2); border:1px dashed #98a2b3"></span>스킵</span>
</div>
```

```css
.legend { display: flex; flex-wrap: wrap; gap: 14px; margin-top: 12px; font-size: 14px; color: var(--muted); }
.legend .item { display: inline-flex; align-items: center; gap: 6px; }
.legend .sw { width: 12px; height: 12px; border-radius: 3px; display: inline-block; }
```

## Mapping table (when a diagram pairs with a table)

```html
<table class="mapping">
  <thead><tr><th>From</th><th>To</th><th>Note</th></tr></thead>
  <tbody>
    <tr><td class="area">old-job</td><td>new-job</td><td>…</td></tr>
  </tbody>
</table>
```

```css
table.mapping { width: 100%; border-collapse: collapse; font-size: 15px; margin-top: 8px; }
table.mapping th, table.mapping td { padding: 8px 10px; text-align: left; border-bottom: 1px solid var(--border); }
table.mapping th { color: var(--muted); font-weight: 600; background: var(--panel-2); }
table.mapping td.area { color: var(--muted); }
```
