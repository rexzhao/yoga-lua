local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGMarginTest.html",
    generated = "tests/generated/YGMarginTest.cpp",
    test = test,
  }
end

local function auto_case(name, direction, root, expect)
  return {
    name = name .. "_" .. direction,
    source = source(name),
    direction = direction,
    root = root,
    expect = expect,
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
  auto_case("margin_auto_bottom", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_bottom", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_top", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 100, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_top", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 100, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_bottom_and_top", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 50, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_bottom_and_top", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 50, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_bottom_and_top_justify_center", "ltr", {
    style = { position = "absolute", width = 200, height = 200, justifyContent = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 0, top = 50, width = 50, height = 50 },
    { left = 0, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_bottom_and_top_justify_center", "rtl", {
    style = { position = "absolute", width = 200, height = 200, justifyContent = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 150, top = 50, width = 50, height = 50 },
    { left = 150, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_multiple_children_column", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 25, width = 50, height = 50 },
    { left = 75, top = 100, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_multiple_children_column", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50, marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 25, width = 50, height = 50 },
    { left = 75, top = 100, width = 50, height = 50 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_multiple_children_row", "ltr", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 0, top = 75, width = 50, height = 50 },
    { left = 75, top = 75, width = 50, height = 50 },
    { left = 150, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_multiple_children_row", "rtl", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 125, top = 75, width = 50, height = 50 },
    { left = 50, top = 75, width = 50, height = 50 },
    { left = 0, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_column", "ltr", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 50, top = 75, width = 50, height = 50 },
    { left = 150, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_column", "rtl", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 100, top = 75, width = 50, height = 50 },
    { left = 0, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right", "ltr", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 0, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right", "rtl", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 150, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_start_and_end_column", "ltr", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginStart = "auto", marginEnd = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 50, top = 75, width = 50, height = 50 },
    { left = 150, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_start_and_end_column", "rtl", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row", alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginStart = "auto", marginEnd = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 100, top = 75, width = 50, height = 50 },
    { left = 0, top = 75, width = 50, height = 50 },
  }),
  auto_case("margin_auto_start_and_end", "ltr", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginStart = "auto", marginEnd = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 0, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_start_and_end", "rtl", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginStart = "auto", marginEnd = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 150, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_column_and_center", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_column_and_center", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 150, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 150, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_right", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 0, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_right", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 50, marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 0, top = 0, width = 50, height = 50 },
    { left = 75, top = 50, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_stretch", "ltr", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 50, top = 0, width = 50, height = 50 },
    { left = 150, top = 0, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_and_right_stretch", "rtl", {
    style = { position = "absolute", width = 200, height = 200, flexDirection = "row" },
    children = {
      { style = { width = 50, height = 50, marginLeft = "auto", marginRight = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 100, top = 0, width = 50, height = 50 },
    { left = 0, top = 0, width = 50, height = 50 },
  }),
  auto_case("margin_auto_top_and_bottom_stretch", "ltr", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 0, top = 50, width = 50, height = 50 },
    { left = 0, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_top_and_bottom_stretch", "rtl", {
    style = { position = "absolute", width = 200, height = 200 },
    children = {
      { style = { width = 50, height = 50, marginTop = "auto", marginBottom = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 150, top = 50, width = 50, height = 50 },
    { left = 150, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_right_child_bigger_than_parent", "ltr", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto", marginRight = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = 0, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_left_right_child_bigger_than_parent", "rtl", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto", marginRight = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = -20, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_left_child_bigger_than_parent", "ltr", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = 0, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_left_child_bigger_than_parent", "rtl", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = -20, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_fix_left_auto_right_child_bigger_than_parent", "ltr", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = 10, marginRight = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = 10, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_fix_left_auto_right_child_bigger_than_parent", "rtl", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = 10, marginRight = "auto" } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = -20, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_left_fix_right_child_bigger_than_parent", "ltr", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto", marginRight = 10 } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = 0, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_left_fix_right_child_bigger_than_parent", "rtl", {
    style = { position = "absolute", width = 52, height = 52, justifyContent = "center" },
    children = {
      { style = { width = 72, height = 72, marginLeft = "auto", marginRight = 10 } },
    },
  }, {
    { left = 0, top = 0, width = 52, height = 52 },
    { left = -30, top = -10, width = 72, height = 72 },
  }),
  auto_case("margin_auto_top_stretching_child", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 100, top = 0, width = 0, height = 150 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_top_stretching_child", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginTop = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 100, top = 0, width = 0, height = 150 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_stretching_child", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginLeft = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 200, top = 0, width = 0, height = 150 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_left_stretching_child", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { flexGrow = 1, flexShrink = 1, flexBasis = "0%", marginLeft = "auto" } },
      { style = { width = 50, height = 50 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 200, top = 0, width = 0, height = 150 },
    { left = 75, top = 150, width = 50, height = 50 },
  }),
  auto_case("margin_auto_overflowing_container", "ltr", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 150, marginBottom = "auto" } },
      { style = { width = 50, height = 150 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 150 },
    { left = 75, top = 150, width = 50, height = 150 },
  }),
  auto_case("margin_auto_overflowing_container", "rtl", {
    style = { position = "absolute", width = 200, height = 200, alignItems = "center" },
    children = {
      { style = { width = 50, height = 150, marginBottom = "auto" } },
      { style = { width = 50, height = 150 } },
    },
  }, {
    { left = 0, top = 0, width = 200, height = 200 },
    { left = 75, top = 0, width = 50, height = 150 },
    { left = 75, top = 150, width = 50, height = 150 },
  }),
}
