local yoga = require("yoga")

return function(runner, helper)
  runner:test("min and max override explicit root size", function()
    local min_root = yoga.node({ width = 50, height = 40, minWidth = 100, minHeight = 80 })
    local max_root = yoga.node({ width = 200, height = 160, maxWidth = 120, maxHeight = 90 })

    yoga.calculateLayout(min_root)
    yoga.calculateLayout(max_root)

    helper.assert_layout(min_root, { left = 0, top = 0, width = 100, height = 80 }, "min root")
    helper.assert_layout(max_root, { left = 0, top = 0, width = 120, height = 90 }, "max root")
  end)

  runner:test("max constrains stretched cross axis", function()
    local root = yoga.node({ width = 100, height = 100 }, {
      yoga.node({ height = 10, maxWidth = 50 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 50, height = 10 }, "max stretched child")
  end)

  runner:test("min constrains measured size", function()
    local child = yoga.node({
      minWidth = 40,
      minHeight = 20,
      measure = function()
        return { width = 10, height = 8 }
      end,
    })

    local root = yoga.node({ width = 100, height = 80, flexDirection = "row", alignItems = "flex-start" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 40, height = 20 }, "min measured child")
  end)

  runner:test("percentage min max use parent dimensions", function()
    local root = yoga.node({ width = 100, height = 100, alignItems = "flex-start" }, {
      yoga.node({
        minWidth = "10%",
        maxWidth = "10%",
        minHeight = "10%",
        maxHeight = "10%",
      }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 10, height = 10 }, "percentage constrained child")
  end)
end
