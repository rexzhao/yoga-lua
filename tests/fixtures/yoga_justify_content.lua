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

local function overflow_row_case(name, direction, justify_content, expected_lefts, first_child_style)
  local root_style = { position = "absolute", width = 102, height = 102, flexDirection = "row" }
  if justify_content then
    root_style.justifyContent = justify_content
  end

  local first_style = { width = 40 }
  for key, value in pairs(first_child_style or {}) do
    first_style[key] = value
  end

  return {
    name = name .. "_" .. direction,
    source = source(name),
    direction = direction,
    root = {
      style = root_style,
      children = {
        { style = first_style },
        { style = { width = 40 } },
        { style = { width = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 102, height = 102 },
      { left = expected_lefts[1], top = 0, width = 40, height = 102 },
      { left = expected_lefts[2], top = 0, width = 40, height = 102 },
      { left = expected_lefts[3], top = 0, width = 40, height = 102 },
    },
  }
end

local function skipped_overflow_case(name)
  return {
    name = name,
    source = source(name),
    skip = true,
    unsupportedReason = "upstream generated test is disabled; row-reverse overflow spacing is deferred",
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
    root = {
      style = { width = 102, height = 102, flexDirection = "row", justifyContent = "space-evenly" },
      children = {
        { style = { height = 10 } },
        { style = { height = 10 } },
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 102, height = 102 },
      { left = 26, top = 0, width = 0, height = 10 },
      { left = 51, top = 0, width = 0, height = 10 },
      { left = 77, top = 0, width = 0, height = 10 },
    },
  },
  overflow_row_case("justify_content_overflow_row_flex_start", "ltr", nil, { 0, 40, 80 }),
  overflow_row_case("justify_content_overflow_row_flex_start", "rtl", nil, { 62, 22, -18 }),
  overflow_row_case("justify_content_overflow_row_flex_end", "ltr", "flex-end", { -18, 22, 62 }),
  overflow_row_case("justify_content_overflow_row_flex_end", "rtl", "flex-end", { 80, 40, 0 }),
  overflow_row_case("justify_content_overflow_row_center", "ltr", "center", { -9, 31, 71 }),
  overflow_row_case("justify_content_overflow_row_center", "rtl", "center", { 71, 31, -9 }),
  overflow_row_case("justify_content_overflow_row_space_between", "ltr", "space-between", { 0, 40, 80 }),
  overflow_row_case("justify_content_overflow_row_space_between", "rtl", "space-between", { 62, 22, -18 }),
  overflow_row_case("justify_content_overflow_row_space_around", "ltr", "space-around", { 0, 40, 80 }),
  overflow_row_case("justify_content_overflow_row_space_around", "rtl", "space-around", { 62, 22, -18 }),
  overflow_row_case("justify_content_overflow_row_space_evenly", "ltr", "space-evenly", { 0, 40, 80 }),
  overflow_row_case("justify_content_overflow_row_space_evenly", "rtl", "space-evenly", { 62, 22, -18 }),
  skipped_overflow_case("justify_content_overflow_row_reverse_space_around"),
  skipped_overflow_case("justify_content_overflow_row_reverse_space_evenly"),
  overflow_row_case(
    "justify_content_overflow_row_space_evenly_auto_margin",
    "ltr",
    "space-evenly",
    { 0, 40, 80 },
    { marginRight = "auto" }
  ),
  overflow_row_case(
    "justify_content_overflow_row_space_evenly_auto_margin",
    "rtl",
    "space-evenly",
    { 62, 22, -18 },
    { marginRight = "auto" }
  ),
}
