local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGFlexTest.html",
    generated = "tests/generated/YGFlexTest.cpp",
    test = test,
  }
end

return {
  {
    name = "flex_basis_flex_grow_column",
    source = source("flex_basis_flex_grow_column"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { flexBasis = 50, flexGrow = 1 } },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 75 },
      { left = 0, top = 75, width = 100, height = 25 },
    },
  },
  {
    name = "flex_shrink_flex_grow_row",
    source = source("flex_shrink_flex_grow_row"),
    root = {
      style = { width = 500, height = 500, flexDirection = "row" },
      children = {
        { style = { width = 500, height = 100, flexShrink = 1 } },
        { style = { width = 500, height = 100, flexShrink = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 500, height = 500 },
      { left = 0, top = 0, width = 250, height = 100 },
      { left = 250, top = 0, width = 250, height = 100 },
    },
  },
  {
    name = "flex_shrink_flex_grow_child_flex_shrink_other_child",
    source = source("flex_shrink_flex_grow_child_flex_shrink_other_child"),
    root = {
      style = { width = 500, height = 500, flexDirection = "row" },
      children = {
        { style = { width = 500, height = 100, flexShrink = 1 } },
        { style = { width = 500, height = 100, flexGrow = 1, flexShrink = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 500, height = 500 },
      { left = 0, top = 0, width = 250, height = 100 },
      { left = 250, top = 0, width = 250, height = 100 },
    },
  },
  {
    name = "flex_basis_flex_grow_row",
    source = source("flex_basis_flex_grow_row"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexBasis = 50, flexGrow = 1 } },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 75, height = 100 },
      { left = 75, top = 0, width = 25, height = 100 },
    },
  },
  {
    name = "flex_basis_flex_shrink_column",
    source = source("flex_basis_flex_shrink_column"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { flexBasis = 100, flexShrink = 1 } },
        { style = { flexBasis = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 50 },
      { left = 0, top = 50, width = 100, height = 50 },
    },
  },
  {
    name = "flex_basis_flex_shrink_row",
    source = source("flex_basis_flex_shrink_row"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexBasis = 100, flexShrink = 1 } },
        { style = { flexBasis = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 100 },
      { left = 50, top = 0, width = 50, height = 100 },
    },
  },
  {
    name = "flex_shrink_to_zero",
    source = source("flex_shrink_to_zero"),
    root = {
      style = { height = 75 },
      children = {
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 50, flexShrink = 1 } },
        { style = { width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 50, height = 75 },
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 0, top = 50, width = 50, height = 0 },
      { left = 0, top = 50, width = 50, height = 50 },
    },
  },
  {
    name = "flex_basis_overrides_main_size",
    source = source("flex_basis_overrides_main_size"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { height = 20, flexGrow = 1, flexBasis = 50 } },
        { style = { height = 10, flexGrow = 1 } },
        { style = { height = 10, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 60 },
      { left = 0, top = 60, width = 100, height = 20 },
      { left = 0, top = 80, width = 100, height = 20 },
    },
  },
  {
    name = "flex_grow_shrink_at_most",
    source = source("flex_grow_shrink_at_most"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        {
          style = {},
          children = {
            { style = { flexGrow = 1, flexShrink = 1 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 0 },
      { left = 0, top = 0, width = 100, height = 0 },
    },
  },
  {
    name = "flex_grow_less_than_factor_one",
    source = source("flex_grow_less_than_factor_one"),
    skip = true,
    unsupportedReason = "partial remaining-space distribution for total flexGrow below 1 is not implemented",
  },
}
