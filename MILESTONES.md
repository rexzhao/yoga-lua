# Milestone Checklist

Update this checklist in the same change set whenever a feature lands, a fixture is migrated, or an unsupported case becomes supported.

Current verification:

- `lua tests/run.lua` -> `ok - 536 tests, 1 skipped`
- `.\LOVE\lovec.exe .\examples\love2d --smoke` -> `ok - love2d visualizer loaded`
- `lua benchmarks/run.lua` and `.\LOVE\lovec.exe .\benchmarks\love2d` -> record 100, 1,000, and 5,000 node layout timings in `BENCHMARKS.md`

## Milestone 0: Project Skeleton

- [x] `src/yoga` module loads.
- [x] `src/ui` module loads.
- [x] Smoke test builds a component tree.
- [x] Smoke test computes a simple layout.
- [x] Project scope and assumptions are documented in `SPEC.md`.
- [x] Project roadmap is documented in `ROADMAP.md`.
- [x] Local Love2D visualizer can smoke-load.

Status: complete.

## Milestone 1: Minimal Flex Layout

- [x] Fixed numeric `width`.
- [x] Fixed numeric `height`.
- [x] `flexDirection = "row"`.
- [x] `flexDirection = "column"`.
- [x] Uniform `padding`.
- [x] Edge/axis padding: `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom`, `paddingHorizontal`, `paddingVertical`.
- [x] Auto size includes border/padding when no content size is specified.
- [x] Uniform `margin`.
- [x] Edge/axis margin: `marginLeft`, `marginRight`, `marginTop`, `marginBottom`, `marginHorizontal`, `marginVertical`.
- [x] Auto margins.
- [x] `gap`.
- [x] Basic `flexGrow`.
- [x] `flex` as grow shorthand.
- [x] Direct `measure` callback support.
- [x] Love2D visual demo for direct `measure` callback.
- [x] Fixture runner for layout trees.
- [x] Basic local fixtures for fixed layout, spacing, and grow.
- [x] Migrated complete `YGDimensionTest` set.
- [x] Migrated complete `YGMarginTest` set.
- [x] Migrated complete `YGPaddingTest` set.
- [x] Migrated basic `YGFlexDirectionTest` column/row/reverse subset.
- [x] Migrated physical-edge `YGFlexDirectionTest` reverse margin/padding/border subset.
- [x] Migrated physical-position `YGFlexDirectionTest` reverse subset.
- [x] Migrated inner absolute-position `YGFlexDirectionTest` reverse subset.
- [x] Migrated inner absolute-spacing `YGFlexDirectionTest` reverse subset.
- [x] Migrated auto-size and percent `YGFlexDirectionTest` subset.
- [x] Migrated complete `YGFlexDirectionTest` set.
- [x] Broader Yoga dimension/flex-direction/margin/padding fixture migration.

Known skipped cases: none.

Status: complete.

## Milestone 2: Web-Like Component API

- [x] `ui.div`.
- [x] `ui.text`.
- [x] `ui.image`.
- [x] `ui.button`.
- [x] `ui.stylesheet`.
- [x] `class` style lookup.
- [x] Inline `style` overrides class style.
- [x] Props are preserved on nodes.
- [x] Function components are usable as plain Lua functions returning nodes.
- [x] Function component behavior has explicit tests.
- [x] Event props such as `onClick` have explicit examples/tests.
- [x] Love2D demos are authored through reusable UI layout modules.
- [x] Love2D selection screen is rendered through Yoga.
- [x] Love2D selection screen supports scrollable overflow.
- [x] Love2D overlay is rendered through Yoga.
- [x] Love2D visualizer can start a named UI with `--case`.
- [x] Love2D visualizer can save a screenshot with `--screenshot`.
- [x] Love2D visualizer derives screen rectangles from parent-relative layout results.

Status: complete.

## Milestone 3: Yoga Compatibility Expansion

