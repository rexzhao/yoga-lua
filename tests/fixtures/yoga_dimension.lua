local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGDimensionTest.html",
    generated = "tests/generated/YGDimensionTest.cpp",
    test = test,
  }
end

return {
  {
    name = "wrap_child",
    source = source("wrap_child"),
    root = {
      style = { position = "absolute" },
      children = {
        { style = { width = 100, height = 100 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
    },
  },
  {
    name = "wrap_grandchild",
    source = source("wrap_grandchild"),
    root = {
      style = { position = "absolute" },
      children = {
        {
          style = {},
          children = {
            { style = { width = 100, height = 100 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
    },
  },
}
