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
- `layout`: computed rectangle; `left` and `top` are parent-relative like Yoga, and renderers can derive absolute/screen rectangles by accumulating ancestor offsets.
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

### Declarative Runtime

The direct `ui.div`/`ui.text` constructors remain supported and continue to return Yoga nodes. A higher-level runtime can also be created when a host renderer needs stable mounted objects:

```lua
local ui = require("ui")

local styles = ui.stylesheet({
  screen = { width = 800, height = 600, flexDirection = "column" },
  button = { width = 120, height = 32 },
  button_active = { width = 140 },
})

local runtime = ui.createRuntime({ styles = styles })
local tree = runtime:div({ class = "screen" }, {
  runtime:button("Bag", {
    key = "nav.bag",
    class = { "button", is_active and "button_active" },
  }),
})

local instance = runtime:render(tree, 800, 600)
local root_node = instance.yogaNode
```

Runtime constructors create virtual element descriptions instead of immediately creating Yoga nodes. `render` reconciles a virtual tree into mounted instances. Each instance owns:

- `type`, `key`, and path identity.
- The latest props and resolved style.
- A reusable `yogaNode`.
- Child instances in render order.
- An optional renderer handle returned by the host backend.
- Visual state and layout snapshots for future animation work.

The reconciler reuses an instance when `key` and `type` match. Unkeyed static children fall back to type plus child index/path matching. Dynamic lists, sortable content, cross-container moves, and nodes that need persistent animation or renderer identity should use explicit keys.

Style resolution happens in the runtime before Yoga sees the node:

- `class` may be a string or an array-like list.
- `nil` and `false` class-list entries are ignored.
- Classes merge from left to right.
- Inline `style` overrides class style.
- `props.styles` can override the runtime stylesheet for component-local styles.

The runtime diffs resolved style separately from non-layout props. Style changes update the Yoga node and mark layout dirty through the existing Yoga mutation APIs. Non-layout prop changes such as text, fill, tint, debug names, image references, and event props update instance/node metadata without forcing layout when the resolved style is unchanged.

Host renderers can provide a small retained-backend adapter:

```lua
local renderer = {
  mount = function(self, instance, parent_handle, index)
    return backend_create_object(instance, parent_handle, index)
  end,
  update = function(self, instance, changes)
    backend_update_object(instance.handle, instance, changes)
  end,
  unmount = function(self, instance)
    backend_destroy_object(instance.handle)
  end,
  applyLayout = function(self, instance, rect)
    backend_apply_rect(instance.handle, rect)
  end,
}
```

Love2D can still draw the resulting Yoga node tree directly. Retained engines such as Unity can keep renderer-owned objects alive by storing them in the instance handle.

The runtime records previous and current absolute layout snapshots for reused instances. `ui.createFlipAnimator` uses those snapshots for reusable FLIP-style layout animation:

```lua
local runtime = ui.createRuntime()
local flip = ui.createFlipAnimator({
  duration = 0.18,
  ease = "outCubic",
  filter = function(instance)
    return instance.props and instance.props.flip == true
  end,
})

local root = runtime:render(build_ui(), width, height)
flip:sync(root)

-- Each frame:
flip:update(dt)

-- Renderer draw path:
local left, top, width, height = flip:rect(instance, left, top, width, height)
```

The animator computes visual transforms from old and new layout rectangles:

1. Record the first rectangle before reconcile.
2. Reconcile and calculate the last rectangle.
3. Derive visual transform deltas from old/new rectangles.
4. Animate those visual deltas back to zero without changing the final Yoga layout.

By default the animator applies x/y visual offsets only. Consumers can opt into scale deltas with `animateScale = true`. Renderers decide how to apply the returned visual rect. Love2D uses it at draw time; hit testing still uses the final Yoga layout.

Renderers can scope FLIP to a subset of instances with `filter`. The Love2D RPG demo enables FLIP only for inventory item slots by giving each item a stable key and `flip = true`:

```lua
common.box(ctx, styles, "panel", {
  key = "inventory.item." .. item.id,
  flip = true,
  itemId = item.id,
})
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
