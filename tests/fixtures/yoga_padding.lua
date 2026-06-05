local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGPaddingTest.html",
    generated = "tests/generated/YGPaddingTest.cpp",
    test = test,
  }
end

return {
  {
    name = "padding_no_size",
    source = source("padding_no_size"),
    root = {
      style = { position = "absolute", padding = 10 },
    },
    expect = {
      { left = 0, top = 0, width = 20, height = 20 },
    },
  },
  {
    name = "padding_container_match_child",
    source = source("padding_container_match_child"),
    root = {
      style = { position = "absolute", padding = 10 },
      children = {
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 30, height = 30 },
      { left = 10, top = 10, width = 10, height = 10 },
    },
  },
  {
    name = "padding_flex_child",
    source = source("padding_flex_child"),
    root = {
      style = { position = "absolute", width = 100, height = 100, padding = 10 },
      children = {
        { style = { width = 10, flexGrow = 1 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 10, width = 10, height = 80 },
    },
  },
  {
    name = "padding_stretch_child",
    source = source("padding_stretch_child"),
    root = {
      style = { position = "absolute", width = 100, height = 100, padding = 10 },
      children = {
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 10, width = 80, height = 10 },
    },
  },
  {
    name = "padding_center_child",
    source = source("padding_center_child"),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        paddingStart = 10,
        paddingEnd = 20,
        paddingBottom = 20,
        alignItems = "center",
        justifyContent = "center",
      },
      children = {
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 40, top = 35, width = 10, height = 10 },
    },
  },
  {
    name = "child_with_padding_align_end",
    source = source("child_with_padding_align_end"),
    root = {
      style = {
        position = "absolute",
        width = 200,
        height = 200,
        justifyContent = "flex-end",
        alignItems = "flex-end",
      },
      children = {
        { style = { width = 100, height = 100, padding = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 100, top = 100, width = 100, height = 100 },
    },
  },
  {
    name = "physical_and_relative_edge_defined",
    source = source("physical_and_relative_edge_defined"),
    root = {
      style = {
        position = "absolute",
        width = 200,
        height = 200,
        paddingLeft = 20,
        paddingEnd = 50,
      },
      children = {
        { style = { width = "100%", height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 20, top = 0, width = 130, height = 50 },
    },
  },
}
