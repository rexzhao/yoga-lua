# Milestone Checklist

Update this checklist in the same change set whenever a feature lands, a fixture is migrated, or an unsupported case becomes supported.

Current verification:

- `lua tests/run.lua` -> `ok - 211 tests, 15 skipped`
- `.\LOVE\lovec.exe .\examples\love2d --smoke` -> `ok - love2d visualizer loaded`

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
- [x] Uniform `margin`.
- [x] Edge/axis margin: `marginLeft`, `marginRight`, `marginTop`, `marginBottom`, `marginHorizontal`, `marginVertical`.
- [x] `gap`.
- [x] Basic `flexGrow`.
- [x] `flex` as grow shorthand.
- [x] Direct `measure` callback support.
- [x] Love2D visual demo for direct `measure` callback.
- [x] Fixture runner for layout trees.
- [x] Basic local fixtures for fixed layout, spacing, and grow.
- [ ] Broader Yoga dimension/flex-direction/margin/padding fixture migration.

Status: mostly complete; broader Yoga fixture migration remains.

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
- [x] `minWidth`.
- [x] `maxWidth`.
- [x] `minHeight`.
- [x] `maxHeight`.
- [x] Love2D visual demo for min/max constraints.
- [x] `position = "absolute"`.
- [x] Love2D visual demo for `position = "absolute"`.
- [x] Absolute nodes can auto-size from children when width/height are not explicit.
- [x] Relative position offsets.
- [x] Love2D visual demo for relative position offsets.
- [x] `display = "none"`.
- [x] Love2D visual demo for `display = "none"`.
- [x] `display = "contents"`.
- [x] Love2D visual demo for `display = "contents"`.
- [x] Migrated supported subset of `YGJustifyContentTest`.
- [x] Migrated supported subset of `YGAlignItemsTest`.
- [x] Migrated supported subset of `YGAlignSelfTest`.
- [x] Migrated supported subset of `YGPercentageTest`.
- [x] Migrated supported subset of `YGMinMaxDimensionTest`.
- [x] Migrated supported subset of `YGDisplayTest`.
- [x] Migrated supported subset of `YGAbsolutePositionTest`.
- [x] Layout `left`/`top` values are Yoga-compatible parent-relative coordinates.

Known skipped cases:

- [ ] `absolute_layout_within_border`: skipped pending border support.
- [ ] `position_root_with_rtl_should_position_withoutdirection`: skipped pending RTL direction support.
- [ ] `absolute_layout_in_wrap_reverse_column_container`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_row_container`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_column_container_flex_end`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_row_container_flex_end`: skipped pending wrap-reverse support.
- [ ] `percent_absolute_position_infinite_height`: skipped pending undefined-height percentage handling.
- [ ] `absolute_layout_percentage_height_based_on_padded_parent`: skipped pending border support.
- [ ] `absolute_layout_percentage_height_based_on_padded_parent_and_align_items_center`: skipped pending border support.
- [ ] `absolute_layout_border`: skipped pending border support.
- [ ] `absolute_layout_column_reverse_margin_border`: skipped pending column-reverse and border support.
- [ ] `aspect_ratio_does_not_stretch_cross_axis_dim`: skipped because upstream generated test is disabled.
- [ ] `wrap_column`: skipped because upstream generated test is disabled.
- [ ] `flex_wrap_wrap_to_child_height`: skipped pending auto content sizing from nested wrapped children.
- [ ] `wrap_reverse_row_align_content_flex_start`: skipped pending wrap-reverse.

Status: partially complete.

## Milestone 4: Advanced Flex Behavior

- [x] `flexShrink`.
- [x] Love2D visual demo for `flexShrink`.
- [x] Auto cross-size from non-wrapped flex children.
- [x] Auto main-size from non-wrapped flex children.
- [x] Partial `flexGrow` remaining-space distribution when total grow is below 1.
- [x] `flexBasis`.
- [x] Love2D visual demo for `flexBasis`.
- [ ] `flexWrap`.
- [x] Basic row `flexWrap = "wrap"` without `alignContent`.
- [x] Love2D visual demo for basic row `flexWrap`.
- [ ] `alignContent`.
- [x] Basic row-wrap `alignContent` values.
- [x] Love2D visual demo for `alignContent`.
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

Status: partially complete.

## Milestone 5: Runtime Polish

- [ ] Dirty marking for style/tree changes.
- [ ] Layout caching.
- [ ] Measure caching.
- [ ] Yoga-compatible `overflow = "hidden" | "scroll"` style semantics.
- [ ] Scroll-container measure behavior matches upstream Yoga on the scroll axis.
- [ ] Layout results expose Yoga-compatible `hadOverflow`.
- [ ] UI-level virtualized scroll list builds visible rows, overscan rows, and spacer nodes only.
- [ ] Fixed-height virtualized list supports direct jumps without laying out skipped rows.
- [ ] Love2D visual demo for a large virtualized scroll list.
- [ ] Relayout behavior tests.
- [ ] Dirty marking tests.
- [ ] Measure tests.
- [ ] Measure cache tests.
- [ ] Overflow and scroll-container measure mode tests.
- [ ] `hadOverflow` behavior tests.
- [ ] Benchmarks for 100 nodes.
- [ ] Benchmarks for 1,000 nodes.
- [ ] Benchmarks for 5,000 nodes.
- [ ] Virtualized list scroll and jump benchmark.

Status: not started.
