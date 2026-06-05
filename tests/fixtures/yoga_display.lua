local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGDisplayTest.html",
    generated = "tests/generated/YGDisplayTest.cpp",
    test = test,
  }
end

local function skip_contents(test)
  return {
    name = test,
    source = source(test),
    skip = true,
    unsupportedReason = "display contents is not implemented",
  }
end

return {
  {
    name = "display_none",
    source = source("display_none"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1 } },
        { style = { flexGrow = 1, display = "none" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
    },
  },
  {
    name = "display_none_fixed_size",
    source = source("display_none_fixed_size"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1 } },
        { style = { width = 20, height = 20, display = "none" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
    },
  },
  {
    name = "display_none_with_margin",
    source = source("display_none_with_margin"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { width = 20, height = 20, display = "none", margin = 10 } },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 100, height = 100 },
    },
  },
  {
    name = "display_none_with_child",
    source = source("display_none_with_child"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1 } },
        {
          style = { flexGrow = 1, display = "none" },
          children = {
            { style = { flexGrow = 1, width = 20 } },
          },
        },
        { style = { flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 50, top = 0, width = 50, height = 100 },
    },
  },
  {
    name = "display_none_with_position",
    source = source("display_none_with_position"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1 } },
        { style = { flexGrow = 1, display = "none", top = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
    },
  },
  {
    name = "display_none_with_position_absolute",
    source = source("display_none_with_position_absolute"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { display = "none", position = "absolute", width = 100, height = 100 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
    },
  },
  skip_contents("display_contents"),
  skip_contents("display_contents_fixed_size"),
  skip_contents("display_contents_with_margin"),
  skip_contents("display_contents_with_padding"),
  skip_contents("display_contents_with_position"),
  skip_contents("display_contents_with_position_absolute"),
  skip_contents("display_contents_nested"),
  skip_contents("display_contents_with_siblings"),
}
