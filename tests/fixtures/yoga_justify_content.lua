local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGJustifyContentTest.html",
    generated = "tests/generated/YGJustifyContentTest.cpp",
    test = test,
  }
end

local function row_case(name, justify_content, expected_lefts)
  return {
    name = name,
    source = source(name),
    root = {
      style = { width = 102, height = 102, flexDirection = "row", justifyContent = justify_content },
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 102, height = 102 },
      { left = expected_lefts[1], top = 0, width = 10, height = 102 },
      { left = expected_lefts[2], top = 0, width = 10, height = 102 },
      { left = expected_lefts[3], top = 0, width = 10, height = 102 },
    },
  }
end

return {
  row_case("justify_content_row_flex_start", "flex-start", { 0, 10, 20 }),
  row_case("justify_content_row_center", "center", { 36, 46, 56 }),
  row_case("justify_content_row_flex_end", "flex-end", { 72, 82, 92 }),
  row_case("justify_content_row_space_between", "space-between", { 0, 46, 92 }),
  row_case("justify_content_row_space_around", "space-around", { 12, 46, 80 }),
  {
    name = "justify_content_row_space_evenly",
    source = source("justify_content_row_space_evenly"),
    skip = true,
    unsupportedReason = "Yoga generated output depends on rounding policy not implemented yet",
  },
}

