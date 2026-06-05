local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAlignContentTest.html",
    generated = "tests/generated/YGAlignContentTest.cpp",
    test = test,
  }
end

local function child()
  return { style = { width = 50, height = 10 } }
end

local function align_content_wrap(name, align_content, tops)
  return {
    name = name,
    source = source(name),
    root = {
      style = {
        position = "absolute",
        width = 140,
        height = 120,
        flexWrap = "wrap",
        flexDirection = "row",
        alignContent = align_content,
      },
      children = {
        child(),
        child(),
        child(),
        child(),
        child(),
      },
    },
    expect = {
      { left = 0, top = 0, width = 140, height = 120 },
      { left = 0, top = tops[1], width = 50, height = 10 },
      { left = 50, top = tops[1], width = 50, height = 10 },
      { left = 0, top = tops[2], width = 50, height = 10 },
      { left = 50, top = tops[2], width = 50, height = 10 },
      { left = 0, top = tops[3], width = 50, height = 10 },
    },
  }
end

return {
  align_content_wrap("align_content_flex_start_wrap", "flex-start", { 0, 10, 20 }),
  align_content_wrap("align_content_flex_end_wrap", "flex-end", { 90, 100, 110 }),
  align_content_wrap("align_content_center_wrap", "center", { 45, 55, 65 }),
  align_content_wrap("align_content_space_between_wrap", "space-between", { 0, 55, 110 }),
  align_content_wrap("align_content_space_around_wrap", "space-around", { 15, 55, 95 }),
  align_content_wrap("align_content_space_evenly_wrap", "space-evenly", { 23, 55, 88 }),
}
