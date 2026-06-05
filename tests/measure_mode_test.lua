local yoga = require("yoga")

local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "YGMeasureModeTest.cpp",
    generated = false,
    test = test,
  }
end

local function make_measured_node(calls)
  return yoga.node({
    measure = function(width, width_mode, height, height_mode)
      calls[#calls + 1] = {
        width = width,
        width_mode = width_mode,
        height = height,
        height_mode = height_mode,
      }

      return {
        width = width_mode == yoga.MEASURE_MODE_UNDEFINED and 10 or width,
        height = height_mode == yoga.MEASURE_MODE_UNDEFINED and 10 or height,
      }
    end,
  })
end

local function assert_single_call(helper, calls, label)
  helper.assert_equal(#calls, 1, label .. " call count")
  return calls[1]
end

return function(runner, helper)
  runner:test("exactly measures stretched child cross axis in column", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "column stretch")
    helper.assert_equal(call.width, 100, "column stretch width")
    helper.assert_equal(call.width_mode, yoga.MEASURE_MODE_EXACTLY, "column stretch width mode")
    helper.assert_equal(call.height, 100, "column stretch height")
    helper.assert_equal(call.height_mode, yoga.MEASURE_MODE_AT_MOST, "column stretch height mode")
  end, source("exactly_measure_stretched_child_column"))

  runner:test("exactly measures stretched child cross axis in row", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ flexDirection = "row", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "row stretch")
    helper.assert_equal(call.width, 100, "row stretch width")
    helper.assert_equal(call.width_mode, yoga.MEASURE_MODE_AT_MOST, "row stretch width mode")
    helper.assert_equal(call.height, 100, "row stretch height")
    helper.assert_equal(call.height_mode, yoga.MEASURE_MODE_EXACTLY, "row stretch height mode")
  end, source("exactly_measure_stretched_child_row"))

  runner:test("at most measures main axis in column", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "column main")
    helper.assert_equal(call.height, 100, "column main height")
    helper.assert_equal(call.height_mode, yoga.MEASURE_MODE_AT_MOST, "column main height mode")
  end, source("at_most_main_axis_column"))

  runner:test("at most measures cross axis in non-stretched column", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ alignItems = "flex-start", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "column flex-start")
    helper.assert_equal(call.width, 100, "column flex-start width")
    helper.assert_equal(call.width_mode, yoga.MEASURE_MODE_AT_MOST, "column flex-start width mode")
  end, source("at_most_cross_axis_column"))

  runner:test("at most measures main axis in row", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ flexDirection = "row", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "row main")
    helper.assert_equal(call.width, 100, "row main width")
    helper.assert_equal(call.width_mode, yoga.MEASURE_MODE_AT_MOST, "row main width mode")
  end, source("at_most_main_axis_row"))

  runner:test("at most measures cross axis in non-stretched row", function()
    local calls = {}
    local child = make_measured_node(calls)
    local root = yoga.node({ flexDirection = "row", alignItems = "flex-start", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    local call = assert_single_call(helper, calls, "row flex-start")
    helper.assert_equal(call.height, 100, "row flex-start height")
    helper.assert_equal(call.height_mode, yoga.MEASURE_MODE_AT_MOST, "row flex-start height mode")
  end, source("at_most_cross_axis_row"))
end
