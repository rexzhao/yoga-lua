local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGRoundingTest.html",
    generated = "tests/generated/YGRoundingTest.cpp",
    test = test,
  }
end

local function flex_grow_child()
  return { style = { flexGrow = 1 } }
end

return {
  {
    name = "rounding_flex_basis_flex_grow_row_width_of_100",
    source = source("rounding_flex_basis_flex_grow_row_width_of_100"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        flex_grow_child(),
        flex_grow_child(),
        flex_grow_child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 33, height = 100 },
      { left = 33, top = 0, width = 34, height = 100 },
      { left = 67, top = 0, width = 33, height = 100 },
    },
  },
  {
    name = "rounding_flex_basis_flex_grow_row_prime_number_width",
    source = source("rounding_flex_basis_flex_grow_row_prime_number_width"),
    root = {
      style = { width = 113, height = 100, flexDirection = "row" },
      children = {
        flex_grow_child(),
        flex_grow_child(),
        flex_grow_child(),
        flex_grow_child(),
        flex_grow_child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 113, height = 100 },
      { left = 0, top = 0, width = 23, height = 100 },
      { left = 23, top = 0, width = 22, height = 100 },
      { left = 45, top = 0, width = 23, height = 100 },
      { left = 68, top = 0, width = 22, height = 100 },
      { left = 90, top = 0, width = 23, height = 100 },
    },
  },
  {
    name = "rounding_flex_basis_flex_shrink_row",
    source = source("rounding_flex_basis_flex_shrink_row"),
    root = {
      style = { width = 101, height = 100, flexDirection = "row" },
      children = {
        { style = { flexBasis = 100, flexShrink = 1 } },
        { style = { flexBasis = 25 } },
        { style = { flexBasis = 25 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 101, height = 100 },
      { left = 0, top = 0, width = 51, height = 100 },
      { left = 51, top = 0, width = 25, height = 100 },
      { left = 76, top = 0, width = 25, height = 100 },
    },
  },
  {
    name = "rounding_flex_basis_overrides_main_size",
    source = source("rounding_flex_basis_overrides_main_size"),
    root = {
      style = { width = 100, height = 113 },
      children = {
        { style = { height = 20, flexGrow = 1, flexBasis = 50 } },
        { style = { height = 10, flexGrow = 1 } },
        { style = { height = 10, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 113 },
      { left = 0, top = 0, width = 100, height = 64 },
      { left = 0, top = 64, width = 100, height = 25 },
      { left = 0, top = 89, width = 100, height = 24 },
    },
  },
  {
    name = "rounding_total_fractial",
    source = source("rounding_total_fractial"),
    root = {
      style = { width = 87.4, height = 113.4 },
      children = {
        { style = { height = 20.3, flexGrow = 0.7, flexBasis = 50.3 } },
        { style = { height = 10, flexGrow = 1.6 } },
        { style = { height = 10.7, flexGrow = 1.1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 87, height = 113 },
      { left = 0, top = 0, width = 87, height = 59 },
      { left = 0, top = 59, width = 87, height = 30 },
      { left = 0, top = 89, width = 87, height = 24 },
    },
  },
  {
    name = "rounding_total_fractial_nested",
    source = source("rounding_total_fractial_nested"),
    root = {
      style = { width = 87.4, height = 113.4 },
      children = {
        {
          style = { height = 20.3, flexGrow = 0.7, flexBasis = 50.3 },
          children = {
            { style = { bottom = 13.3, height = 9.9, flexGrow = 1, flexBasis = 0.3 } },
            { style = { top = 13.3, height = 1.1, flexGrow = 4, flexBasis = 0.3 } },
          },
        },
        { style = { height = 10, flexGrow = 1.6 } },
        { style = { height = 10.7, flexGrow = 1.1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 87, height = 113 },
      { left = 0, top = 0, width = 87, height = 59 },
      { left = 0, top = -13, width = 87, height = 12 },
      { left = 0, top = 25, width = 87, height = 47 },
      { left = 0, top = 59, width = 87, height = 30 },
      { left = 0, top = 89, width = 87, height = 24 },
    },
  },
  {
    name = "rounding_fractial_input_1",
    source = source("rounding_fractial_input_1"),
    root = {
      style = { width = 100, height = 113.4 },
      children = {
        { style = { height = 20, flexGrow = 1, flexBasis = 50 } },
        { style = { height = 10, flexGrow = 1 } },
        { style = { height = 10, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 113 },
      { left = 0, top = 0, width = 100, height = 64 },
      { left = 0, top = 64, width = 100, height = 25 },
      { left = 0, top = 89, width = 100, height = 24 },
    },
  },
  {
    name = "rounding_fractial_input_2",
    source = source("rounding_fractial_input_2"),
    root = {
      style = { width = 100, height = 113.6 },
      children = {
        { style = { height = 20, flexGrow = 1, flexBasis = 50 } },
        { style = { height = 10, flexGrow = 1 } },
        { style = { height = 10, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 114 },
      { left = 0, top = 0, width = 100, height = 65 },
      { left = 0, top = 65, width = 100, height = 24 },
      { left = 0, top = 89, width = 100, height = 25 },
    },
  },
  {
    name = "rounding_fractial_input_3",
    source = source("rounding_fractial_input_3"),
    skip = true,
    unsupportedReason = "root top offset is not implemented",
  },
  {
    name = "rounding_fractial_input_4",
    source = source("rounding_fractial_input_4"),
    skip = true,
    unsupportedReason = "root top offset is not implemented",
  },
  {
    name = "rounding_inner_node_controversy_horizontal",
    source = source("rounding_inner_node_controversy_horizontal"),
    skip = true,
    unsupportedReason = "auto cross-size from children is not implemented",
  },
  {
    name = "rounding_inner_node_controversy_vertical",
    source = source("rounding_inner_node_controversy_vertical"),
    skip = true,
    unsupportedReason = "auto cross-size from children is not implemented",
  },
  {
    name = "rounding_inner_node_controversy_combined",
    source = source("rounding_inner_node_controversy_combined"),
    skip = true,
    unsupportedReason = "auto cross-size from nested children is not implemented",
  },
}
