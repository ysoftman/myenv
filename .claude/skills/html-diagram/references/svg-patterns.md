# SVG Diagram Patterns

Each pattern below is a **complete, copy-pasteable snippet** — the `<defs>` marker and the pattern's `<style>` block are inlined so you can drop a single `<svg>…</svg>` block into any page and it renders correctly. Adjust the viewBox, coordinates, and labels to fit your data, but keep semantics in classes (`.ok`, `.wip`, …) rather than inline `fill=` so colors stay consistent with `design-tokens.md`.

Two non-negotiable rules:

1. **Accessibility contract.** Every SVG follows `SKILL.md` §Accessibility: `role="img"` + `aria-labelledby` referencing first-child `<title>` and `<desc>`. Replace the IDs with section-unique ones; don't strip the elements.
2. **Section-scoped marker IDs.** Each pattern uses `id="arr-<pattern>"` (e.g. `arr-flow`, `arr-seq`). When you embed multiple patterns in one HTML document, **rename the marker to match your section id** (`arr-deploy-flow`, `arr-rollout-seq`, …) so document-scoped IDs don't collide.

## Shared style fragments (reference only)

If you want to share a status style block across many flow diagrams in one host doc, lift this into the page-level `<style>` instead of repeating it per SVG:

```css
.step rect   { stroke: #2a3142; stroke-width: 1.5; }
.step text   { fill: #e6e8ee; font: 600 15px sans-serif; text-anchor: middle; }
.step .sub   { font: 13px sans-serif; fill: #98a2b3; }
.step .stat  { font: 700 12px sans-serif; }
.ok   rect   { fill: rgba(34,197,94,.18);  stroke: rgba(34,197,94,.5); }
.wip  rect   { fill: rgba(245,158,11,.18); stroke: rgba(245,158,11,.5); }
.todo rect   { fill: rgba(100,116,139,.18); stroke: rgba(100,116,139,.5); }
.skip rect   { fill: rgba(100,116,139,.10); stroke: rgba(100,116,139,.4);
               stroke-dasharray: 4 3; }
.ok   .stat  { fill: #22c55e; }
.wip  .stat  { fill: #f59e0b; }
.todo .stat  { fill: #64748b; }
.skip .stat  { fill: #64748b; }
.arrow       { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
```

For colored arrowhead variants, add more markers next to your `arr-<section>` (e.g. `arr-<section>-ok`) with a matching `fill`.

---

## 1. flow (linear / branching pipeline)

Use when the story is "first A, then B, then C, branching on D". Boxes 130–160px wide, 80px tall, 20px gap horizontally. Single-row width budget ≈ 7 boxes for 1100 viewBox.

```html
<svg viewBox="0 0 1100 220" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="flow-t flow-d">
  <title id="flow-t">Pipeline progress</title>
  <desc id="flow-d">Three sequential steps from left to right with status badges (done, in progress, todo).</desc>
  <defs>
    <marker id="arr-flow" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .step rect   { stroke-width: 1.5; }
    .step text   { fill: #e6e8ee; font: 600 15px sans-serif; text-anchor: middle; }
    .step .sub   { font: 13px sans-serif; fill: #98a2b3; }
    .step .stat  { font: 700 12px sans-serif; }
    .ok   rect   { fill: rgba(34,197,94,.18);  stroke: rgba(34,197,94,.5); }
    .wip  rect   { fill: rgba(245,158,11,.18); stroke: rgba(245,158,11,.5); }
    .todo rect   { fill: rgba(100,116,139,.18); stroke: rgba(100,116,139,.5); }
    .ok   .stat  { fill: #22c55e; }
    .wip  .stat  { fill: #f59e0b; }
    .todo .stat  { fill: #64748b; }
    .arrow       { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
  </style>

  <g class="step ok"   transform="translate(20,40)">
    <rect width="130" height="80" rx="6" />
    <text x="65" y="22">Step 1</text>
    <text x="65" y="40" class="sub">subtitle</text>
    <text x="65" y="72" class="stat">DONE</text>
  </g>
  <g class="step wip"  transform="translate(170,40)">
    <rect width="130" height="80" rx="6" />
    <text x="65" y="22">Step 2</text>
    <text x="65" y="72" class="stat">WIP</text>
  </g>
  <g class="step todo" transform="translate(320,40)">
    <rect width="130" height="80" rx="6" />
    <text x="65" y="22">Step 3</text>
    <text x="65" y="72" class="stat">TODO</text>
  </g>

  <path class="arrow" d="M150,80 L170,80" marker-end="url(#arr-flow)" />
  <path class="arrow" d="M300,80 L320,80" marker-end="url(#arr-flow)" />
</svg>
```

