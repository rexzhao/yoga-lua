local yoga = require("yoga")

return function(runner, helper)
  runner:test("row uses columnGap on main axis", function()
    local root = yoga.node({ width = 100, height = 40, flexDirection = "row", columnGap = 10, rowGap = 40 }, {
      yoga.node({ width = 20 }),
      yoga.node({ width = 20 }),
      yoga.node({ width = 20 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 20, height = 40 }, "first child")
    helper.assert_layout(root.children[2], { left = 30, top = 0, width = 20, height = 40 }, "second child")
    helper.assert_layout(root.children[3], { left = 60, top = 0, width = 20, height = 40 }, "third child")
  end)

  runner:test("column uses rowGap on main axis", function()
    local root = yoga.node({ width = 40, height = 100, flexDirection = "column", rowGap = 10, columnGap = 40 }, {
      yoga.node({ height = 20 }),
      yoga.node({ height = 20 }),
      yoga.node({ height = 20 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 40, height = 20 }, "first child")
    helper.assert_layout(root.children[2], { left = 0, top = 30, width = 40, height = 20 }, "second child")
    helper.assert_layout(root.children[3], { left = 0, top = 60, width = 40, height = 20 }, "third child")
  end)

  runner:test("axis gaps fall back to gap", function()
    local root = yoga.node({ width = 100, height = 40, flexDirection = "row", gap = 5 }, {
      yoga.node({ width = 20 }),
      yoga.node({ width = 20 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 20, height = 40 }, "first child")
    helper.assert_layout(root.children[2], { left = 25, top = 0, width = 20, height = 40 }, "second child")
  end)
end
