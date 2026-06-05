local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignItemsTest.html",
    generated = "tests/generated/YGAlignItemsTest.cpp",
    test = test,
  }
end

local function column_case(name, align_items, expected_left, expected_width)
  local child_style = { height = 10 }
  if expected_width ~= 100 then
    child_style.width = 10
  end

  return {
    name = name,
    source = source(name),
    root = {
      style = { width = 100, height = 100, alignItems = align_items },
      children = {
        { style = child_style },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = expected_left, top = 0, width = expected_width, height = 10 },
    },
  }
end

return {
  column_case("align_items_stretch", "stretch", 0, 100),
  column_case("align_items_flex_start", "flex-start", 0, 10),
  column_case("align_items_center", "center", 45, 10),
  column_case("align_items_flex_end", "flex-end", 90, 10),
  {
    name = "align_baseline",
    source = source("align_baseline"),
    root = {
      style = { width = 100, height = 100, flexDirection = "row", alignItems = "baseline" },
      children = {
        { style = { width = 50, height = 50 } },
        { style = { width = 50, height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 50, top = 30, width = 50, height = 20 },
    },
  },
}
