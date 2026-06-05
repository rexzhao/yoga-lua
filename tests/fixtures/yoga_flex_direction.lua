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

local function reverse_position(name, direction, position_style, child_left, child_top, nested_lefts, nested_top)
  local child_style = {
    width = 100,
    height = 100,
    flexDirection = direction,
  }

  for key, value in pairs(position_style) do
    child_style[key] = value
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        {
          style = child_style,
          children = {
            { style = { width = 10 } },
            { style = { width = 10 } },
            { style = { width = 10 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = child_left, top = child_top, width = 100, height = 100 },
      { left = nested_lefts[1], top = nested_top, width = 10, height = direction == "row-reverse" and 100 or 0 },
      { left = nested_lefts[2], top = nested_top, width = 10, height = direction == "row-reverse" and 100 or 0 },
      { left = nested_lefts[3], top = nested_top, width = 10, height = direction == "row-reverse" and 100 or 0 },
    },
  }
end

local function inner_absolute_position(name, direction, position_style, absolute_left, absolute_top, flow_lefts, flow_top)
  local absolute_style = {
    position = "absolute",
    width = 10,
    height = 10,
  }

  for key, value in pairs(position_style) do
    absolute_style[key] = value
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        {
          style = { width = 100, height = 100, flexDirection = direction },
          children = {
            { style = absolute_style },
            { style = { width = 10 } },
            { style = { width = 10 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = absolute_left, top = absolute_top, width = 10, height = 10 },
      { left = flow_lefts[1], top = flow_top, width = 10, height = direction == "row-reverse" and 100 or 0 },
      { left = flow_lefts[2], top = flow_top, width = 10, height = direction == "row-reverse" and 100 or 0 },
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
  reverse_position("flex_direction_row_reverse_pos_left", "row-reverse", { left = 100 }, 100, 0, { 90, 80, 70 }, 0),
  reverse_position("flex_direction_row_reverse_pos_right", "row-reverse", { right = 100 }, -100, 0, { 90, 80, 70 }, 0),
  reverse_position("flex_direction_column_reverse_pos_top", "column-reverse", { top = 100 }, 0, 100, { 0, 0, 0 }, 100),
  reverse_position(
    "flex_direction_column_reverse_pos_bottom",
    "column-reverse",
    { bottom = 100 },
    0,
    -100,
    { 0, 0, 0 },
    100
  ),
  inner_absolute_position("flex_direction_row_reverse_inner_pos_left", "row-reverse", { left = 10 }, 10, 0, { 90, 80 }, 0),
  inner_absolute_position("flex_direction_row_reverse_inner_pos_right", "row-reverse", { right = 10 }, 80, 0, { 90, 80 }, 0),
  inner_absolute_position("flex_direction_col_reverse_inner_pos_top", "column-reverse", { top = 10 }, 0, 10, { 0, 0 }, 100),
  inner_absolute_position(
    "flex_direction_col_reverse_inner_pos_bottom",
    "column-reverse",
    { bottom = 10 },
    0,
    80,
    { 0, 0 },
    100
  ),
}
