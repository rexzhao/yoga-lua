local yoga = require("yoga")

return function(runner, helper)
  runner:test("clean measured child reuses cached measurement during parent relayout", function()
    local calls = 0
    local child = yoga.node({
      measure = function()
        calls = calls + 1
        return { width = 20 + calls, height = 10 }
      end,
    })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)
    yoga.markDirty(root)
    yoga.calculateLayout(root)

    helper.assert_equal(calls, 1, "measure calls after parent-only relayout")
    helper.assert_layout(child, { left = 0, top = 0, width = 21, height = 10 }, "cached measured child")
  end)

  runner:test("dirty measured child invalidates cached measurement", function()
    local calls = 0
    local child = yoga.node({
      measure = function()
        calls = calls + 1
        return { width = 20 + calls, height = 10 }
      end,
    })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)
    yoga.markDirty(child)
    yoga.calculateLayout(root)

    helper.assert_equal(calls, 2, "measure calls after child dirty")
    helper.assert_layout(child, { left = 0, top = 0, width = 22, height = 10 }, "remeasured child")
  end)

  runner:test("measure cache key includes child available size", function()
    local calls = {}
    local child = yoga.node({
      measure = function(width, width_mode, height, height_mode)
        calls[#calls + 1] = {
          width = width,
          width_mode = width_mode,
          height = height,
          height_mode = height_mode,
        }

        return { width = 20, height = 10 }
      end,
    })
    local root = yoga.node({ flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root, 100, 20)
    yoga.markDirty(root)
    yoga.calculateLayout(root, 100, 20)
    yoga.calculateLayout(root, 120, 20)

    helper.assert_equal(#calls, 2, "measure calls across available sizes")
    helper.assert_equal(calls[1].width, 100, "first available width")
    helper.assert_equal(calls[1].width_mode, yoga.MEASURE_MODE_AT_MOST, "first width mode")
    helper.assert_equal(calls[2].width, 120, "second available width")
    helper.assert_equal(calls[2].width_mode, yoga.MEASURE_MODE_AT_MOST, "second width mode")
  end)

  runner:test("measure cache key includes measure modes", function()
    local calls = {}
    local root = yoga.node({
      measure = function(width, width_mode, height, height_mode)
        calls[#calls + 1] = {
          width = width,
          width_mode = width_mode,
          height = height,
          height_mode = height_mode,
        }

        return { width = 20, height = 10 }
      end,
    })

    yoga.calculateLayout(root)
    yoga.calculateLayout(root)
    yoga.calculateLayout(root, 100)

    helper.assert_equal(#calls, 2, "measure calls across modes")
    helper.assert_equal(calls[1].width, nil, "undefined available width")
    helper.assert_equal(calls[1].width_mode, yoga.MEASURE_MODE_UNDEFINED, "undefined width mode")
    helper.assert_equal(calls[2].width, 100, "at-most available width")
    helper.assert_equal(calls[2].width_mode, yoga.MEASURE_MODE_AT_MOST, "at-most width mode")
  end)
end
