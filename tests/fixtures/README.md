# Yoga Fixture Migration

This directory stores Lua fixtures used by `tests/fixture_runner.lua`.

## Purpose

Fixtures should make layout behavior comparable to upstream Yoga tests while keeping unsupported behavior explicit. Prefer migrating a small supported subset from Yoga over inventing broad local-only cases.

## Sources

Use upstream Yoga generated tests and their HTML fixtures as the source of truth:

- `gentest/fixtures/*.html`
- `tests/generated/*.cpp`

When migrating from Yoga, include a `source` table on each case:

```lua
source = {
  repo = "facebook/yoga",
  fixture = "gentest/fixtures/YGJustifyContentTest.html",
  generated = "tests/generated/YGJustifyContentTest.cpp",
  test = "justify_content_row_center",
}
```

## Case Shape

```lua
{
  name = "local_case_name",
  source = {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignItemsTest.html",
    generated = "tests/generated/YGAlignItemsTest.cpp",
    test = "align_items_center",
  },
  root = {
    style = { width = 100, height = 100 },
    children = {
      { style = { width = 10, height = 10 } },
    },
  },
  expect = {
    { left = 0, top = 0, width = 100, height = 100 },
    { left = 0, top = 0, width = 10, height = 10 },
  },
}
```

The expected layout list is pre-order: root first, then descendants in child order.

## Unsupported Cases

Use `skip` when a Yoga fixture is important but not yet supported by this implementation:

```lua
{
  name = "align_items_baseline",
  skip = true,
  unsupportedReason = "baseline alignment is not implemented",
  source = {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignItemsTest.html",
    generated = "tests/generated/YGAlignItemsTest.cpp",
    test = "align_items_baseline",
  },
}
```

Do not silently omit a relevant upstream case once its category is being migrated. Add a skipped fixture with a short reason instead.

## Migration Order

1. Migrate only cases covered by the current feature surface.
2. Add skipped cases for nearby upstream behavior that is intentionally deferred.
3. Enable skipped cases when the feature lands.
4. Keep local smoke fixtures only when they cover project-specific behavior not represented upstream.

