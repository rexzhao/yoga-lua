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

  runner:test("dirty leaf relayout skips clean sibling subtree", function()
    local dirty_leaf = yoga.node({ width = 10, height = 10 })
    local dirty_branch = yoga.node({ width = 20, height = 20 }, {
      dirty_leaf,
    })
    local clean_leaf = yoga.node({ width = 10, height = 10 })
    local clean_branch = yoga.node({ width = 20, height = 20 }, {
      clean_leaf,
    })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row" }, {
      dirty_branch,
      clean_branch,
    })

    clean_branch._debugCountLayout = true
    clean_leaf._debugCountLayout = true

    yoga.calculateLayout(root)
    helper.assert_equal(clean_branch._debugLayoutCount, 1, "clean branch first layout")
    helper.assert_equal(clean_leaf._debugLayoutCount, 1, "clean leaf first layout")

    yoga.markDirty(dirty_leaf)
    yoga.calculateLayout(root)

    helper.assert_equal(clean_branch._debugLayoutCount, 1, "clean branch skipped after unrelated dirty leaf")
    helper.assert_equal(clean_leaf._debugLayoutCount, 1, "clean leaf skipped after unrelated dirty leaf")
  end)

  runner:test("dirty leaf relayout skips clean sibling subtree rounding", function()
    local dirty_leaf = yoga.node({ width = 10.2, height = 10.2 })
    local dirty_branch = yoga.node({ width = 20.2, height = 20.2 }, {
      dirty_leaf,
    })
    local clean_leaf = yoga.node({ width = 10.2, height = 10.2, marginLeft = 0.25 })
    local clean_branch = yoga.node({ width = 20.2, height = 20.2 }, {
      clean_leaf,
    })
    local root = yoga.node({ width = 100.2, height = 20.2, flexDirection = "row" }, {
      dirty_branch,
      clean_branch,
    })

    yoga.calculateLayout(root)
    local clean_left = clean_leaf.layout.left
    local clean_width = clean_leaf.layout.width

    yoga.markDirty(dirty_leaf)
    yoga._resetDebugStats()
    yoga.calculateLayout(root)
    local stats = yoga._debugStats()
    yoga._clearDebugStats()

    helper.assert_equal(stats.roundedSkippedSubtrees > 0, true, "clean subtree rounding skipped")
    helper.assert_near(clean_leaf.layout.left, clean_left, "clean leaf left after skipped rounding")
    helper.assert_near(clean_leaf.layout.width, clean_width, "clean leaf width after skipped rounding")
  end)

  runner:test("changed parent constraints relayout clean child", function()
    local child = yoga.node({ height = 10 })
    child._debugCountLayout = true
    local root = yoga.node({ height = 20 }, {
      child,
    })

    yoga.calculateLayout(root, 100, 20)
    yoga.calculateLayout(root, 120, 20)

    helper.assert_equal(child._debugLayoutCount, 2, "clean child relayouts when available width changes")
    helper.assert_layout(child, { left = 0, top = 0, width = 120, height = 10 }, "child uses new parent width")
  end)
end