Branching: drop one node to row 2 (e.g. `translate(320,180)`) and route the arrow `d="M385,120 L385,180"` with a vertical drop.

---

## 2. sequence (actors over time)

Two-column or three-column actors on top, dashed lifelines down, horizontal arrows between them with labels above. Vertical spacing ≈ 50px per message.

```html
<svg viewBox="0 0 900 360" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="seq-t seq-d">
  <title id="seq-t">Request sequence between three services</title>
  <desc id="seq-d">Client triggers a job on the orchestrator, which calls the backend; backend responds, orchestrator returns the result.</desc>
  <defs>
    <marker id="arr-seq" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .actor rect { fill: rgba(110,168,254,.18); stroke: rgba(110,168,254,.5); }
    .actor text { fill: #e6e8ee; font: 600 14px sans-serif; text-anchor: middle; }
    .life       { stroke: #6b7280; stroke-width: 1.2; stroke-dasharray: 5 4; opacity: 0.75; }
    .msg        { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
    .lbl        { fill: #e6e8ee; font: 13px sans-serif; }
    .note       { fill: #98a2b3; font: 12px sans-serif; }
  </style>

  <!-- actors -->
  <g class="actor"><rect x="60"  y="20" width="160" height="36" rx="4" />
    <text x="140" y="43">Client</text></g>
  <g class="actor"><rect x="370" y="20" width="160" height="36" rx="4" />
    <text x="450" y="43">Orchestrator</text></g>
  <g class="actor"><rect x="680" y="20" width="160" height="36" rx="4" />
    <text x="760" y="43">Backend API</text></g>

  <!-- lifelines -->
  <line class="life" x1="140" y1="60" x2="140" y2="340" />
  <line class="life" x1="450" y1="60" x2="450" y2="340" />
  <line class="life" x1="760" y1="60" x2="760" y2="340" />

  <!-- messages -->
  <text class="lbl" x="295" y="95" text-anchor="middle">start job</text>
  <path class="msg" d="M140,105 L450,105" marker-end="url(#arr-seq)" />

  <text class="lbl" x="605" y="155" text-anchor="middle">POST /work</text>
  <path class="msg" d="M450,165 L760,165" marker-end="url(#arr-seq)" />

  <text class="lbl" x="605" y="215" text-anchor="middle">200 OK</text>
  <path class="msg" d="M760,225 L450,225" marker-end="url(#arr-seq)" stroke-dasharray="5 3" />
</svg>
```

---

## 3. timeline (events on a date axis)

Horizontal axis with ticks; events drop above/below as labeled markers. Use when the user asks for milestones, release history, "이 날짜에 무슨 일".

