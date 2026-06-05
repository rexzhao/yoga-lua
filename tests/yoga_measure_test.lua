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

local function measure_100()
  return { width = 100, height = 100 }
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

  runner:test("absolute measured child is measured without constraints", function()
    local calls = { count = 0 }
    local absolute = yoga.node(with_measure({
      position = "absolute",
    }, calls))
    local child = yoga.node({}, {
      absolute,
    })
    local root = yoga.node({}, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(calls.count, 1, "absolute measure count")
  end, source("measure_absolute_child_with_no_constraints"))

  runner:test("measure callback is not called with negative vertical constraints", function()
    local calls = 0
    local child = yoga.node({
      marginTop = 20,
      measure = function(width, _, height)
        calls = calls + 1
        helper.assert_equal((width or 0) >= 0, true, "measure width is non-negative")
        helper.assert_equal((height or 0) >= 0, true, "measure height is non-negative")
        return { width = 0, height = 0 }
      end,
    })
    local root = yoga.node({ flexDirection = "column", width = 50, height = 10 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(calls, 1, "measure call count")
  end, source("cant_call_negative_measure"))

  runner:test("measure callback is not called with negative horizontal constraints", function()
    local calls = 0
    local child = yoga.node({
      marginStart = 20,
      measure = function(width, _, height)
        calls = calls + 1
        helper.assert_equal((width or 0) >= 0, true, "measure width is non-negative")
        helper.assert_equal((height or 0) >= 0, true, "measure height is non-negative")
        return { width = 0, height = 0 }
      end,
    })
    local root = yoga.node({ flexDirection = "row", width = 10, height = 20 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(calls, 1, "measure call count")
  end, source("cant_call_negative_measure_horizontal"))

  runner:test("measure function can be cleared from a non-leaf node", function()
    local root = yoga.node({}, {
      yoga.node({}),
    })

    yoga.setStyle(root, { measure = nil })

    helper.assert_equal(root.measure, nil, "measure function")
  end, source("can_nullify_measure_func_on_any_node"))

  runner:test("cross-axis auto margin keeps measured size instead of stretch", function()
    local child = yoga.node({
      marginLeft = "auto",
      measure = function()
        return { width = 10, height = 10 }
      end,
    })
    local root = yoga.node({ width = 500, height = 500 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 490, top = 0, width = 10, height = 10 }, "auto margin measured")
  end, source("measure_nodes_with_margin_auto_and_stretch"))

  runner:test("measured child can grow from zero available content space", function()
    local calls = { count = 0 }
    local child = yoga.node(with_measure({
      flexDirection = "column",
      padding = 100,
    }, calls))
    local root = yoga.node({ height = 200, flexDirection = "column", flexGrow = 0 }, {
      child,
    })

    yoga.calculateLayout(root, 282)

    helper.assert_equal(child.layout.width, 282, "zero space grow child width")
    helper.assert_equal(child.layout.top, 0, "zero space grow child top")
  end, source("measure_zero_space_should_grow"))

  runner:test("row measured child with padding follows Yoga layout", function()
    local measured = yoga.node({
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({
      flexDirection = "row",
      paddingLeft = 25,
      paddingTop = 25,
      paddingRight = 25,
      paddingBottom = 25,
      width = 50,
      height = 50,
    }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(measured, { left = 25, top = 25, width = 50, height = 0 }, "row padding measured")
    helper.assert_layout(fixed, { left = 75, top = 25, width = 5, height = 5 }, "row padding fixed")
  end, source("measure_flex_direction_row_and_padding"))

  runner:test("column measured child with padding follows Yoga layout", function()
    local measured = yoga.node({
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({ marginTop = 20, padding = 25, width = 50, height = 50 }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "column padding root")
    helper.assert_layout(measured, { left = 25, top = 25, width = 0, height = 32 }, "column padding measured")
    helper.assert_layout(fixed, { left = 25, top = 57, width = 5, height = 5 }, "column padding fixed")
  end, source("measure_flex_direction_column_and_padding"))

  runner:test("row measured child without padding stretches cross axis", function()
    local measured = yoga.node({
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({ flexDirection = "row", marginTop = 20, width = 50, height = 50 }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "row no padding root")
    helper.assert_layout(measured, { left = 0, top = 0, width = 50, height = 50 }, "row no padding measured")
    helper.assert_layout(fixed, { left = 50, top = 0, width = 5, height = 5 }, "row no padding fixed")
  end, source("measure_flex_direction_row_no_padding"))

  runner:test("row measured child without padding can align flex-start", function()
    local measured = yoga.node({
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({
      flexDirection = "row",
      alignItems = "flex-start",
      marginTop = 20,
      width = 50,
      height = 50,
    }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "row flex-start root")
    helper.assert_layout(measured, { left = 0, top = 0, width = 50, height = 32 }, "row flex-start measured")
    helper.assert_layout(fixed, { left = 50, top = 0, width = 5, height = 5 }, "row flex-start fixed")
  end, source("measure_flex_direction_row_no_padding_align_items_flexstart"))

  runner:test("measured child with fixed size keeps explicit dimensions", function()
    local measured = yoga.node({
      width = 10,
      height = 10,
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({ marginTop = 20, padding = 25, width = 50, height = 50 }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "fixed measure root")
    helper.assert_layout(measured, { left = 25, top = 25, width = 10, height = 10 }, "fixed measured")
    helper.assert_layout(fixed, { left = 25, top = 35, width = 5, height = 5 }, "fixed sibling")
  end, source("measure_with_fixed_size"))

  runner:test("measured child with flex shrink can collapse inside padding", function()
    local measured = yoga.node({
      flexShrink = 1,
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({ marginTop = 20, padding = 25, width = 50, height = 50 }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "flex shrink root")
    helper.assert_layout(measured, { left = 25, top = 25, width = 0, height = 0 }, "flex shrink measured")
    helper.assert_layout(fixed, { left = 25, top = 25, width = 5, height = 5 }, "flex shrink fixed")
  end, source("measure_with_flex_shrink"))

  runner:test("measured child without padding keeps measured height", function()
    local measured = yoga.node({
      flexShrink = 1,
      measure = measure_wrapping_text,
    })
    local fixed = yoga.node({ width = 5, height = 5 })
    local root = yoga.node({ marginTop = 20, width = 50, height = 50 }, {
      measured,
      fixed,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 20, width = 50, height = 50 }, "no padding root")
    helper.assert_layout(measured, { left = 0, top = 0, width = 50, height = 32 }, "no padding measured")
    helper.assert_layout(fixed, { left = 0, top = 32, width = 5, height = 5 }, "no padding fixed")
  end, source("measure_no_padding"))

  runner:test("percent margins resolve on measured children", function()
    local first = yoga.node({ width = 100, height = 100, marginTop = 0, measure = measure_100 })
    local second = yoga.node({ width = 100, height = 100, marginTop = 100, measure = measure_100 })
    local third = yoga.node({ width = 100, height = 100, marginTop = "10%", measure = measure_100 })
    local fourth = yoga.node({ width = 100, height = 100, marginTop = "20%", measure = measure_100 })
    local root = yoga.node({ flexDirection = "row", width = 500, height = 500 }, {
      first,
      second,
      third,
      fourth,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(first, { left = 0, top = 0, width = 100, height = 100 }, "percent margin first")
    helper.assert_layout(second, { left = 100, top = 100, width = 100, height = 100 }, "percent margin second")
    helper.assert_layout(third, { left = 200, top = 50, width = 100, height = 100 }, "percent margin third")
    helper.assert_layout(fourth, { left = 300, top = 100, width = 100, height = 100 }, "percent margin fourth")
  end, source("percent_margin_with_measure_func"))

  runner:test("percent max width and percent padding apply to measured text", function()
    local spacer = yoga.node({})
    local text = yoga.node({
      maxWidth = "50%",
      paddingTop = "50%",
      measure = function()
        return { width = 90, height = 10 }
      end,
    })
    local root = yoga.node({
      flexDirection = "row",
      justifyContent = "space-between",
      alignItems = "center",
      width = 100,
      height = 80,
    }, {
      spacer,
      text,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 80 }, "percent text root")
    helper.assert_layout(spacer, { left = 0, top = 40, width = 0, height = 0 }, "percent text spacer")
    helper.assert_layout(text, { left = 50, top = 10, width = 50, height = 60 }, "percent text")
  end, source("percent_with_text_node"))

  runner:test("percent padding contributes to measured child size", function()
    local first = yoga.node({ width = 100, height = 100, paddingTop = 0, measure = measure_100 })
    local second = yoga.node({ width = 100, height = 100, paddingTop = 100, measure = measure_100 })
    local third = yoga.node({ paddingTop = "10%", measure = measure_100 })
    local fourth = yoga.node({ paddingTop = "20%", measure = measure_100 })
    local root = yoga.node({
      flexDirection = "row",
      alignItems = "flex-start",
      alignContent = "flex-start",
      width = 500,
      height = 500,
    }, {
      first,
      second,
      third,
      fourth,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(first, { left = 0, top = 0, width = 100, height = 100 }, "percent padding first")
    helper.assert_layout(second, { left = 100, top = 0, width = 100, height = 100 }, "percent padding second")
    helper.assert_layout(third, { left = 200, top = 0, width = 100, height = 150 }, "percent padding third")
    helper.assert_layout(fourth, { left = 300, top = 0, width = 100, height = 200 }, "percent padding fourth")
  end, source("percent_padding_with_measure_func"))

  runner:test("percent padding and margin compose on measured children", function()
    local first = yoga.node({ width = 100, height = 100, paddingTop = 0, measure = measure_100 })
    local second = yoga.node({ width = 100, height = 100, paddingTop = 100, measure = measure_100 })
    local third = yoga.node({ paddingTop = "10%", marginTop = "10%", measure = measure_100 })
    local fourth = yoga.node({ paddingTop = "20%", marginTop = "20%", measure = measure_100 })
    local root = yoga.node({
      flexDirection = "row",
      alignItems = "flex-start",
      alignContent = "flex-start",
      width = 500,
      height = 500,
    }, {
      first,
      second,
      third,
      fourth,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(first, { left = 0, top = 0, width = 100, height = 100 }, "percent padding margin first")
    helper.assert_layout(second, { left = 100, top = 0, width = 100, height = 100 }, "percent padding margin second")
    helper.assert_layout(third, { left = 200, top = 50, width = 100, height = 150 }, "percent padding margin third")
    helper.assert_layout(fourth, { left = 300, top = 100, width = 100, height = 200 }, "percent padding margin fourth")
  end, source("percent_padding_and_percent_margin_with_measure_func"))

  runner:test("min width larger than width propagates to auto parent", function()
    local grandchild = yoga.node({ width = 50, minWidth = 100, height = 50 })
    local child = yoga.node({ flexDirection = "row", height = 50 }, {
      grandchild,
    })
    local root = yoga.node({}, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 50 }, "min width root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 50 }, "min width child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 100, height = 50 }, "min width grandchild")
  end, source("min_width_larger_than_width_propagates_to_auto_parent"))

  runner:skip(
    "fixture cannot_add_child_to_node_with_measure_func [cannot_add_child_to_node_with_measure_func]",
    "Lua API does not enforce Yoga's measure-node leaf invariant yet",
    source("cannot_add_child_to_node_with_measure_func")
  )

  runner:skip(
    "fixture cannot_add_nonnull_measure_func_to_non_leaf_node [cannot_add_nonnull_measure_func_to_non_leaf_node]",
    "Lua API does not enforce Yoga's measure-node leaf invariant yet",
    source("cannot_add_nonnull_measure_func_to_non_leaf_node")
  )

  runner:skip(
    "fixture measure_content_box [measure_content_box]",
    "boxSizing = content-box is not implemented yet",
    source("measure_content_box")
  )

  runner:skip(
    "fixture measure_border_box [measure_border_box]",
    "boxSizing style support is not implemented yet",
    source("measure_border_box")
  )
end