- [x] `justifyContent = "flex-start"`.
- [x] `justifyContent = "center"`.
- [x] `justifyContent = "flex-end"`.
- [x] `justifyContent = "space-between"`.
- [x] `justifyContent = "space-around"`.
- [x] `justifyContent = "space-evenly"` basic behavior.
- [x] `alignItems = "stretch"`.
- [x] `alignItems = "flex-start"`.
- [x] `alignItems = "center"`.
- [x] `alignItems = "flex-end"`.
- [x] `alignSelf` override.
- [x] Percentage `width`.
- [x] Percentage `height`.
- [x] Percentage `padding`.
- [x] Percentage `margin`.
- [x] Percentage parser supports leading-dot values while preserving trailing-dot numeric values.
- [x] `minWidth`.
- [x] `maxWidth`.
- [x] `minHeight`.
- [x] `maxHeight`.
- [x] Conflicting min/max constraints honor Yoga-compatible min-wins behavior.
- [x] Love2D visual demo for min/max constraints.
- [x] `position = "absolute"`.
- [x] Love2D visual demo for `position = "absolute"`.
- [x] Absolute nodes can auto-size from children when width/height are not explicit.
- [x] Absolute percentage sizes use Yoga-compatible border-box-minus-border sizing.
- [x] Absolute percentage offsets resolve safely when the parent height is undefined.
- [x] Relative position offsets.
- [x] Love2D visual demo for relative position offsets.
- [x] `display = "none"`.
- [x] Love2D visual demo for `display = "none"`.
- [x] `display = "contents"`.
- [x] Love2D visual demo for `display = "contents"`.
- [x] Numeric `border`/`border*` layout insets.
- [x] Basic RTL layout direction parameter.
- [x] Logical `start`/`end` edges for horizontal position, margin, padding, and border.
- [x] Migrated supported subset of `YGJustifyContentTest`.
- [x] Migrated supported subset of `YGAlignItemsTest`.
- [x] Migrated supported subset of `YGAlignSelfTest`.
- [x] Migrated supported subset of `YGPercentageTest`.
- [x] Migrated supported subset of `YGMinMaxDimensionTest`.
- [x] Migrated supported subset of `YGDisplayTest`.
- [x] Migrated supported subset of `YGAbsolutePositionTest`.
- [x] Layout `left`/`top` values are Yoga-compatible parent-relative coordinates.
- [x] `position_root_with_rtl_should_position_withoutdirection`.

Known skipped cases:

- [ ] `aspect_ratio_does_not_stretch_cross_axis_dim`: skipped because upstream generated test is disabled and conflicts with enabled Yoga aspect-ratio flexed-dimension behavior.

Status: complete for the supported Milestone 3 scope; one upstream-disabled Yoga fixture remains tracked as a known skipped case instead of being counted as implemented.

## Milestone 4: Advanced Flex Behavior

- [x] `flexShrink`.
- [x] Negative `flex` shorthand maps to Yoga-compatible shrink behavior.
- [x] Love2D visual demo for `flexShrink`.
- [x] Auto cross-size from non-wrapped flex children.
- [x] Auto main-size from non-wrapped flex children.
- [x] Partial `flexGrow` remaining-space distribution when total grow is below 1.
- [x] `flexBasis`.
- [x] Positive `flex` shorthand uses Yoga-compatible zero flex basis.
- [x] Love2D visual demo for `flexBasis`.
- [x] `flexWrap` supported row and wrap-reverse behavior.
- [x] Basic row `flexWrap = "wrap"` without `alignContent`.
- [x] `flexWrap = "wrap-reverse"` cross-axis placement.
- [x] Column-direction wrap can overflow extra columns without expanding auto cross-size.
- [x] Nested wrapped children contribute to auto content size.
- [x] Love2D visual demo for basic row `flexWrap`.
- [x] Love2D visual demo for `flexWrap = "wrap-reverse"`.
- [x] `alignContent`.
- [x] Basic row-wrap `alignContent` values.
- [x] `alignContent` nowrap and single-line wrap behavior matches Yoga.
- [x] Love2D visual demo for `alignContent`.
- [x] Migrated complete LTR `YGAlignContentTest` set.
- [x] Migrated supported `YGAlignContentTest` stretch row subset.
- [x] Migrated `YGAlignContentTest` stretch row children and flex variants.
- [x] `alignContent: stretch` line sizing respects child min/max cross-axis constraints.
- [x] Wrapped auto cross-size respects container min/max cross-axis constraints.
- [x] Wrapped auto cross-size min/max constraints account for border and padding.
- [x] `alignContent` line distribution composes with per-line `alignItems`.
- [x] `alignContent: stretch` supports column-direction wrapped lines.
- [x] `alignContent` handles negative cross-axis free space for wrapped rows.
- [x] `alignContent` negative cross-axis free space handles row-reverse wrapped rows.
- [x] `alignContent` negative cross-axis free space composes with cross-axis gap.
- [x] `alignContent` covers flex-start column wrap with zero-height and flexible children.
- [x] `alignContent: stretch` composes with `alignItems` and `alignSelf`.
- [x] `alignContent: stretch` line-box sizing influences nested wrapped auto sizes.
- [x] Migrated supported `YGGapTest` row-wrap `alignContent` subset.
- [x] `aspectRatio`.
- [x] Love2D visual demo for `aspectRatio`.
- [x] Rounding policy.
- [x] Nested rounding preserves Yoga parent-relative layout semantics.
- [x] Root position offsets participate in pixel-grid rounding.
- [x] Baseline alignment.
- [x] Love2D visual demo for baseline alignment.
- [x] `gap` basic support.
- [x] `rowGap` and `columnGap` main-axis support without wrapping.
- [x] Love2D visual demo for `rowGap` and `columnGap`.
- [x] Migrated supported subset of `YGFlexTest`.
- [x] Migrate supported `YGFlexWrapTest` subset.
- [x] Migrate supported `YGGapTest` subset.
- [x] Migrate supported `YGAspectRatioTest` subset.
- [x] Migrate supported `YGRoundingTest` subset.

