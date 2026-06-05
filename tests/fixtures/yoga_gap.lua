local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGGapTest.html",
    generated = "tests/generated/YGGapTest.cpp",
    test = test,
  }
end

local function flex_child()
  return { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%" } }
end

local function row_gap_justify(name, justify, expected_lefts)
  local style = { width = 100, height = 100, flexDirection = "row", columnGap = 10 }
  if justify then
    style.justifyContent = justify
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = expected_lefts[1], top = 0, width = 20, height = 100 },
      { left = expected_lefts[2], top = 0, width = 20, height = 100 },
      { left = expected_lefts[3], top = 0, width = 20, height = 100 },
    },
  }
end

local function fixed_wrap_align_content(name, align_content, first_line_top, second_line_top)
  local style = {
    width = 100,
    height = 100,
    flexDirection = "row",
    flexWrap = "wrap",
    columnGap = 10,
    rowGap = 20,
  }

  if align_content then
    style.alignContent = align_content
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = first_line_top, width = 20, height = 20 },
      { left = 30, top = first_line_top, width = 20, height = 20 },
      { left = 60, top = first_line_top, width = 20, height = 20 },
      { left = 0, top = second_line_top, width = 20, height = 20 },
      { left = 30, top = second_line_top, width = 20, height = 20 },
      { left = 60, top = second_line_top, width = 20, height = 20 },
    },
  }
end

