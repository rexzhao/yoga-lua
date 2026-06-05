local yoga = require("yoga")
local ui = require("ui")

return function(runner, helper)
  runner:test("measured row child uses natural main and cross size", function()
    local calls = {}
    local child = yoga.node({
      measure = function(width, width_mode, height, height_mode, node)
        calls[#calls + 1] = {
          width = width,
          width_mode = width_mode,
          height = height,
          height_mode = height_mode,
          node = node,
        }

        return { width = 42, height = 18 }
      end,
    })

    local root = yoga.node({ width = 100, height = 40, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 42, height = 18 }, "measured child")
    helper.assert_equal(#calls, 1, "measure call count")
    helper.assert_equal(calls[1].width, 100, "measure available width")
    helper.assert_equal(calls[1].width_mode, yoga.MEASURE_MODE_AT_MOST, "measure width mode")
    helper.assert_equal(calls[1].height, 40, "measure available height")
    helper.assert_equal(calls[1].height_mode, yoga.MEASURE_MODE_AT_MOST, "measure height mode")
    helper.assert_equal(calls[1].node, child, "measure node argument")
  end)

  runner:test("explicit row main size overrides measured width", function()
    local child = yoga.node({
      width = 30,
      measure = function()
        return { width = 42, height = 18 }
      end,
    })

    local root = yoga.node({ width = 100, height = 40, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 30, height = 18 }, "explicit width child")
  end)

  runner:test("measured column child uses natural main and cross size", function()
    local child = yoga.node({
      measure = function()
        return { width = 32, height = 20 }
      end,
    })

    local root = yoga.node({ width = 100, height = 80, flexDirection = "column", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 32, height = 20 }, "measured column child")
  end)

  runner:test("ui text forwards measure prop", function()
    local child = ui.text("Measured", {
      measure = function()
        return 25, 11
      end,
    })

    local root = ui.div({ style = { width = 100, height = 40, flexDirection = "row", alignItems = "flex-start" } }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 25, height = 11 }, "measured text")
  end)
end