Known skipped cases: none.

Status: complete for the supported Milestone 4 scope.

## Milestone 5: Runtime Polish

- [x] Dirty marking for style/tree changes.
- [x] Layout caching.
- [x] Measure caching.
- [x] Yoga-compatible `overflow = "hidden" | "scroll"` style semantics.
- [x] Scroll-container measure behavior matches upstream Yoga on the scroll axis.
- [x] Container flex items derive auto main size from content and can overflow definite parents.
- [x] Migrated supported `YGFlexBasisFitContentTest` container overflow subset.
- [x] Migrated supported generated `YGFlexBasisFitContentTest` overflow and scroll-content subset.
- [x] Migrated complete `YGSizeOverflowTest` set.
- [x] Migrated supported `YGJustifyContentTest` overflow row alignment subset.
- [x] Row-reverse overflow spacing for `justifyContent = "space-around" | "space-evenly"`.
- [x] Migrated `YGMinMaxDimensionTest` overflow justify/min/max case.
- [x] Migrated `YGFlexWrapTest` overflowing margin content-sizing case.
- [x] Love2D renderer clips children for `overflow = "hidden" | "scroll"`.
- [x] Layout results expose Yoga-compatible `hadOverflow`.
- [x] UI-level virtualized scroll list builds visible rows, overscan rows, and spacer nodes only.
- [x] Fixed-height virtualized list supports direct jumps without laying out skipped rows.
- [x] Love2D visual demo for a large virtualized scroll list.
- [x] Relayout behavior tests.
- [x] Dirty marking tests.
- [x] Basic measure callback layout tests.
- [x] Migrated supported non-flex `YGMeasureModeTest` subset.
- [x] Migrated supported `YGMeasureTest` min/max and wrapping text subset.
- [x] Single grow/shrink measured child can skip unnecessary measure.
- [x] Migrated supported `YGMeasureTest` direction, padding, fixed-size, flex-shrink, and percent-margin subset.
- [x] Cross-axis auto margins keep measured size instead of stretch.
- [x] Percent padding contributes to measured child border-box size.
- [x] Migrated supported `YGMeasureTest` negative constraint, percent text, nullable measure, and min-width propagation subset.
- [x] `boxSizing = "content-box" | "border-box"` covers measured parent sizing.
- [x] Yoga measure-node leaf invariant is enforced.
- [x] Broader upstream `YGMeasureTest` migration.
- [x] Measure cache tests.
- [x] Overflow and scroll-container measure mode tests.
- [x] `hadOverflow` behavior tests.
- [x] Benchmarks for 100 nodes.
- [x] Benchmarks for 1,000 nodes.
- [x] Benchmarks for 5,000 nodes.
- [x] Virtualized list scroll and jump benchmark.

Known skipped cases: none.

Status: complete.

## Milestone 6: Incremental Layout

- [x] Add an incremental layout benchmark that compares clean cache hits, root-dirty relayout, single-leaf dirty relayout, and single-style-change relayout for the same large tree.
- [x] Record incremental benchmark results for both system Lua 5.4 and Love2D/LuaJIT in `BENCHMARKS.md`.
- [x] Add benchmark scenarios that distinguish measured-node cache reuse from ordinary layout subtree cache reuse.
- [x] Define the cache key for ordinary node layout reuse, including available width, available height, owner size, layout direction, and layout options.
- [x] Cache per-node layout inputs/results after layout, not only the root layout call.
- [x] Skip clean child subtrees when their cached layout inputs still match the current parent constraints.
- [x] Preserve dirty propagation so style/tree changes mark the changed node and ancestors dirty without dirtying unaffected siblings.
- [x] Invalidate cached layout when child order, children, display, position, config, or relevant style constraints change.
- [x] Keep measured-node cache behavior compatible with ordinary layout cache behavior.
- [x] Add tests mirroring upstream dirty propagation behavior from `YGDirtyMarkingTest`.
- [x] Add tests mirroring upstream cached layout/cache hit behavior from `EventsTest` where practical in Lua.
- [x] Add tests proving a dirty leaf relayout does not remeasure or relayout unaffected sibling subtrees when constraints are unchanged.
- [x] Add tests proving changed parent constraints can force clean children to relayout when their cache key no longer matches.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `lua benchmarks/run.lua` and `.\LOVE\lovec.exe .\benchmarks\love2d` after implementation.

