local yoga = require("yoga")

return function(runner, helper)
  runner:test("row container derives automatic height from children", function()
    local root = yoga.node({ width = 320, flexDirection = "row" }, {
      yoga.node({ height = 10, flexGrow = 1 }),
      yoga.node({ height = 16, flexGrow = 1 }),
      yoga.node({ height = 12, flexGrow = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 320, height = 16 }, "root")
    helper.assert_layout(root.children[2], { left = 107, top = 0, width = 106, height = 16 }, "tall child")
  end)

  runner:test("column container derives automatic width from children", function()
    local root = yoga.node({ height = 320 }, {
      yoga.node({ width = 10, flexGrow = 1 }),
      yoga.node({ width = 16, flexGrow = 1 }),
      yoga.node({ width = 12, flexGrow = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 16, height = 320 }, "root")
    helper.assert_layout(root.children[2], { left = 0, top = 107, width = 16, height = 106 }, "wide child")
  end)
end