```html
<svg viewBox="0 0 1100 240" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="tl-t tl-d">
  <title id="tl-t">Project milestone timeline</title>
  <desc id="tl-d">Four dated milestones on a horizontal axis showing planning, kickoff, mid-point, and delivery.</desc>
  <style>
    .axis  { stroke: #2a3142; stroke-width: 2; }
    .tick  { stroke: #98a2b3; stroke-width: 1; }
    .date  { fill: #98a2b3; font: 12px sans-serif; text-anchor: middle; }
    .event { fill: #e6e8ee; font: 600 13px sans-serif; text-anchor: middle; }
    .dot   { fill: #6ea8fe; }
    .dot.ok { fill: #22c55e; } .dot.wip { fill: #f59e0b; }
  </style>

  <line class="axis" x1="40" y1="140" x2="1060" y2="140" />

  <!-- tick + date -->
  <line class="tick" x1="120" y1="135" x2="120" y2="145" />
  <text class="date" x="120" y="165">01-15</text>

  <line class="tick" x1="360" y1="135" x2="360" y2="145" />
  <text class="date" x="360" y="165">02-01</text>

  <line class="tick" x1="700" y1="135" x2="700" y2="145" />
  <text class="date" x="700" y="165">03-10</text>

  <line class="tick" x1="1000" y1="135" x2="1000" y2="145" />
  <text class="date" x="1000" y="165">04-20</text>

  <!-- events above axis -->
  <circle class="dot ok"  cx="120"  cy="140" r="6" />
  <text class="event" x="120"  y="115">Planning</text>

  <circle class="dot ok"  cx="360"  cy="140" r="6" />
  <text class="event" x="360"  y="115">Kickoff</text>

  <!-- event below axis -->
  <circle class="dot wip" cy="140" cx="700" r="6" />
  <text class="event" x="700"  y="200">Mid-point review</text>

  <circle class="dot" cx="1000" cy="140" r="6" />
  <text class="event" x="1000" y="115">Delivery</text>
</svg>
```

For dense timelines, stagger event labels (alternate `y=115` and `y=95`) so they don't overlap.

---

## 4. mapping (AS-IS → TO-BE, two columns)

Left column boxes, right column boxes, arrows crossing. Use when comparing "old → new" or "from → to".

```html
<svg viewBox="0 0 900 360" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="map-t map-d">
  <title id="map-t">Legacy to new system mapping</title>
  <desc id="map-d">Two boxes on the left (legacy components) map with arrows to two boxes on the right (replacements).</desc>
  <defs>
    <marker id="arr-map" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .col-title { fill: #98a2b3; font: 600 14px sans-serif; text-anchor: middle; }
    .box rect  { stroke-width: 1.5; }
    .box text  { fill: #e6e8ee; font: 14px sans-serif; text-anchor: middle; }
    .src rect  { fill: rgba(100,116,139,.18); stroke: rgba(100,116,139,.5); }
    .dst rect  { fill: rgba(34,197,94,.18);   stroke: rgba(34,197,94,.5); }
    .arrow     { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
  </style>

  <text class="col-title" x="150" y="30">AS-IS</text>
  <text class="col-title" x="750" y="30">TO-BE</text>

  <g class="box src"><rect x="40" y="60" width="220" height="56" rx="6" />
    <text x="150" y="93">Legacy System</text></g>
  <g class="box src"><rect x="40" y="140" width="220" height="56" rx="6" />
    <text x="150" y="173">Legacy Job Push</text></g>

  <g class="box dst"><rect x="640" y="60" width="220" height="56" rx="6" />
    <text x="750" y="93">New Pipeline</text></g>
  <g class="box dst"><rect x="640" y="140" width="220" height="56" rx="6" />
    <text x="750" y="173">Declarative Apply</text></g>

  <path class="arrow" d="M260,88  L640,88"  marker-end="url(#arr-map)" />
  <path class="arrow" d="M260,168 L640,168" marker-end="url(#arr-map)" />
</svg>
```

If lines would cross, reorder rows on one side so most arrows stay roughly horizontal.

---

## 5. architecture (boxed components, optional region grouping)

Boxes for components, dashed rectangles around groups (a service, a namespace, a cluster). Use for system topology, deploy stacks.

