local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGMarginTest.html",
    generated = "tests/generated/YGMarginTest.cpp",
    test = test,
  }
end

local function unsupported_auto_margin(name)
  return {
    name = name,
    source = source(name),
    skip = true,
    unsupportedReason = "auto margins are not implemented",
  }
end

return {
  {
    name = "margin_start",
    source = source("margin_start"),
    root = {
      style = { position = "absolute", width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { width = 10, marginStart = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 0, width = 10, height = 100 },
    },
  },
  {
    name = "margin_top",
    source = source("margin_top"),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        { style = { height = 10, marginTop = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 10, width = 100, height = 10 },
    },
  },
  {
    name = "margin_end",
    source = source("margin_end"),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        flexDirection = "row",
        justifyContent = "flex-end",
      },
      children = {
        { style = { width = 10, marginEnd = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 80, top = 0, width = 10, height = 100 },
    },
  },
  {
    name = "margin_bottom",
    source = source("margin_bottom"),
    root = {
      style = { position = "absolute", width = 100, height = 100, justifyContent = "flex-end" },
      children = {
        { style = { height = 10, marginBottom = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 80, width = 100, height = 10 },
    },
  },
  {
    name = "margin_and_flex_row",
    source = source("margin_and_flex_row"),
    root = {
      style = { position = "absolute", width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1, marginStart = 10, marginEnd = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 0, width = 80, height = 100 },
    },
  },
  {
    name = "margin_and_flex_column",
    source = source("margin_and_flex_column"),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        { style = { flexGrow = 1, marginTop = 10, marginBottom = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 10, width = 100, height = 80 },
    },
  },
  {
    name = "margin_and_stretch_row",
    source = source("margin_and_stretch_row"),
    root = {
      style = { position = "absolute", width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1, marginTop = 10, marginBottom = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 10, width = 100, height = 80 },
    },
  },
  {
    name = "margin_and_stretch_column",
    source = source("margin_and_stretch_column"),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        { style = { flexGrow = 1, marginStart = 10, marginEnd = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 0, width = 80, height = 100 },
    },
  },
  {
    name = "margin_with_sibling_row",
    source = source("margin_with_sibling_row"),
    root = {
      style = { position = "absolute", width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1, marginEnd = 10 } },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 45, height = 100 },
      { left = 55, top = 0, width = 45, height = 100 },
    },
  },
  {
    name = "margin_with_sibling_column",
    source = source("margin_with_sibling_column"),
    root = {
      style = { position = "absolute", width = 100, height = 100 },
      children = {
        { style = { flexGrow = 1, marginBottom = 10 } },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 45 },
      { left = 0, top = 55, width = 100, height = 45 },
    },
  },
  {
    name = "margin_should_not_be_part_of_max_height",
    source = source("margin_should_not_be_part_of_max_height"),
    root = {
      style = { position = "absolute", width = 250, height = 250 },
      children = {
        { style = { width = 100, height = 100, maxHeight = 100, marginTop = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 250, height = 250 },
      { left = 0, top = 20, width = 100, height = 100 },
    },
  },
  {
    name = "margin_should_not_be_part_of_max_width",
    source = source("margin_should_not_be_part_of_max_width"),
    root = {
      style = { position = "absolute", width = 250, height = 250 },
      children = {
        { style = { width = 100, height = 100, maxWidth = 100, marginLeft = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 250, height = 250 },
      { left = 20, top = 0, width = 100, height = 100 },
    },
  },
  unsupported_auto_margin("margin_auto_bottom"),
  unsupported_auto_margin("margin_auto_top"),
  unsupported_auto_margin("margin_auto_bottom_and_top"),
  unsupported_auto_margin("margin_auto_bottom_and_top_justify_center"),
  unsupported_auto_margin("margin_auto_multiple_children_column"),
  unsupported_auto_margin("margin_auto_multiple_children_row"),
  unsupported_auto_margin("margin_auto_left_and_right_column"),
  unsupported_auto_margin("margin_auto_left_and_right"),
  unsupported_auto_margin("margin_auto_start_and_end_column"),
  unsupported_auto_margin("margin_auto_start_and_end"),
  unsupported_auto_margin("margin_auto_left_and_right_column_and_center"),
  unsupported_auto_margin("margin_auto_left"),
  unsupported_auto_margin("margin_auto_right"),
  unsupported_auto_margin("margin_auto_left_and_right_stretch"),
  unsupported_auto_margin("margin_auto_top_and_bottom_stretch"),
  unsupported_auto_margin("margin_auto_left_right_child_bigger_than_parent"),
  unsupported_auto_margin("margin_auto_left_child_bigger_than_parent"),
  unsupported_auto_margin("margin_fix_left_auto_right_child_bigger_than_parent"),
  unsupported_auto_margin("margin_auto_left_fix_right_child_bigger_than_parent"),
  unsupported_auto_margin("margin_auto_top_stretching_child"),
  unsupported_auto_margin("margin_auto_left_stretching_child"),
  unsupported_auto_margin("margin_auto_overflowing_container"),
}
