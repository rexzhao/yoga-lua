local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignContentTest.html",
    generated = "tests/generated/YGAlignContentTest.cpp",
    test = test,
  }
end

local function child()
  return { style = { width = 50, height = 10 } }
end

local function align_content_wrap(name, align_content, tops)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 140,
        height = 120,
        flexWrap = "wrap",
        flexDirection = "row",
        alignContent = align_content,
      },
      children = {
        child(),
        child(),
        child(),
        child(),
        child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 140, height = 120 },
      { left = 0, top = tops[1], width = 50, height = 10 },
      { left = 50, top = tops[1], width = 50, height = 10 },
      { left = 0, top = tops[2], width = 50, height = 10 },
      { left = 50, top = tops[2], width = 50, height = 10 },
      { left = 0, top = tops[3], width = 50, height = 10 },
    },
  }
end

local function align_content_nowrap(name, align_content)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 140,
        height = 120,
        flexDirection = "row",
        alignContent = align_content,
      },
      children = {
        child(),
        child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 140, height = 120 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 10 },
    },
  }
end

local function align_content_singleline(name, align_content, top)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 140,
        height = 120,
        flexWrap = "wrap",
        flexDirection = "row",
        alignContent = align_content,
      },
      children = {
        child(),
        child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 140, height = 120 },
      { left = 0, top = top, width = 50, height = 10 },
      { left = 50, top = top, width = 50, height = 10 },
    },
  }
end

local function negative_space(name, align_content, tops, gap)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 320,
        height = 320,
        border = 60,
      },
      children = {
        {
          style = {
            flexDirection = "row",
            flexWrap = "wrap",
            alignContent = align_content,
            justifyContent = "center",
            height = 10,
            gap = gap,
          },
          children = {
            { style = { width = "80%", height = 20 } },
            { style = { width = "80%", height = 20 } },
            { style = { width = "80%", height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 320, height = 320 },
      { left = 60, top = 60, width = 200, height = 10 },
      { left = 20, top = tops[1], width = 160, height = 20 },
      { left = 20, top = tops[2], width = 160, height = 20 },
      { left = 20, top = tops[3], width = 160, height = 20 },
    },
  }
end

local function stretch_row(name, children, expected)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 150,
        height = 100,
        flexWrap = "wrap",
        flexDirection = "row",
        alignContent = "stretch",
      },
      children = children,
    },
    expect = expected,
  }
end

local function flex_start_column_case(name, height, children, expected)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = height,
        flexWrap = "wrap",
      },
      children = children,
    },
    expect = expected,
  }
end

local function root_cross_axis_case(name, align_content, cross_style, root_height, first_top, second_top, child_left)
  local style = {
    position = "absolute",
    width = 500,
    flexDirection = "row",
    flexWrap = "wrap",
    alignContent = align_content,
  }

  for key, value in pairs(cross_style) do
    style[key] = value
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 400, height = 200 } },
        { style = { width = 400, height = 200 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 500, height = root_height },
      { left = child_left or 0, top = first_top, width = 400, height = 200 },
      { left = child_left or 0, top = second_top, width = 400, height = 200 },
    },
  }
end

local function space_around_align_items(name, align_items, first_top, second_top, third_top)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 300,
        height = 300,
        flexDirection = "row",
        flexWrap = "wrap",
        alignContent = "space-around",
        alignItems = align_items,
      },
      children = {
        { style = { width = 150, height = 50 } },
        { style = { width = 120, height = 100 } },
        { style = { width = 120, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 300, height = 300 },
      { left = 0, top = first_top, width = 150, height = 50 },
      { left = 150, top = second_top, width = 120, height = 100 },
      { left = 0, top = third_top, width = 120, height = 50 },
    },
  }
end

local function stretch_not_overriding_align_items()
  return {
    name = "align_content_stretch_is_not_overriding_align_items",
    source = source("align_content_stretch_is_not_overriding_align_items"),
    root = {
      style = {
        position = "absolute",
        alignContent = "stretch",
      },
      children = {
        {
          style = {
            width = 100,
            height = 100,
            alignItems = "center",
            flexDirection = "row",
            alignContent = "stretch",
          },
          children = {
            { style = { width = 10, height = 10, alignContent = "stretch" } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 45, width = 10, height = 10 },
    },
  }
end

local function stretch_align_items(name, align_items, first_align_self, first_top, second_top, third_top)
  local style = {
    position = "absolute",
    width = 300,
    height = 300,
    flexDirection = "row",
    flexWrap = "wrap",
    alignContent = "stretch",
  }

  if align_items then
    style.alignItems = align_items
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 150, height = 50, alignSelf = first_align_self } },
        { style = { width = 120, height = 100 } },
        { style = { width = 120, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 300, height = 300 },
      { left = 0, top = first_top, width = 150, height = 50 },
      { left = 150, top = second_top, width = 120, height = 100 },
      { left = 0, top = third_top, width = 120, height = 50 },
    },
  }
end