```html
<svg viewBox="0 0 1000 420" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="arch-t arch-d">
  <title id="arch-t">Two-namespace service topology</title>
  <desc id="arch-d">Stage namespace contains a runner and worker; prod namespace contains an API service. Arrow shows the runner calling the API across namespaces.</desc>
  <style>
    .region rect { fill: none; stroke: #2a3142; stroke-dasharray: 6 4; stroke-width: 1.5; }
    .region text { fill: #98a2b3; font: 600 13px sans-serif; }
    .comp rect   { fill: rgba(110,168,254,.18); stroke: rgba(110,168,254,.5); stroke-width: 1.5; }
    .comp text   { fill: #e6e8ee; font: 14px sans-serif; text-anchor: middle; }
    .data rect   { fill: rgba(167,139,250,.18); stroke: rgba(167,139,250,.5); stroke-width: 1.5; }
    .data text   { fill: #e6e8ee; font: 14px sans-serif; text-anchor: middle; }
    .link        { stroke: #98a2b3; stroke-width: 1.2; fill: none; }
  </style>

  <g class="region">
    <rect x="40" y="40" width="430" height="340" rx="10" />
    <text x="56" y="62">namespace: app-stage</text>
  </g>
  <g class="region">
    <rect x="530" y="40" width="430" height="340" rx="10" />
    <text x="546" y="62">namespace: app-prod</text>
  </g>

  <g class="comp"><rect x="80" y="100" width="180" height="50" rx="6" />
    <text x="170" y="130">runner</text></g>
  <g class="comp"><rect x="80" y="200" width="180" height="50" rx="6" />
    <text x="170" y="230">worker</text></g>
  <g class="data"><rect x="580" y="100" width="180" height="50" rx="6" />
    <text x="670" y="130">api</text></g>

  <path class="link" d="M260,225 C400,225 440,125 580,125" />
</svg>
```

---

## 6. state (nodes + labeled transitions)

Small graph with circles or rounded rectangles for states, arrows with text labels. Use for verdict gates, status machines.

```html
<svg viewBox="0 0 800 300" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="state-t state-d">
  <title id="state-t">Gate verdict state machine</title>
  <desc id="state-d">Running state transitions to PASS when all gates succeed, or FAIL when any gate fails.</desc>
  <defs>
    <marker id="arr-state" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .state rect { fill: rgba(110,168,254,.18); stroke: rgba(110,168,254,.5); stroke-width: 1.5; }
    .state text { fill: #e6e8ee; font: 600 14px sans-serif; text-anchor: middle; }
    .pass rect  { fill: rgba(34,197,94,.18);  stroke: rgba(34,197,94,.5); }
    .fail rect  { fill: rgba(239,68,68,.18);  stroke: rgba(239,68,68,.5); }
    .edge       { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
    .lbl        { fill: #98a2b3; font: 12px sans-serif; }
  </style>

  <g class="state"><rect x="80"  y="120" width="120" height="50" rx="25" />
    <text x="140" y="150">RUNNING</text></g>
  <g class="state pass"><rect x="340" y="40"  width="120" height="50" rx="25" />
    <text x="400" y="70">PASS</text></g>
  <g class="state fail"><rect x="340" y="200" width="120" height="50" rx="25" />
    <text x="400" y="230">FAIL</text></g>

  <path class="edge" d="M200,140 Q270,80 340,65" marker-end="url(#arr-state)" />
  <text class="lbl" x="240" y="100">all gates ok</text>

  <path class="edge" d="M200,160 Q270,220 340,225" marker-end="url(#arr-state)" />
  <text class="lbl" x="240" y="200">any gate fail</text>
</svg>
```

---

## 7. swimlane (actors as rows)

Horizontal lanes, each labeled on the left; activities flow left-to-right within each lane; inter-lane arrows for handoffs.

