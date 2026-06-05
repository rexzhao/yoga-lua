# yoga-lua Roadmap

## Milestone 0: Project Skeleton

Success criteria:

- `src/yoga` and `src/ui` modules load in Lua 5.4.
- A smoke test builds a component tree and computes a simple layout.
- Documentation states scope, assumptions, and acceptance criteria.

Verification:

- `lua tests/run.lua`

## Milestone 1: Minimal Flex Layout

Implement:

- Fixed `width` and `height`.
- `flexDirection = "row" | "column"`.
- `padding`, `margin`, and `gap`.
- Basic `flexGrow` distribution.
- Direct `measure` callback support.

Yoga tests to migrate first:

- Dimension cases.
- Flex direction cases.
- Margin and padding cases.
- Simple align-items cases.

Verification:

- Migrated fixture tests pass.
- A vertical menu and horizontal inventory row produce expected rectangles.

## Milestone 2: Web-Like Component API

Implement:

- `ui.div`, `ui.text`, `ui.image`, `ui.button`.
- `stylesheet` and `class` merging.
- Function components.
- Basic event props passthrough such as `onClick`, without dispatch implementation.

Verification:

- A sample inventory screen can be written as reusable components.
- Layout output remains plain core nodes.

## Milestone 3: Yoga Compatibility Expansion

Implement:

- `justifyContent`.
- `alignItems` and `alignSelf`.
- `min/max` constraints.
- Percentage values.
- `position = "absolute"`.
- `display = "none"`.

Yoga tests to migrate:

- `YGJustifyContentTest`.
- `YGAlignItemsTest`.
- `YGAlignSelfTest`.
- `YGMinMaxDimensionTest`.
- `YGPercentageTest`.
- `YGAbsolutePositionTest`.

Verification:

- Migrated Yoga cases pass within numeric tolerance.

## Milestone 4: Advanced Flex Behavior

Implement:

- `flexShrink`.
- `flexBasis`.
- `flexWrap`.
- `alignContent`.
- `aspectRatio`.
- Rounding policy.

Yoga tests to migrate:

- Flex cases.
- Flex wrap cases.
- Gap cases.
- Aspect ratio cases.
- Rounding cases.

Verification:

- Complex generated Yoga fixtures pass or are explicitly marked unsupported with a reason.

## Milestone 5: Runtime Polish

Implement:

- Dirty marking.
- Layout caching.
- Measure caching.
- Benchmarks for large UI trees.

Yoga tests to migrate:

- Measure tests.
- Measure cache tests.
- Dirty marking tests.
- Relayout tests.

Verification:

- Repeated layout avoids unnecessary measure calls.
- Benchmark records layout time for 100, 1,000, and 5,000 nodes.

