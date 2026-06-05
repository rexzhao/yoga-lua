local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGDisplayTest.html",
    generated = "tests/generated/YGDisplayTest.cpp",
    test = test,
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
  {
    name = "display_contents",
    source = source("display_contents"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents" },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_fixed_size",
    source = source("display_contents_fixed_size"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents", width = 50, height = 50 },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_with_margin",
    source = source("display_contents_with_margin"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { width = 20, height = 20, display = "contents", margin = 10 } },
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
    name = "display_contents_with_padding",
    source = source("display_contents_with_padding"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents", padding = 10 },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_with_position",
    source = source("display_contents_with_position"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents", top = 10 },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_with_position_absolute",
    source = source("display_contents_with_position_absolute"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents", position = "absolute", width = 50, height = 50 },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_nested",
    source = source("display_contents_nested"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        {
          style = { display = "contents" },
          children = {
            {
              style = { display = "contents" },
              children = {
                { style = { flexGrow = 1, height = 10 } },
                { style = { flexGrow = 1, height = 20 } },
              },
            },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 0, top = 0, width = 50, height = 10 },
      { left = 50, top = 0, width = 50, height = 20 },
    },
  },
  {
    name = "display_contents_with_siblings",
    source = source("display_contents_with_siblings"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1, height = 30 } },
        {
          style = { display = "contents" },
          children = {
            { style = { flexGrow = 1, height = 10 } },
            { style = { flexGrow = 1, height = 20 } },
          },
        },
        { style = { flexGrow = 1, height = 30 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 25, height = 30 },
      { left = 0, top = 0, width = 0, height = 0 },
      { left = 25, top = 0, width = 25, height = 10 },
      { left = 50, top = 0, width = 25, height = 20 },
      { left = 75, top = 0, width = 25, height = 30 },
    },
  },
}