```html
<svg viewBox="0 0 1100 320" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="swim-t swim-d">
  <title id="swim-t">Cross-system workflow swimlanes</title>
  <desc id="swim-d">Three lanes — CI, staging cluster, production cluster — with activities flowing left-to-right and handoffs between lanes.</desc>
  <defs>
    <marker id="arr-swim" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .lane rect  { fill: none; stroke: #2a3142; stroke-width: 1; }
    .lane text  { fill: #98a2b3; font: 600 13px sans-serif; }
    .act rect   { fill: rgba(110,168,254,.18); stroke: rgba(110,168,254,.5); }
    .act text   { fill: #e6e8ee; font: 13px sans-serif; text-anchor: middle; }
    .arrow      { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
  </style>

  <g class="lane">
    <rect x="120" y="40"  width="960" height="80" />
    <text x="20"  y="85">CI</text>
    <rect x="120" y="120" width="960" height="80" />
    <text x="20"  y="165">staging</text>
    <rect x="120" y="200" width="960" height="80" />
    <text x="20"  y="245">production</text>
  </g>

  <g class="act"><rect x="140" y="55" width="180" height="50" rx="6" />
    <text x="230" y="85">trigger build</text></g>
  <g class="act"><rect x="380" y="135" width="180" height="50" rx="6" />
    <text x="470" y="165">apply config</text></g>
  <g class="act"><rect x="620" y="215" width="180" height="50" rx="6" />
    <text x="710" y="245">smoke test</text></g>

  <path class="arrow" d="M320,80  L380,160" marker-end="url(#arr-swim)" />
  <path class="arrow" d="M560,160 L620,240" marker-end="url(#arr-swim)" />
</svg>
```

---

## 8. dependency (DAG)

Free-form positioned nodes with multiple in/out arrows. Use when jobs have non-trivial fan-in/fan-out.

```html
<svg viewBox="0 0 900 360" xmlns="http://www.w3.org/2000/svg"
     role="img" aria-labelledby="dag-t dag-d">
  <title id="dag-t">Build job dependency graph</title>
  <desc id="dag-d">Build feeds two parallel jobs (deploy and index); deploy and index both feed load-test; all feed the final report job.</desc>
  <defs>
    <marker id="arr-dag" viewBox="0 0 10 10" refX="9" refY="5"
            markerWidth="8" markerHeight="8" orient="auto">
      <path d="M0,0 L10,5 L0,10 z" fill="#98a2b3" />
    </marker>
  </defs>
  <style>
    .job rect { fill: rgba(110,168,254,.18); stroke: rgba(110,168,254,.5); stroke-width: 1.5; }
    .job text { fill: #e6e8ee; font: 600 14px sans-serif; text-anchor: middle; }
    .edge     { stroke: #98a2b3; stroke-width: 1.5; fill: none; }
  </style>

  <g class="job"><rect x="60"  y="40"  width="160" height="50" rx="6" />
    <text x="140" y="70">build</text></g>
  <g class="job"><rect x="60"  y="160" width="160" height="50" rx="6" />
    <text x="140" y="190">deploy</text></g>
  <g class="job"><rect x="370" y="40"  width="160" height="50" rx="6" />
    <text x="450" y="70">index</text></g>
  <g class="job"><rect x="370" y="160" width="160" height="50" rx="6" />
    <text x="450" y="190">load-test</text></g>
  <g class="job"><rect x="680" y="100" width="160" height="50" rx="6" />
    <text x="760" y="130">report</text></g>

  <path class="edge" d="M220,65  L370,65"  marker-end="url(#arr-dag)" />
  <path class="edge" d="M220,185 L370,185" marker-end="url(#arr-dag)" />
  <path class="edge" d="M220,90  L370,160" marker-end="url(#arr-dag)" />
  <path class="edge" d="M530,65  L680,120" marker-end="url(#arr-dag)" />
  <path class="edge" d="M530,185 L680,130" marker-end="url(#arr-dag)" />
</svg>
```

---

## Tips for clean coordinates

- Pick a node width and gap up front (e.g. 130 + 20) so arrow endpoints fall on round numbers.
- Vertical centers: for an 80px-tall node at `y=40`, center is `y=80`. Arrows hit `M (right_edge), 80 L (left_edge), 80`.
- Add a one-line comment near non-obvious paths explaining the geometry — `<!-- branch out at step 5 -->` saves time on the next edit.
- If labels collide, prefer enlarging the viewBox over shrinking the font; readability beats compactness.