Known skipped cases: none.

Status: complete.

## Milestone 7: Allocation Reduction

- [x] Add allocation-focused benchmark coverage for clean-tree, leaf-dirty, branch-dirty, and full relayout scenarios.
- [x] Report benchmark timing and heap growth with multi-sample median/min/max statistics.
- [x] Record allocation benchmark results for Lua 5.4 and Love2D/LuaJIT in `BENCHMARKS.md`.
- [x] Reduce per-layout temporary allocations by reusing scratch child specs where safe.
- [x] Reduce repeated edge/margin result allocations without changing auto-margin mutation semantics.
- [x] Preserve existing incremental layout correctness and dirty propagation behavior.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `lua benchmarks/run.lua` and `.\LOVE\lovec.exe .\benchmarks\love2d` after implementation.

Known skipped cases: none.

Status: complete for the low-GC common-path scope.

## Milestone 8: Incremental Post-Processing

- [x] Add timing coverage for true full-subtree dirty relayout, distinct from root-dirty relayout.
- [x] Add benchmark diagnostics that separate layout traversal from rounding/post-processing cost where practical.
- [x] Skip clean subtree pixel rounding when cached absolute offsets and rounded layout output are still valid.
- [x] Preserve Yoga-compatible rounding behavior for dirty nodes, relative offsets, RTL, absolute children, and display contents.
- [x] Keep overflow/hadOverflow behavior correct after any skipped post-processing.
- [x] Record updated Lua 5.4 and Love2D/LuaJIT benchmark results in `BENCHMARKS.md`.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `lua benchmarks/run.lua` and `.\LOVE\lovec.exe .\benchmarks\love2d` after implementation.

Known skipped cases: none.

Status: complete.

## Milestone 9: Love2D RPG UI Demo

- [x] Replace the static Love2D layout showcase entrypoint with a simple RPG UI demo.
- [x] Keep each RPG interface in its own layout description file.
- [x] Add RPG field HUD, character, skills, inventory, quests, and camp/shop screens.
- [x] Add clickable UI actions for item selection/use/inspection, quest accept/abandon/track, skill selection, rest, and shop purchase.
- [x] Add `--screen` startup support for targeted Love2D screenshot checks.
- [x] Add imagegen-derived base UI PNG assets for panels, buttons, slots, bars, portraits, item art, and map tiles.
- [x] Define a manifest-driven UI asset contract for nine-slice, horizontal three-slice, cover, and contain rendering.
- [x] Document the AI UI asset generation and screenshot QA workflow.
- [x] Inventory item grid wraps slots through Yoga so item count per row responds to available width.
- [x] Inventory category rows are clickable and filter the item grid while keeping the selected detail item in the visible category.
- [x] Hide layout helper frames by default while keeping `--debug-layout` for targeted layout inspection.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `.\LOVE\lovec.exe .\examples\love2d --smoke` after implementation.
- [x] Verify targeted Love2D screenshots for the major RPG screens.

Known skipped cases: none.

Status: complete.

## Milestone 10: Declarative Runtime and Reconciler

Goal: preserve the current declarative layout authoring style while adding a backend-neutral runtime that can diff virtual UI descriptions, reuse mounted instances, and keep renderer-owned objects stable for retained engines such as Unity.

Assumptions:

- The existing direct `yoga.node` and current `ui` APIs stay usable during the transition.
- The first runtime target is correctness and clean boundaries, not a full React/Vue feature set.
- Reconciliation belongs above the `yoga` layout core; the core should continue to receive ordinary nodes, style updates, and tree mutations.
- Animation is intentionally out of this milestone except for recording enough layout snapshots and stable instance identity to support FLIP later.

Planned checklist:

