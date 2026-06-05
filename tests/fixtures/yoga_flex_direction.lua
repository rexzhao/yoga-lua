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

local function column_no_height()
  return {
    name = "flex_direction_column_no_height",
    source = source("flex_direction_column_no_height"),
    root = {
      style = {
        position = "absolute",
        width = 100,
      },
      children = {
        { style = { height = 10 } },
        { style = { height = 10 } },
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 30 },
      { left = 0, top = 0, width = 100, height = 10 },
      { left = 0, top = 10, width = 100, height = 10 },
      { left = 0, top = 20, width = 100, height = 10 },
    },
  }
end

local function row_no_width()
  return {
    name = "flex_direction_row_no_width",
    source = source("flex_direction_row_no_width"),
    root = {
      style = {
        position = "absolute",
        height = 100,
        flexDirection = "row",
      },
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 30, height = 100 },
      { left = 0, top = 0, width = 10, height = 100 },
      { left = 10, top = 0, width = 10, height = 100 },
      { left = 20, top = 0, width = 10, height = 100 },
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

local function inner_absolute_spacing(name, direction, spacing_style, absolute_left, absolute_top, flow_lefts, flow_top)
  local absolute_style = {
    position = "absolute",
    width = 10,
    height = 10,
  }

  for key, value in pairs(spacing_style) do
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

local function alternating_with_percent()
  return {
    name = "flex_direction_alternating_with_percent",
    source = source("flex_direction_alternating_with_percent"),
    root = {
      style = { position = "absolute", width = 200, height = 300 },
      children = {
        {
          style = {
            width = "50%",
            height = "50%",
            left = "10%",
            top = "10%",
            flexDirection = "row",
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 300 },
      { left = 20, top = 30, width = 100, height = 150 },
    },
  }
end

local function unsupported_logical_edge(name)
  return {
    name = name,
    source = source(name),
    skip = true,
    unsupportedReason = "logical start/end edges and RTL direction are not implemented",
  }
end

return {
  column_no_height(),
  row_no_width(),
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
  inner_absolute_spacing("flex_direction_row_reverse_inner_margin_left", "row-reverse", { marginLeft = 10 }, 90, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_row_reverse_inner_margin_right", "row-reverse", { marginRight = 10 }, 80, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_col_reverse_inner_margin_top", "column-reverse", { marginTop = 10 }, 0, 90, { 0, 0 }, 100),
  inner_absolute_spacing("flex_direction_col_reverse_inner_margin_bottom", "column-reverse", { marginBottom = 10 }, 0, 80, { 0, 0 }, 100),
  inner_absolute_spacing("flex_direction_row_reverse_inner_border_left", "row-reverse", { borderLeft = 10 }, 90, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_row_reverse_inner_border_right", "row-reverse", { borderRight = 10 }, 90, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_col_reverse_inner_border_top", "column-reverse", { borderTop = 10 }, 0, 90, { 0, 0 }, 100),
  inner_absolute_spacing("flex_direction_col_reverse_inner_border_bottom", "column-reverse", { borderBottom = 10 }, 0, 90, { 0, 0 }, 100),
  inner_absolute_spacing("flex_direction_row_reverse_inner_padding_left", "row-reverse", { paddingLeft = 10 }, 90, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_row_reverse_inner_padding_right", "row-reverse", { paddingRight = 10 }, 90, 0, { 90, 80 }, 0),
  inner_absolute_spacing("flex_direction_col_reverse_inner_padding_top", "column-reverse", { paddingTop = 10 }, 0, 90, { 0, 0 }, 100),
  inner_absolute_spacing("flex_direction_col_reverse_inner_padding_bottom", "column-reverse", { paddingBottom = 10 }, 0, 90, { 0, 0 }, 100),
  alternating_with_percent(),
  unsupported_logical_edge("flex_direction_row_reverse_margin_start"),
  unsupported_logical_edge("flex_direction_row_reverse_margin_end"),
  unsupported_logical_edge("flex_direction_row_reverse_padding_start"),
  unsupported_logical_edge("flex_direction_row_reverse_padding_end"),
  unsupported_logical_edge("flex_direction_row_reverse_border_start"),
  unsupported_logical_edge("flex_direction_row_reverse_border_end"),
  unsupported_logical_edge("flex_direction_row_reverse_pos_start"),
  unsupported_logical_edge("flex_direction_row_reverse_pos_end"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_pos_start"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_pos_end"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_marign_start"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_margin_end"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_border_start"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_border_end"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_padding_start"),
  unsupported_logical_edge("flex_direction_row_reverse_inner_padding_end"),
}
