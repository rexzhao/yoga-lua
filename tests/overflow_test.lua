local yoga = require("yoga")

return function(runner, helper)
  runner:test("overflow scroll column measures child with undefined main axis", function()
    local calls = {}
    local child = yoga.node({
      measure = function(width, width_mode, height, height_mode)
        calls[#calls + 1] = {
          width = width,
          width_mode = width_mode,
          height = height,
          height_mode = height_mode,
        }

        return { width = 50, height = 150 }
      end,
    })
    local root = yoga.node({
      width = 100,
      height = 100,
      alignItems = "flex-start",
      overflow = "scroll",
    }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(#calls, 1, "measure call count")
    helper.assert_equal(calls[1].width, 100, "column scroll width")
    helper.assert_equal(calls[1].width_mode, yoga.MEASURE_MODE_AT_MOST, "column scroll width mode")
    helper.assert_equal(calls[1].height, nil, "column scroll height")
    helper.assert_equal(calls[1].height_mode, yoga.MEASURE_MODE_UNDEFINED, "column scroll height mode")
    helper.assert_layout(child, { left = 0, top = 0, width = 50, height = 150 }, "column scroll child")
  end)

  runner:test("overflow scroll row measures child with undefined main axis", function()
    local calls = {}
    local child = yoga.node({
      measure = function(width, width_mode, height, height_mode)
        calls[#calls + 1] = {
          width = width,
          width_mode = width_mode,
          height = height,
          height_mode = height_mode,
        }

        return { width = 150, height = 50 }
      end,
    })
    local root = yoga.node({
      width = 100,
      height = 100,
      flexDirection = "row",
      alignItems = "flex-start",
      overflow = "scroll",
    }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(#calls, 1, "measure call count")
    helper.assert_equal(calls[1].width, nil, "row scroll width")
    helper.assert_equal(calls[1].width_mode, yoga.MEASURE_MODE_UNDEFINED, "row scroll width mode")
    helper.assert_equal(calls[1].height, 100, "row scroll height")
    helper.assert_equal(calls[1].height_mode, yoga.MEASURE_MODE_AT_MOST, "row scroll height mode")
    helper.assert_layout(child, { left = 0, top = 0, width = 150, height = 50 }, "row scroll child")
  end)
end
