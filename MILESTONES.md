# Milestone Checklist

Update this checklist in the same change set whenever a feature lands, a fixture is migrated, or an unsupported case becomes supported.

Current verification:

- `lua tests/run.lua` -> `ok - 140 tests, 31 skipped`
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
- [ ] Function component behavior has explicit tests.
- [ ] Event props such as `onClick` have explicit examples/tests.
- [x] Love2D demos are authored through reusable UI layout modules.
- [x] Love2D selection screen is rendered through Yoga.
- [x] Love2D selection screen supports scrollable overflow.
- [x] Love2D overlay is rendered through Yoga.
- [x] Love2D visualizer can start a named UI with `--case`.
- [x] Love2D visualizer can save a screenshot with `--screenshot`.

Status: mostly complete; explicit tests/examples for function components and event props remain.

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
- [x] Relative position offsets.
- [x] Love2D visual demo for relative position offsets.
- [x] `display = "none"`.
- [x] Love2D visual demo for `display = "none"`.
- [x] Migrated supported subset of `YGJustifyContentTest`.
- [x] Migrated supported subset of `YGAlignItemsTest`.
- [x] Migrated supported subset of `YGAlignSelfTest`.
- [x] Migrated supported subset of `YGPercentageTest`.
- [x] Migrated supported subset of `YGMinMaxDimensionTest`.
- [x] Migrated supported subset of `YGDisplayTest`.
- [x] Migrated supported subset of `YGAbsolutePositionTest`.

Known skipped cases:

- [ ] `justify_content_row_space_evenly`: skipped pending rounding policy.
- [ ] `align_baseline`: skipped pending baseline alignment.
- [ ] `align_self_baseline`: skipped pending baseline alignment.
- [ ] `display_contents`: skipped pending `display = "contents"`.
- [ ] `display_contents_fixed_size`: skipped pending `display = "contents"`.
- [ ] `display_contents_with_margin`: skipped pending `display = "contents"`.
- [ ] `display_contents_with_padding`: skipped pending `display = "contents"`.
- [ ] `display_contents_with_position`: skipped pending `display = "contents"`.
- [ ] `display_contents_with_position_absolute`: skipped pending `display = "contents"`.
- [ ] `display_contents_nested`: skipped pending `display = "contents"`.
- [ ] `display_contents_with_siblings`: skipped pending `display = "contents"`.
- [ ] `do_not_clamp_height_of_absolute_node_to_height_of_its_overflow_hidden_parent`: skipped pending absolute auto-size from children.
- [ ] `absolute_layout_within_border`: skipped pending border support.
- [ ] `position_root_with_rtl_should_position_withoutdirection`: skipped pending RTL direction support.
- [ ] `absolute_layout_in_wrap_reverse_column_container`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_row_container`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_column_container_flex_end`: skipped pending wrap-reverse support.
- [ ] `absolute_layout_in_wrap_reverse_row_container_flex_end`: skipped pending wrap-reverse support.
- [ ] `percent_absolute_position_infinite_height`: skipped pending undefined-height percentage handling.
- [ ] `absolute_layout_percentage_height_based_on_padded_parent`: skipped pending border support.
- [ ] `absolute_layout_percentage_height_based_on_padded_parent_and_align_items_center`: skipped pending border support.
- [ ] `absolute_layout_padding`: skipped pending auto-size parent layout.
- [ ] `absolute_layout_border`: skipped pending border support.
- [ ] `absolute_layout_column_reverse_margin_border`: skipped pending column-reverse and border support.
- [ ] `flex_shrink_to_zero`: skipped pending auto cross-size from children.
- [ ] `flex_grow_less_than_factor_one`: skipped pending partial remaining-space distribution for total `flexGrow` below 1.
- [ ] `column_row_gap_wrapping`: skipped pending `flexWrap`.
- [ ] `column_gap_start_index`: skipped pending `flexWrap`.
- [ ] `column_gap_justify_space_around`: skipped pending rounding policy.
- [ ] `column_gap_determines_parent_width`: skipped pending auto main-size from children.
- [ ] `row_gap_determines_parent_height`: skipped pending auto main-size from children.

Status: partially complete.

## Milestone 4: Advanced Flex Behavior

- [x] `flexShrink`.
- [x] Love2D visual demo for `flexShrink`.
- [x] `flexBasis`.
- [x] Love2D visual demo for `flexBasis`.
- [ ] `flexWrap`.
- [ ] `alignContent`.
- [ ] `aspectRatio`.
- [ ] Rounding policy.
- [ ] Baseline alignment.
- [x] `gap` basic support.
- [x] `rowGap` and `columnGap` main-axis support without wrapping.
- [x] Love2D visual demo for `rowGap` and `columnGap`.
- [x] Migrated supported subset of `YGFlexTest`.
- [ ] Migrate supported `YGFlexWrapTest` subset.
- [x] Migrate supported `YGGapTest` subset.
- [ ] Migrate supported `YGAspectRatioTest` subset.
- [ ] Migrate supported `YGRoundingTest` subset.

Status: mostly not started.

## Milestone 5: Runtime Polish

- [ ] Dirty marking for style/tree changes.
- [ ] Layout caching.
- [ ] Measure caching.
- [ ] Relayout behavior tests.
- [ ] Dirty marking tests.
- [ ] Measure tests.
- [ ] Measure cache tests.
- [ ] Benchmarks for 100 nodes.
- [ ] Benchmarks for 1,000 nodes.
- [ ] Benchmarks for 5,000 nodes.

Status: not started.