return {
  {
    name = "column_gap_flexible",
    source = source("column_gap_flexible"),
    root = {
      style = { width = 80, height = 100, flexDirection = "row", columnGap = 10, rowGap = 20 },
      children = {
        flex_child(),
        flex_child(),
        flex_child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 100 },
      { left = 0, top = 0, width = 20, height = 100 },
      { left = 30, top = 0, width = 20, height = 100 },
      { left = 60, top = 0, width = 20, height = 100 },
    },
  },
  {
    name = "column_gap_inflexible",
    source = source("column_gap_inflexible"),
    root = {
      style = { width = 80, height = 100, flexDirection = "row", columnGap = 10 },
      children = {
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 100 },
      { left = 0, top = 0, width = 20, height = 100 },
      { left = 30, top = 0, width = 20, height = 100 },
      { left = 60, top = 0, width = 20, height = 100 },
    },
  },
  {
    name = "column_gap_mixed_flexible",
    source = source("column_gap_mixed_flexible"),
    root = {
      style = { width = 80, height = 100, flexDirection = "row", columnGap = 10 },
      children = {
        { style = { width = 20 } },
        flex_child(),
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 100 },
      { left = 0, top = 0, width = 20, height = 100 },
      { left = 30, top = 0, width = 20, height = 100 },
      { left = 60, top = 0, width = 20, height = 100 },
    },
  },
  {
    name = "column_gap_child_margins",
    source = source("column_gap_child_margins"),
    root = {
      style = { width = 80, height = 100, flexDirection = "row", columnGap = 10 },
      children = {
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginHorizontal = 2 } },
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginHorizontal = 10 } },
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginHorizontal = 15 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 100 },
      { left = 2, top = 0, width = 2, height = 100 },
      { left = 26, top = 0, width = 2, height = 100 },
      { left = 63, top = 0, width = 2, height = 100 },
    },
  },
  {
    name = "column_row_gap_wrapping",
    source = source("column_row_gap_wrapping"),
    root = {
      style = { width = 80, flexDirection = "row", flexWrap = "wrap", columnGap = 10, rowGap = 20 },
      children = {
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 100 },
      { left = 0, top = 0, width = 20, height = 20 },
      { left = 30, top = 0, width = 20, height = 20 },
      { left = 60, top = 0, width = 20, height = 20 },
      { left = 0, top = 40, width = 20, height = 20 },
      { left = 30, top = 40, width = 20, height = 20 },
      { left = 60, top = 40, width = 20, height = 20 },
      { left = 0, top = 80, width = 20, height = 20 },
      { left = 30, top = 80, width = 20, height = 20 },
      { left = 60, top = 80, width = 20, height = 20 },
    },
  },
  {
    name = "column_gap_start_index",
    source = source("column_gap_start_index"),
    root = {
      style = { width = 80, flexDirection = "row", flexWrap = "wrap", columnGap = 10, rowGap = 20 },
      children = {
        { style = { width = 20, height = 20, position = "absolute" } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
        { style = { width = 20, height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 80, height = 20 },
      { left = 0, top = 0, width = 20, height = 20 },
      { left = 0, top = 0, width = 20, height = 20 },
      { left = 30, top = 0, width = 20, height = 20 },
      { left = 60, top = 0, width = 20, height = 20 },
    },
  },
  row_gap_justify("column_gap_justify_flex_start", nil, { 0, 30, 60 }),
  row_gap_justify("column_gap_justify_center", "center", { 10, 40, 70 }),
  row_gap_justify("column_gap_justify_flex_end", "flex-end", { 20, 50, 80 }),
  row_gap_justify("column_gap_justify_space_between", "space-between", { 0, 40, 80 }),
  row_gap_justify("column_gap_justify_space_around", "space-around", { 3, 40, 77 }),
  row_gap_justify("column_gap_justify_space_evenly", "space-evenly", { 5, 40, 75 }),
  fixed_wrap_align_content("column_gap_wrap_align_flex_start", nil, 0, 40),
  fixed_wrap_align_content("column_gap_wrap_align_center", "center", 20, 60),
  fixed_wrap_align_content("column_gap_wrap_align_flex_end", "flex-end", 40, 80),
  fixed_wrap_align_content("column_gap_wrap_align_space_between", "space-between", 0, 80),
  fixed_wrap_align_content("column_gap_wrap_align_space_around", "space-around", 10, 70),
  {
    name = "column_gap_wrap_align_stretch",
    source = source("column_gap_wrap_align_stretch"),
    root = {
      style = { width = 300, height = 300, flexDirection = "row", flexWrap = "wrap", columnGap = 5, alignContent = "stretch" },
      children = {
        { style = { minWidth = 60, flexGrow = 1 } },
        { style = { minWidth = 60, flexGrow = 1 } },
        { style = { minWidth = 60, flexGrow = 1 } },
        { style = { minWidth = 60, flexGrow = 1 } },
        { style = { minWidth = 60, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 300, height = 300 },
      { left = 0, top = 0, width = 71, height = 150 },
      { left = 76, top = 0, width = 72, height = 150 },
      { left = 153, top = 0, width = 71, height = 150 },
      { left = 229, top = 0, width = 71, height = 150 },
      { left = 0, top = 150, width = 300, height = 150 },
    },
  },
  {
    name = "column_gap_determines_parent_width",
    source = source("column_gap_determines_parent_width"),
    skip = true,
    unsupportedReason = "auto main-size from children is not implemented",
  },
  {
    name = "row_gap_align_items_stretch",
    source = source("row_gap_align_items_stretch"),
    root = {
      style = {
        width = 100,
        height = 200,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "stretch",
        alignContent = "stretch",
        columnGap = 10,
        rowGap = 20,
      },
      children = {
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 200 },
      { left = 0, top = 0, width = 20, height = 90 },
      { left = 30, top = 0, width = 20, height = 90 },
      { left = 60, top = 0, width = 20, height = 90 },
      { left = 0, top = 110, width = 20, height = 90 },
      { left = 30, top = 110, width = 20, height = 90 },
      { left = 60, top = 110, width = 20, height = 90 },
    },
  },
  {
    name = "row_gap_align_items_end",
    source = source("row_gap_align_items_end"),
    root = {
      style = {
        width = 100,
        height = 200,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "flex-end",
        columnGap = 10,
        rowGap = 20,
      },
      children = {
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 200 },
      { left = 0, top = 0, width = 20, height = 0 },
      { left = 30, top = 0, width = 20, height = 0 },
      { left = 60, top = 0, width = 20, height = 0 },
      { left = 0, top = 20, width = 20, height = 0 },
      { left = 30, top = 20, width = 20, height = 0 },
      { left = 60, top = 20, width = 20, height = 0 },
    },
  },
  {
    name = "row_gap_column_child_margins",
    source = source("row_gap_column_child_margins"),
    root = {
      style = { width = 100, height = 200, rowGap = 10 },
      children = {
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginVertical = 2 } },
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginVertical = 10 } },
        { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginVertical = 15 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 200 },
      { left = 0, top = 2, width = 100, height = 42 },
      { left = 0, top = 66, width = 100, height = 42 },
      { left = 0, top = 143, width = 100, height = 42 },
    },
  },
  {
    name = "row_gap_determines_parent_height",
    source = source("row_gap_determines_parent_height"),
    skip = true,
    unsupportedReason = "auto main-size from children is not implemented",
  },
}
