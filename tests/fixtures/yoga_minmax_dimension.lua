local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGMinMaxDimensionTest.html",
    generated = "tests/generated/YGMinMaxDimensionTest.cpp",
    test = test,
  }
end

return {
  {
    name = "max_width",
    source = source("max_width"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { height = 10, maxWidth = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 10 },
    },
  },
  {
    name = "max_height",
    source = source("max_height"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { width = 10, maxHeight = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 10, height = 50 },
    },
  },
  {
    name = "justify_content_min_max",
    source = source("justify_content_min_max"),
    root = {
      style = { maxHeight = 200, minHeight = 100, width = 100, justifyContent = "center" },
      children = {
        { style = { width = 60, height = 60 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 20, width = 60, height = 60 },
    },
  },
  {
    name = "align_items_min_max",
    source = source("align_items_min_max"),
    root = {
      style = { maxWidth = 200, minWidth = 100, height = 100, alignItems = "center" },
      children = {
        { style = { width = 60, height = 60 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 20, top = 0, width = 60, height = 60 },
    },
  },
  {
    name = "justify_content_overflow_min_max_ltr",
    source = source("justify_content_overflow_min_max"),
    root = {
      style = { position = "absolute", minHeight = 100, maxHeight = 110, justifyContent = "center" },
      children = {
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 50, height = 110 },
      { left = 0, top = -20, width = 50, height = 50 },
      { left = 0, top = 30, width = 50, height = 50 },
      { left = 0, top = 80, width = 50, height = 50 },
    },
  },
  {
    name = "justify_content_overflow_min_max_rtl",
    source = source("justify_content_overflow_min_max"),
    direction = "rtl",
    root = {
      style = { position = "absolute", minHeight = 100, maxHeight = 110, justifyContent = "center" },
      children = {
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 50, height = 110 },
      { left = 0, top = -20, width = 50, height = 50 },
      { left = 0, top = 30, width = 50, height = 50 },
      { left = 0, top = 80, width = 50, height = 50 },
    },
  },
  {
    name = "flex_grow_to_min",
    source = source("flex_grow_to_min"),
    root = {
      style = { minHeight = 100, maxHeight = 500, width = 100 },
      children = {
        { style = { flexGrow = 1 } },
        { style = { height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 50 },
      { left = 0, top = 50, width = 100, height = 50 },
    },
  },
  {
    name = "flex_grow_within_constrained_min_row",
    source = source("flex_grow_within_constrained_min_row"),
    root = {
      style = { minWidth = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1 } },
        { style = { width = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 100 },
      { left = 50, top = 0, width = 50, height = 100 },
    },
  },
  {
    name = "flex_grow_within_constrained_min_column",
    source = source("flex_grow_within_constrained_min_column"),
    root = {
      style = { minHeight = 100 },
      children = {
        { style = { flexGrow = 1 } },
        { style = { height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 0, height = 100 },
      { left = 0, top = 0, width = 0, height = 50 },
      { left = 0, top = 50, width = 0, height = 50 },
    },
  },
  {
    name = "min_width_overrides_width",
    source = source("min_width_overrides_width"),
    root = {
      style = { minWidth = 100, width = 50 },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 0 },
    },
  },
  {
    name = "max_width_overrides_width",
    source = source("max_width_overrides_width"),
    root = {
      style = { maxWidth = 100, width = 200 },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 0 },
    },
  },
  {
    name = "min_height_overrides_height",
    source = source("min_height_overrides_height"),
    root = {
      style = { minHeight = 100, height = 50 },
    },
    expect = {
      { left = 0, top = 0, width = 0, height = 100 },
    },
  },
  {
    name = "max_height_overrides_height",
    source = source("max_height_overrides_height"),
    root = {
      style = { maxHeight = 100, height = 200 },
    },
    expect = {
      { left = 0, top = 0, width = 0, height = 100 },
    },
  },
  {
    name = "min_max_percent_no_width_height",
    source = source("min_max_percent_no_width_height"),
    root = {
      style = { width = 100, height = 100, alignItems = "flex-start" },
      children = {
        {
          style = {
            minWidth = "10%",
            maxWidth = "10%",
            minHeight = "10%",
            maxHeight = "10%",
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 10, height = 10 },
    },
  },
}