- [x] Define a virtual element model for `div`, `text`, `image`, `button`, and `virtualList` descriptions without immediately creating Yoga nodes.
- [x] Preserve a compatibility path so existing layouts can continue returning Yoga nodes until migrated.
- [x] Add class-list support that ignores `nil`/`false` entries and merges classes from left to right before inline `style`.
- [x] Move style resolution toward an external stylesheet/runtime step so ordinary nodes can specify class names without repeatedly passing `styles`.
- [x] Define mounted instances that hold `type`, resolved key/path identity, props, resolved style, a Yoga node, child instances, renderer handle, visual state, and last layout snapshots.
- [x] Implement mount behavior that converts virtual elements into mounted instances and Yoga nodes.
- [x] Implement reconcile behavior that reuses instances when `key` and `type` match.
- [x] Implement fallback matching by type and child path/index when no explicit key is present.
- [x] Implement child insertion, removal, and reordering without rebuilding unaffected sibling instances.
- [x] Diff resolved layout styles and update Yoga style only when style inputs changed.
- [x] Diff non-layout props such as text, image, event props, debug names, fill/tint, and clipping flags without dirtying Yoga unnecessarily.
- [x] Keep tree mutation dirty propagation compatible with existing incremental layout behavior.
- [x] Define a minimal backend renderer interface: `mount`, `update`, `unmount`, and optional `applyLayout`.
- [x] Adapt the Love2D visualizer to render from the instance tree while preserving existing smoke, debug-layout, hover, click, screenshot, and clipping behavior.
- [x] Add tests for stable instance reuse across repeated renders of the same virtual tree.
- [x] Add tests for keyed dynamic list insertion, deletion, and reorder preserving item instances.
- [x] Add tests for unkeyed static children matching by type/path.
- [x] Add tests proving style-only changes dirty the expected Yoga path while prop-only changes do not force relayout.
- [x] Add tests proving removed instances are unmounted and new instances are mounted exactly once.
- [x] Add a small demo layout that uses class lists and runtime-managed styles without passing `styles` into every node.
- [x] Add runtime/reconciler benchmark coverage for mount, clean rerender, prop-only rerender, style change, and keyed reorder scenarios.
- [x] Record runtime benchmark results for Lua 5.4 and Love2D/LuaJIT in `BENCHMARKS.md`.
- [x] Document the runtime model, key guidance, renderer adapter contract, and the future FLIP/animation hook points.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `.\LOVE\lovec.exe .\examples\love2d --smoke` after implementation.
- [x] Verify at least one targeted Love2D screenshot after the visualizer is migrated to the instance tree.

Known skipped cases: none yet.

Status: complete.

## Milestone 11: FLIP Layout Animation

Goal: provide reusable FLIP-style layout animation on top of runtime instance layout snapshots, while keeping Yoga layout deterministic and keeping renderer-specific drawing concerns outside the animation core.

Planned checklist:

- [x] Add a public `ui.createFlipAnimator` helper backed by a pure Lua `ui.flip` module.
- [x] Compute visual x/y deltas from runtime `previousLayout` and `layout` snapshots.
- [x] Support optional scale deltas for consumers that want size FLIP effects.
- [x] Keep unchanged instances from starting animations and clear animations for instances removed from the synced tree.
- [x] Expose a runtime layout snapshot helper for renderers that adjust layout coordinates after render.
- [x] Integrate FLIP into the Love2D visualizer as a draw-time visual transform without changing Yoga layout or hit testing.
- [x] Scope Love2D FLIP playback to explicitly marked nodes and enable it only for keyed inventory item slots.
- [x] Keep unmarked children visually moving with their marked parent node in the Love2D draw path.
- [x] Add focused unit tests for interpolation, scale deltas, unchanged layouts, and removed instances.
- [x] Add regression coverage proving keyed item FLIP starts after parent resize changes item layout.
- [x] Defer Love2D FLIP playback by one update after sync so window resize cannot consume the animation before its first draw.
- [x] Verify `lua tests/run.lua` after implementation.
- [x] Verify `.\LOVE\lovec.exe .\examples\love2d --smoke` after implementation.
- [x] Verify a targeted Love2D screenshot after the draw path applies visual rects.

Known skipped cases: none.

Status: complete.

## Future Optimization Directions

- [ ] Preprocess style metadata on `node`, `setStyle`, and `updateStyle` so layout can skip repeated hot-path style discovery.
- [ ] Add a conservative simple row/column layout fast path for common game UI nodes after compatibility tests cover the general path.
- [ ] Low priority: investigate a strict GC-free layout mode after low-GC common-path work is stable.
