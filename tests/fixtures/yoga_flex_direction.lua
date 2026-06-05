local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGFlexDirectionTest.html",
    generated = "tests/generated/YGFlexDirectionTest.cpp",
    test = test,
  }
end

local function column_case(name, direction, tops)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        flexDirection = direction,
      },
      children = {
        { style = { height = 10 } },
        { style = { height = 10 } },
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = tops[1], width = 100, height = 10 },
      { left = 0, top = tops[2], width = 100, height = 10 },
      { left = 0, top = tops[3], width = 100, height = 10 },
    },
  }
end

local function row_case(name, direction, lefts)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        flexDirection = direction,
      },
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = lefts[1], top = 0, width = 10, height = 100 },
      { left = lefts[2], top = 0, width = 10, height = 100 },
      { left = lefts[3], top = 0, width = 10, height = 100 },
    },
  }
end

local function row_reverse_spacing(name, style, lefts)
  style.position = "absolute"
  style.width = 100
  style.height = 100
  style.flexDirection = "row-reverse"

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = style.marginLeft or 0, top = 0, width = 100, height = 100 },
      { left = lefts[1], top = 0, width = 10, height = 100 },
      { left = lefts[2], top = 0, width = 10, height = 100 },
      { left = lefts[3], top = 0, width = 10, height = 100 },
    },
  }
end

local function column_reverse_spacing(name, style, top)
  style.position = "absolute"
  style.width = 100
  style.height = 100
  style.flexDirection = "column-reverse"

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = 0, top = style.marginTop or 0, width = 100, height = 100 },
      { left = 0, top = top, width = 10, height = 0 },
      { left = 0, top = top, width = 10, height = 0 },
      { left = 0, top = top, width = 10, height = 0 },
    },
  }
end

return {
  column_case("flex_direction_column", nil, { 0, 10, 20 }),
  row_case("flex_direction_row", "row", { 0, 10, 20 }),
  column_case("flex_direction_column_reverse", "column-reverse", { 90, 80, 70 }),
  row_case("flex_direction_row_reverse", "row-reverse", { 90, 80, 70 }),
  row_reverse_spacing("flex_direction_row_reverse_margin_left", { marginLeft = 100 }, { 90, 80, 70 }),
  row_reverse_spacing("flex_direction_row_reverse_margin_right", { marginRight = 100 }, { 90, 80, 70 }),
  column_reverse_spacing("flex_direction_column_reverse_margin_top", { marginTop = 100 }, 100),
  column_reverse_spacing("flex_direction_column_reverse_margin_bottom", { marginBottom = 100 }, 100),
  row_reverse_spacing("flex_direction_row_reverse_padding_left", { paddingLeft = 100 }, { 90, 80, 70 }),
  row_reverse_spacing("flex_direction_row_reverse_padding_right", { paddingRight = 100 }, { -10, -20, -30 }),
  column_reverse_spacing("flex_direction_column_reverse_padding_top", { paddingTop = 100 }, 100),
  column_reverse_spacing("flex_direction_column_reverse_padding_bottom", { paddingBottom = 100 }, 0),
  row_reverse_spacing("flex_direction_row_reverse_border_left", { borderLeft = 100 }, { 90, 80, 70 }),
  row_reverse_spacing("flex_direction_row_reverse_border_right", { borderRight = 100 }, { -10, -20, -30 }),
  column_reverse_spacing("flex_direction_column_reverse_border_top", { borderTop = 100 }, 100),
  column_reverse_spacing("flex_direction_column_reverse_border_bottom", { borderBottom = 100 }, 0),
}