local function stretch_column()
  return {
    name = "align_content_stretch_column",
    source = source("align_content_stretch_column"),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 150,
        flexWrap = "wrap",
        alignContent = "stretch",
      },
      children = {
        {
          style = { height = 50 },
          children = {
            { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%" } },
          },
        },
        { style = { height = 50, flexGrow = 1, flexShrink = 1, flexBasis = "0%" } },
        { style = { height = 50 } },
        { style = { height = 50 } },
        { style = { height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 150 },
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 0, top = 50, width = 50, height = 0 },
      { left = 0, top = 50, width = 50, height = 50 },
      { left = 0, top = 100, width = 50, height = 50 },
      { left = 50, top = 0, width = 50, height = 50 },
    },
  }
end

return {
  align_content_nowrap("align_content_flex_start_nowrap", "flex-start"),
  align_content_wrap("align_content_flex_start_wrap", "flex-start", { 0, 10, 20 }),
  align_content_singleline("align_content_flex_start_wrap_singleline", "flex-start", 0),
  align_content_nowrap("align_content_flex_end_nowrap", "flex-end"),
  align_content_wrap("align_content_flex_end_wrap", "flex-end", { 90, 100, 110 }),
  align_content_singleline("align_content_flex_end_wrap_singleline", "flex-end", 110),
  align_content_nowrap("align_content_center_nowrap", "center"),
  align_content_wrap("align_content_center_wrap", "center", { 45, 55, 65 }),
  align_content_singleline("align_content_center_wrap_singleline", "center", 55),
  align_content_nowrap("align_content_space_between_nowrap", "space-between"),
  align_content_wrap("align_content_space_between_wrap", "space-between", { 0, 55, 110 }),
  align_content_singleline("align_content_space_between_wrap_singleline", "space-between", 0),
  align_content_nowrap("align_content_space_around_nowrap", "space-around"),
  align_content_wrap("align_content_space_around_wrap", "space-around", { 15, 55, 95 }),
  align_content_singleline("align_content_space_around_wrap_singleline", "space-around", 55),
  align_content_nowrap("align_content_space_evenly_nowrap", "space-evenly"),
  align_content_wrap("align_content_space_evenly_wrap", "space-evenly", { 23, 55, 88 }),
  align_content_singleline("align_content_space_evenly_wrap_singleline", "space-evenly", 55),
  negative_space("align_content_flex_start_wrapped_negative_space", "flex-start", { 0, 20, 40 }),
  negative_space("align_content_flex_end_wrapped_negative_space", "flex-end", { -50, -30, -10 }),
  negative_space("align_content_center_wrapped_negative_space", "center", { -25, -5, 15 }),
  negative_space("align_content_space_between_wrapped_negative_space", "space-between", { 0, 20, 40 }),
  negative_space("align_content_space_around_wrapped_negative_space", "space-around", { 0, 20, 40 }),
  negative_space("align_content_space_evenly_wrapped_negative_space", "space-evenly", { 0, 20, 40 }),
  negative_space("align_content_flex_start_wrapped_negative_space_gap", "flex-start", { 0, 30, 60 }, 10),
  negative_space("align_content_flex_end_wrapped_negative_space_gap", "flex-end", { -70, -40, -10 }, 10),
  negative_space("align_content_center_wrapped_negative_space_gap", "center", { -35, -5, 25 }, 10),
  negative_space("align_content_space_between_wrapped_negative_space_gap", "space-between", { 0, 30, 60 }, 10),
  negative_space("align_content_space_around_wrapped_negative_space_gap", "space-around", { 0, 30, 60 }, 10),
  negative_space("align_content_space_evenly_wrapped_negative_space_gap", "space-evenly", { 0, 30, 60 }, 10),
  flex_start_column_case("align_content_flex_start_without_height_on_children", 100, {
    { style = { width = 50 } },
    { style = { width = 50, height = 10 } },
    { style = { width = 50 } },
    { style = { width = 50, height = 10 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 100, height = 100 },
    { left = 0, top = 0, width = 50, height = 0 },
    { left = 0, top = 0, width = 50, height = 10 },
    { left = 0, top = 10, width = 50, height = 0 },
    { left = 0, top = 10, width = 50, height = 10 },
    { left = 0, top = 20, width = 50, height = 0 },
  }),
  flex_start_column_case("align_content_flex_start_with_flex", 120, {
    { style = { width = 50, flexGrow = 1, flexBasis = "0%" } },
    { style = { width = 50, height = 10, flexGrow = 1, flexBasis = "0%" } },
    { style = { width = 50 } },
    { style = { width = 50, flexGrow = 1, flexShrink = 1, flexBasis = "0%" } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 100, height = 120 },
    { left = 0, top = 0, width = 50, height = 40 },
    { left = 0, top = 40, width = 50, height = 40 },
    { left = 0, top = 80, width = 50, height = 0 },
    { left = 0, top = 80, width = 50, height = 40 },
    { left = 0, top = 120, width = 50, height = 0 },
  }),
  stretch_row("align_content_stretch_row", {
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 50 },
    { left = 50, top = 0, width = 50, height = 50 },
    { left = 100, top = 0, width = 50, height = 50 },
    { left = 0, top = 50, width = 50, height = 50 },
    { left = 50, top = 50, width = 50, height = 50 },
  }),
  stretch_row("align_content_stretch_row_with_single_row", {
    { style = { width = 50 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 100 },
    { left = 50, top = 0, width = 50, height = 100 },
  }),
  stretch_row("align_content_stretch_row_with_fixed_height", {
    { style = { width = 50 } },
    { style = { width = 50, height = 60 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 80 },
    { left = 50, top = 0, width = 50, height = 60 },
    { left = 100, top = 0, width = 50, height = 80 },
    { left = 0, top = 80, width = 50, height = 20 },
    { left = 50, top = 80, width = 50, height = 20 },
  }),
  stretch_row("align_content_stretch_row_with_margin", {
    { style = { width = 50 } },
    { style = { width = 50, margin = 10 } },
    { style = { width = 50 } },
    { style = { width = 50, margin = 10 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 40 },
    { left = 60, top = 10, width = 50, height = 20 },
    { left = 0, top = 40, width = 50, height = 40 },
    { left = 60, top = 50, width = 50, height = 20 },
    { left = 0, top = 80, width = 50, height = 20 },
  }),
  stretch_row("align_content_stretch_row_with_padding", {
    { style = { width = 50 } },
    { style = { width = 50, padding = 10 } },
    { style = { width = 50 } },
    { style = { width = 50, padding = 10 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 50 },
    { left = 50, top = 0, width = 50, height = 50 },
    { left = 100, top = 0, width = 50, height = 50 },
    { left = 0, top = 50, width = 50, height = 50 },
    { left = 50, top = 50, width = 50, height = 50 },
  }),
  stretch_row("align_content_stretch_row_with_max_height", {
    { style = { width = 50 } },
    { style = { width = 50, maxHeight = 20 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 50 },
    { left = 50, top = 0, width = 50, height = 20 },
    { left = 100, top = 0, width = 50, height = 50 },
    { left = 0, top = 50, width = 50, height = 50 },
    { left = 50, top = 50, width = 50, height = 50 },
  }),
  stretch_row("align_content_stretch_row_with_min_height", {
    { style = { width = 50 } },
    { style = { width = 50, minHeight = 80 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
    { style = { width = 50 } },
  }, {
    { left = 0, top = 0, width = 150, height = 100 },
    { left = 0, top = 0, width = 50, height = 90 },
    { left = 50, top = 0, width = 50, height = 90 },
    { left = 100, top = 0, width = 50, height = 90 },
    { left = 0, top = 90, width = 50, height = 10 },
    { left = 50, top = 90, width = 50, height = 10 },
  }),
  root_cross_axis_case("align_content_stretch_with_min_cross_axis", "stretch", { minHeight = 500 }, 500, 0, 250),
  root_cross_axis_case("align_content_stretch_with_max_cross_axis", "stretch", { maxHeight = 500 }, 400, 0, 200),
  root_cross_axis_case(
    "align_content_stretch_with_max_cross_axis_violated",
    "stretch",
    { maxHeight = 300 },
    300,
    0,
    200
  ),
  root_cross_axis_case("align_content_space_evenly_with_min_cross_axis", "space-evenly", { minHeight = 500 }, 500, 33, 267),
  root_cross_axis_case("align_content_space_evenly_with_max_cross_axis", "space-evenly", { maxHeight = 500 }, 400, 0, 200),
  root_cross_axis_case(
    "align_content_space_evenly_with_max_cross_axis_violated",
    "space-evenly",
    { maxHeight = 300 },
    300,
    0,
    200
  ),
  root_cross_axis_case(
    "align_content_stretch_with_max_cross_axis_and_border_padding",
    "stretch",
    { maxHeight = 500, border = 5, padding = 2 },
    414,
    7,
    207,
    7
  ),
  root_cross_axis_case(
    "align_content_space_evenly_with_max_cross_axis_violated_padding_and_border",
    "space-evenly",
    { maxHeight = 300, border = 5, padding = 2 },
    300,
    7,
    207,
    7
  ),
  space_around_align_items("align_content_space_around_and_align_items_flex_end_with_flex_wrap", "flex-end", 88, 38, 213),
  space_around_align_items("align_content_space_around_and_align_items_center_with_flex_wrap", "center", 63, 38, 213),
  space_around_align_items(
    "align_content_space_around_and_align_items_flex_start_with_flex_wrap",
    "flex-start",
    38,
    38,
    213
  ),
  stretch_not_overriding_align_items(),
  stretch_align_items("align_content_stretch_and_align_items_flex_end_with_flex_wrap", "flex-end", "flex-start", 0, 75, 250),
  stretch_align_items(
    "align_content_stretch_and_align_items_flex_start_with_flex_wrap",
    "flex-start",
    "flex-end",
    125,
    0,
    175
  ),
  stretch_align_items("align_content_stretch_and_align_items_center_with_flex_wrap", "center", "flex-end", 125, 38, 213),
  stretch_align_items("align_content_stretch_and_align_items_stretch_with_flex_wrap", nil, "flex-end", 125, 0, 175),
  stretch_column(),
}
