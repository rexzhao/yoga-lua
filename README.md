# yoga-lua

A small, pure Lua Yoga/Flexbox-style layout engine for game UI.

`yoga-lua` provides a layout core that computes Yoga-like rectangles from Lua
tables, plus a lightweight `ui` layer for declaring reusable interface trees.
Rendering, input dispatch, fonts, images, and engine integration stay in the
host application.

## Status

The project currently covers the supported scope through the runtime polish
milestone:

- Fixed, percentage, min/max, and measured sizing.
- Flex direction, grow, shrink, basis, wrap, gap, justify, align, baseline, and
  align-content behavior.
- Margin, padding, border insets, logical start/end edges, RTL row behavior,
  relative and absolute positioning, display modes, overflow semantics, and
  Yoga-compatible rounded layout output.
- Dirty marking, layout caching, measure caching, a declarative runtime, scoped
  FLIP layout animation helpers, and UI-level fixed-height virtual lists.
- Migrated Yoga fixtures for the supported feature set.
- A Love2D visualizer and RPG-style UI demo.

See [MILESTONES.md](MILESTONES.md) for the live checklist and latest local
verification notes.

## Quick Start

Add `src` to `package.path`, require `yoga`, build a node tree, and calculate
layout:

```lua
package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")

local root = yoga.node({
  width = 300,
  height = 120,
  flexDirection = "row",
  padding = 10,
  gap = 8,
}, {
  yoga.node({ width = 64 }),
  yoga.node({ flex = 1 }),
})

yoga.calculateLayout(root)

print(root.children[1].layout.left, root.children[1].layout.width)
print(root.children[2].layout.left, root.children[2].layout.width)
```

The computed `layout` boxes are parent-relative and contain `left`, `top`,
`width`, `height`, and `hadOverflow`.

## UI Layer

The `ui` module wraps layout nodes with web-like constructors and style merging:

```lua
package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")
local ui = require("ui")

local styles = ui.stylesheet({
  screen = { width = 800, height = 600, flexDirection = "column", padding = 16, gap = 8 },
  body = { flex = 1, flexDirection = "row", gap = 12 },
  sidebar = { width = 220 },
  main = { flex = 1 },
})

local root = ui.div({ class = "screen", styles = styles }, {
  ui.text("Inventory"),
  ui.div({ class = "body", styles = styles }, {
    ui.div({ class = "sidebar", styles = styles }),
    ui.div({ class = "main", styles = styles }),
  }),
})

yoga.calculateLayout(root)
```

For retained host renderers, `ui.createRuntime()` reconciles virtual trees into
stable instances with reusable Yoga nodes. `ui.createFlipAnimator()` can animate
layout changes for nodes with stable `flip` keys.

## Tests

Run the full Lua test suite from the repository root:

```powershell
lua tests/run.lua
```

Fixture tests use local data under `tests/fixtures`. When the ignored upstream
checkout exists at `.upstream/facebook-yoga/`, it can be used as the source for
future Yoga fixture migrations.

## Love2D Demo

The Love2D demo imports the project modules from `src` and renders Yoga-computed
layouts:

```powershell
.\LOVE\love.exe .\examples\love2d
```

Run the non-interactive smoke check:

```powershell
.\LOVE\lovec.exe .\examples\love2d --smoke
```

Open a specific screen or capture a screenshot:

```powershell
.\LOVE\lovec.exe .\examples\love2d --screen inventory
.\LOVE\lovec.exe .\examples\love2d --screen quests --screenshot $env:TEMP\yoga-rpg-quests.png
```

`LOVE/` is a local runtime directory and is ignored by git.

## Benchmarks

Run system Lua and Love2D benchmarks:

```powershell
lua benchmarks/run.lua
.\LOVE\lovec.exe .\benchmarks\love2d
```

Latest recorded benchmark output lives in [BENCHMARKS.md](BENCHMARKS.md).

## Project Docs

- [SPEC.md](SPEC.md) documents scope, architecture, public API expectations,
  and non-goals.
- [ROADMAP.md](ROADMAP.md) describes milestone intent and acceptance criteria.
- [MILESTONES.md](MILESTONES.md) is the live implementation checklist.
- [examples/love2d/README.md](examples/love2d/README.md) describes the visual
  demo controls and layout organization.
