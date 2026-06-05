# yoga-lua Spec

## Assumptions

- The project is a pure Lua implementation of the main Yoga/Flexbox layout ideas for game UI.
- The first target is Lua 5.4. LuaJIT compatibility is desirable but not required for the first milestone.
- The layout engine owns layout calculation only. Rendering, input dispatch, font measurement, and image loading are host-engine responsibilities.
- The public API should feel familiar to web UI authors, but the implementation should stay smaller and more predictable than a browser CSS engine.

## Goals

- Provide a Yoga-like layout core in Lua.
- Provide a component-oriented UI declaration layer on top of the layout core.
- Make layout behavior testable against migrated Yoga test cases where the supported feature set overlaps.
- Keep the core usable without the component layer.

## Non-Goals

- Full browser CSS compatibility.
- DOM selectors, cascading specificity, computed style inheritance, or CSS parsing in the first milestone.
- A React-compatible runtime with hooks, reconciliation, or async rendering.
- Drawing widgets directly from the layout engine.
- Managing scroll offsets, data fetching, or list virtualization inside the layout core.

## Architecture

### Layout Core

The `yoga` module provides:

- `node(style, children)` for building layout trees.
- `calculateLayout(root, width, height)` for computing layout.
- `root.layout` and child `layout` tables with `left`, `top`, `width`, and `height`.

The core data model:

- `style`: layout inputs.
- `children`: ordered child nodes.
- `layout`: computed rectangle.
- `measure`: optional callback for text/image intrinsic size.
- `dirty`: whether layout needs recomputation.

### Component Layer

The `ui` module provides web-like constructors:

- `ui.div(props, children)`
- `ui.text(value, props)`
- `ui.image(props)`
- `ui.button(label, props)`
- `ui.stylesheet(definitions)`

Components are plain Lua functions that return nodes.

Example:

```lua
local ui = require("ui")

local styles = ui.stylesheet({
  screen = { width = 800, height = 600, flexDirection = "column", padding = 16, gap = 8 },
  body = { flex = 1, flexDirection = "row", gap = 12 },
  sidebar = { width = 220 },
  main = { flex = 1 },
})

local function Inventory(props)
  return ui.div({ class = "screen", styles = styles }, {
    ui.text("Inventory"),
    ui.div({ class = "body" }, {
      ui.div({ class = "sidebar" }),
      ui.div({ class = "main" }),
    }),
  })
end
```

## Initial Style Surface

Milestone 1 should cover:

- `width`, `height`
- `minWidth`, `maxWidth`, `minHeight`, `maxHeight`
- `margin`, `padding`
- `flexDirection = "row" | "column"`
- `justifyContent`
- `alignItems`, `alignSelf`
- `flex`, `flexGrow`, `flexShrink`, `flexBasis`
- `gap`
- `position = "relative" | "absolute"`
- `display = "flex" | "none"`
- point values and percentage strings such as `"50%"`

## Scroll and Virtualized Lists

Scroll layout semantics should follow upstream Yoga where Yoga has matching behavior:

- `overflow = "visible" | "hidden" | "scroll"` belongs to the layout core.
- Scroll containers should use Yoga-compatible measurement behavior along the scroll axis.
- The layout result should be able to report when content overflowed, matching Yoga's `hadOverflow` concept.

Lazy loading and virtualized lists belong above the layout core:

- A virtualized scroll view should build only visible items plus a small overscan range.
- Spacer nodes should preserve the full scrollable content size, so Yoga still lays out an ordinary tree.
- Fast jumps should set the target scroll offset directly instead of incrementally scrolling through skipped items.
- Fixed-height item virtualization is the first supported target; variable-height lists need an item height cache and can come later.

## Test Strategy

Tests are grouped into:

- Smoke tests for module loading and component construction.
- Focused Lua tests for each supported layout behavior.
- Migrated Yoga tests stored as Lua fixtures under `tests/fixtures`.
- Behavior tests for dirty marking, measure callbacks, and relayout.

Yoga migration order:

- Basic generated layout cases first: dimension, flex direction, justify content, align items, margin, padding, percentage.
- Complex generated cases next: absolute positioning, flex wrapping, gap, min/max, aspect ratio, rounding.
- Hand-written behavior tests last: measure, measure cache, dirty marking, relayout, computed margin, computed padding.

## Acceptance Criteria

- A game UI screen can be declared with reusable Lua components and no absolute coordinates.
- The layout core can be used directly without `ui`.
- Supported migrated Yoga tests pass within a configurable numeric tolerance.
- Text and image nodes can participate in layout through measure callbacks.
- Re-layout after a style change updates only dirty trees once dirty tracking is implemented.
- The project has a single command that runs all tests.
