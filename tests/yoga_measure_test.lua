local yoga = require("yoga")

local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "YGMeasureTest.cpp",
    generated = false,
    test = test,
  }
end

local function with_measure(style, calls, result)
  local copy = {}
  for key, value in pairs(style) do
    copy[key] = value
  end

  copy.measure = function()
    calls.count = calls.count + 1
    return result or { width = 10, height = 10 }
  end

  return copy
end

local function assert_locked_min_max_case(runner, helper, name, child_style)
  runner:test("locked min/max skips measure: " .. name, function()
    local calls = { count = 0 }
    local child = yoga.node(with_measure(child_style, calls))
    local root = yoga.node({ alignItems = "flex-start", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(calls.count, 0, name .. " measure count")
    helper.assert_layout(child, { left = 0, top = 0, width = 10, height = 10 }, name)
  end, source(name))
end

local function measure_wrapping_text(width, width_mode)
  if width_mode == yoga.MEASURE_MODE_UNDEFINED or width >= 68 then
    return { width = 68, height = 16 }
  end

  return { width = 50, height = 32 }
end

return function(runner, helper)
  runner:test("single grow/shrink child does not need measure", function()
    local calls = { count = 0 }
    local child = yoga.node(with_measure({
      flexGrow = 1,
      flexShrink = 1,
    }, calls))
    local root = yoga.node({ width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(calls.count, 0, "measure count")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 100 }, "flexible child")
  end, source("dont_measure_single_grow_shrink_child"))

  assert_locked_min_max_case(runner, helper, "dont_measure_when_min_equals_max", {
    minWidth = 10,
    maxWidth = 10,
    minHeight = 10,
    maxHeight = 10,
  })

  assert_locked_min_max_case(runner, helper, "dont_measure_when_min_equals_max_percentages", {
    minWidth = "10%",
    maxWidth = "10%",
    minHeight = "10%",
    maxHeight = "10%",
  })

  assert_locked_min_max_case(runner, helper, "dont_measure_when_min_equals_max_mixed_width_percent", {
    minWidth = "10%",
    maxWidth = "10%",
    minHeight = 10,
    maxHeight = 10,
  })

  assert_locked_min_max_case(runner, helper, "dont_measure_when_min_equals_max_mixed_height_percent", {
    minWidth = 10,
    maxWidth = 10,
    minHeight = "10%",
    maxHeight = "10%",
  })

  runner:test("measured text stays on one line with enough width", function()
    local child = yoga.node({
      alignSelf = "flex-start",
      measure = measure_wrapping_text,
    })
    local root = yoga.node({ width = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 68, height = 16 }, "single line text")
  end, source("measure_enough_size_should_be_in_single_line"))

  runner:test("measured text wraps when available width is too small", function()
    local child = yoga.node({
      alignSelf = "flex-start",
      measure = measure_wrapping_text,
    })
    local root = yoga.node({ width = 55 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 50, height = 32 }, "wrapped text")
  end, source("measure_not_enough_size_should_wrap"))
end
