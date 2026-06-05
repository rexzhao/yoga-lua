local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignSelfTest.html",
    generated = "tests/generated/YGAlignSelfTest.cpp",
    test = test,
  }
end

local function self_case(name, parent_align, align_self, expected_left)
  return {
    name = name,
    source = source(name),
    root = {
      style = { width = 100, height = 100, alignItems = parent_align },
      children = {
        { style = { width = 10, height = 10, alignSelf = align_self } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = expected_left, top = 0, width = 10, height = 10 },
    },
  }
end

return {
  self_case("align_self_center", nil, "center", 45),
  self_case("align_self_flex_end", nil, "flex-end", 90),
  self_case("align_self_flex_start", nil, "flex-start", 0),
  self_case("align_self_flex_end_override_flex_start", "flex-start", "flex-end", 90),
  {
    name = "align_self_baseline",
    source = source("align_self_baseline"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row" },
      children = {
        { style = { width = 50, height = 50, alignSelf = "baseline" } },
        {
          style = { width = 50, height = 20, alignSelf = "baseline" },
          children = {
            { style = { width = 50, height = 10 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 50, top = 40, width = 50, height = 20 },
      { left = 50, top = 40, width = 50, height = 10 },
    },
  },
}
