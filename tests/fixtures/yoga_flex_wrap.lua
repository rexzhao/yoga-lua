local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGFlexWrapTest.html",
    generated = "tests/generated/YGFlexWrapTest.cpp",
    test = test,
  }
end

local function box(width, height)
  return { style = { width = width, height = height } }
end

local function wrap_row_case(name, align_items, expected_tops)
  local style = { width = 100, flexDirection = "row", flexWrap = "wrap" }
  if align_items then
    style.alignItems = align_items
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = style,
      children = {
        box(30, 10),
        box(30, 20),
        box(30, 30),
        box(30, 30),
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 60 },
      { left = 0, top = expected_tops[1], width = 30, height = 10 },
      { left = 30, top = expected_tops[2], width = 30, height = 20 },
      { left = 60, top = expected_tops[3], width = 30, height = 30 },
      { left = 0, top = 30, width = 30, height = 30 },
    },
  }
end

return {
  {
    name = "wrap_column_ltr",
    source = source("wrap_column"),
    root = {
      style = { position = "absolute", height = 100, flexWrap = "wrap" },
      children = {
        box(30, 30),
        box(30, 30),
        box(30, 30),
        box(30, 30),
      },
    },
    expect = {
      { left = 0, top = 0, width = 30, height = 100 },
      { left = 0, top = 0, width = 30, height = 30 },
      { left = 0, top = 30, width = 30, height = 30 },
      { left = 0, top = 60, width = 30, height = 30 },
      { left = 30, top = 0, width = 30, height = 30 },
    },
  },
  {
    name = "wrap_column_rtl",
    source = source("wrap_column"),
    direction = "rtl",
    root = {
      style = { position = "absolute", height = 100, flexWrap = "wrap" },
      children = {
        box(30, 30),
        box(30, 30),
        box(30, 30),
        box(30, 30),
      },
    },
    expect = {
      { left = 0, top = 0, width = 30, height = 100 },
      { left = 0, top = 0, width = 30, height = 30 },
      { left = 0, top = 30, width = 30, height = 30 },
      { left = 0, top = 60, width = 30, height = 30 },
      { left = -30, top = 0, width = 30, height = 30 },
    },
  },
  {
    name = "wrap_row",
    source = source("wrap_row"),
    root = {
      style = { width = 100, flexDirection = "row", flexWrap = "wrap" },
      children = {
        box(30, 30),
        box(30, 30),
        box(30, 30),
        box(30, 30),
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 60 },
      { left = 0, top = 0, width = 30, height = 30 },
      { left = 30, top = 0, width = 30, height = 30 },
      { left = 60, top = 0, width = 30, height = 30 },
      { left = 0, top = 30, width = 30, height = 30 },
    },
  },
  wrap_row_case("wrap_row_align_items_flex_end", "flex-end", { 20, 10, 0 }),
  wrap_row_case("wrap_row_align_items_center", "center", { 10, 5, 0 }),
  {
    name = "flex_wrap_children_with_min_main_overriding_flex_basis",
    source = source("flex_wrap_children_with_min_main_overriding_flex_basis"),
    root = {
      style = { width = 100, flexDirection = "row", flexWrap = "wrap" },
      children = {
        { style = { flexBasis = 50, minWidth = 55, height = 50 } },
        { style = { flexBasis = 50, minWidth = 55, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 55, height = 50 },
      { left = 0, top = 50, width = 55, height = 50 },
    },
  },
  {
    name = "flex_wrap_wrap_to_child_height",
    source = source("flex_wrap_wrap_to_child_height"),
    root = {
      style = { position = "absolute" },
      children = {
        {
          style = { flexDirection = "row", alignItems = "flex-start", flexWrap = "wrap" },
          children = {
            {
              style = { width = 100 },
              children = {
                box(100, 100),
              },
            },
          },
        },
        box(100, 100),
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 200 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 100, width = 100, height = 100 },
    },
  },
  {
    name = "flex_wrap_align_stretch_fits_one_row",
    source = source("flex_wrap_align_stretch_fits_one_row"),
    root = {
      style = { width = 150, height = 100, flexDirection = "row", flexWrap = "wrap" },
      children = {
        { style = { width = 50 } },
        { style = { width = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 150, height = 100 },
      { left = 0, top = 0, width = 50, height = 0 },
      { left = 50, top = 0, width = 50, height = 0 },
    },
  },
  {
    name = "wrap_reverse_row_align_content_flex_start",
    source = source("wrap_reverse_row_align_content_flex_start"),
    root = {
      style = { width = 100, flexDirection = "row", flexWrap = "wrap-reverse", alignContent = "flex-start" },
      children = {
        box(30, 10),
        box(30, 20),
        box(30, 30),
        box(30, 40),
        box(30, 50),
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 80 },
      { left = 0, top = 70, width = 30, height = 10 },
      { left = 30, top = 60, width = 30, height = 20 },
      { left = 60, top = 50, width = 30, height = 30 },
      { left = 0, top = 10, width = 30, height = 40 },
      { left = 30, top = 0, width = 30, height = 50 },
    },
  },
}
