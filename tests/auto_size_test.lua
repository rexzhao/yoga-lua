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

  runner:test("row container derives automatic width from children and gap", function()
    local root = yoga.node({ height = 100, flexDirection = "row", columnGap = 10 }, {
      yoga.node({ width = 10 }),
      yoga.node({ width = 20 }),
      yoga.node({ width = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 80, height = 100 }, "root")
    helper.assert_layout(root.children[2], { left = 20, top = 0, width = 20, height = 100 }, "middle child")
    helper.assert_layout(root.children[3], { left = 50, top = 0, width = 30, height = 100 }, "last child")
  end)

  runner:test("column container derives automatic height from children and gap", function()
    local root = yoga.node({ width = 100, rowGap = 10 }, {
      yoga.node({ height = 10 }),
      yoga.node({ height = 20 }),
      yoga.node({ height = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 80 }, "root")
    helper.assert_layout(root.children[2], { left = 0, top = 20, width = 100, height = 20 }, "middle child")
    helper.assert_layout(root.children[3], { left = 0, top = 50, width = 100, height = 30 }, "last child")
  end)
end
