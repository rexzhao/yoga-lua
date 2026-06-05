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

local function root_cross_axis_case(name, align_content, cross_style, root_height, first_top, second_top)
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
      { left = 0, top = first_top, width = 400, height = 200 },
      { left = 0, top = second_top, width = 400, height = 200 },
    },
  }
end

return {
  align_content_wrap("align_content_flex_start_wrap", "flex-start", { 0, 10, 20 }),
  align_content_wrap("align_content_flex_end_wrap", "flex-end", { 90, 100, 110 }),
  align_content_wrap("align_content_center_wrap", "center", { 45, 55, 65 }),
  align_content_wrap("align_content_space_between_wrap", "space-between", { 0, 55, 110 }),
  align_content_wrap("align_content_space_around_wrap", "space-around", { 15, 55, 95 }),
  align_content_wrap("align_content_space_evenly_wrap", "space-evenly", { 23, 55, 88 }),
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
}
