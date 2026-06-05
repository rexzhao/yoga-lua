# Milestone Checklist

Update this checklist in the same change set whenever a feature lands, a fixture is migrated, or an unsupported case becomes supported.

Current verification:

- `lua tests/run.lua` -> `ok - 44 tests, 7 skipped`
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
- [ ] Direct `measure` callback support.
- [x] Fixture runner for layout trees.
- [x] Basic local fixtures for fixed layout, spacing, and grow.
- [ ] Broader Yoga dimension/flex-direction/margin/padding fixture migration.

Status: mostly complete; `measure` is the main missing core item.

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
- [x] Love2D overlay is rendered through Yoga.

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
- [ ] `minWidth`.
- [ ] `maxWidth`.
- [ ] `minHeight`.
- [ ] `maxHeight`.
- [ ] `position = "absolute"`.
- [ ] Relative position offsets.
- [ ] `display = "none"`.
- [x] Migrated supported subset of `YGJustifyContentTest`.
- [x] Migrated supported subset of `YGAlignItemsTest`.
- [x] Migrated supported subset of `YGAlignSelfTest`.
- [x] Migrated supported subset of `YGPercentageTest`.
- [ ] Migrate `YGMinMaxDimensionTest`.
- [ ] Migrate `YGAbsolutePositionTest`.

Known skipped cases:

- [ ] `justify_content_row_space_evenly`: skipped pending rounding policy.
- [ ] `align_baseline`: skipped pending baseline alignment.
- [ ] `align_self_baseline`: skipped pending baseline alignment.
- [ ] `percentage_position_left_top`: skipped pending relative position offsets.
- [ ] `percentage_flex_basis`: skipped pending `flexBasis`.
- [ ] `percentage_absolute_position`: skipped pending absolute positioning.
- [ ] `percent_of_minmax_main`: skipped pending min/max constraints.

Status: partially complete.

## Milestone 4: Advanced Flex Behavior

- [ ] `flexShrink`.
- [ ] `flexBasis`.
- [ ] `flexWrap`.
- [ ] `alignContent`.
- [ ] `aspectRatio`.
- [ ] Rounding policy.
- [ ] Baseline alignment.
- [x] `gap` basic support.
- [ ] Migrate supported `YGFlexTest` subset.
- [ ] Migrate supported `YGFlexWrapTest` subset.
- [ ] Migrate supported `YGGapTest` subset.
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

