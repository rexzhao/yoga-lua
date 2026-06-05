local yoga = require("yoga")

return function(runner, helper)
  runner:test("clean repeated calculateLayout reuses cached layout", function()
    local calls = 0
    local child = yoga.node({
      measure = function()
        calls = calls + 1
        return { width = 20, height = 10 }
      end,
    })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)
    yoga.calculateLayout(root)

    helper.assert_equal(calls, 1, "measure calls after cache hit")
    helper.assert_layout(child, { left = 0, top = 0, width = 20, height = 10 }, "cached child layout")
  end)

  runner:test("dirty node invalidates cached layout", function()
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
    yoga.calculateLayout(root)
    yoga.markDirty(child)
    yoga.calculateLayout(root)

    helper.assert_equal(calls, 2, "measure calls after dirty invalidation")
    helper.assert_layout(child, { left = 0, top = 0, width = 22, height = 10 }, "recomputed child layout")
  end)

  runner:test("layout cache key includes available size and direction", function()
    local calls = 0
    local child = yoga.node({
      measure = function()
        calls = calls + 1
        return { width = 20, height = 10 }
      end,
    })
    local root = yoga.node({ height = 20, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root, 100, 20, "ltr")
    yoga.calculateLayout(root, 100, 20, "ltr")
    yoga.calculateLayout(root, 120, 20, "ltr")
    yoga.calculateLayout(root, 120, 20, "rtl")

    helper.assert_equal(calls, 2, "measure calls across available sizes")
    helper.assert_layout(child, { left = 100, top = 0, width = 20, height = 10 }, "direction change relayout")
  end)
end
