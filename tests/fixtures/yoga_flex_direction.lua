local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGFlexDirectionTest.html",
    generated = "tests/generated/YGFlexDirectionTest.cpp",
    test = test,
  }
end

local function column_case(name, direction, tops)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        flexDirection = direction,
      },
      children = {
        { style = { height = 10 } },
        { style = { height = 10 } },
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = tops[1], width = 100, height = 10 },
      { left = 0, top = tops[2], width = 100, height = 10 },
      { left = 0, top = tops[3], width = 100, height = 10 },
    },
  }
end

local function row_case(name, direction, lefts)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 100,
        height = 100,
        flexDirection = direction,
      },
      children = {
        { style = { width = 10 } },
        { style = { width = 10 } },
        { style = { width = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = lefts[1], top = 0, width = 10, height = 100 },
      { left = lefts[2], top = 0, width = 10, height = 100 },
      { left = lefts[3], top = 0, width = 10, height = 100 },
    },
  }
end

return {
  column_case("flex_direction_column", nil, { 0, 10, 20 }),
  row_case("flex_direction_row", "row", { 0, 10, 20 }),
  column_case("flex_direction_column_reverse", "column-reverse", { 90, 80, 70 }),
  row_case("flex_direction_row_reverse", "row-reverse", { 90, 80, 70 }),
}
