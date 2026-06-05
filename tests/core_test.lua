local yoga = require("yoga")

return function(runner, helper)
  runner:test("core fixed column layout", function()
    local root = yoga.node({ width = 100, height = 80, flexDirection = "column", padding = 10, gap = 5 }, {
      yoga.node({ height = 20 }),
      yoga.node({ height = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 80 }, "root")
    helper.assert_layout(root.children[1], { left = 10, top = 10, width = 80, height = 20 }, "first child")
    helper.assert_layout(root.children[2], { left = 10, top = 35, width = 80, height = 30 }, "second child")
  end)

  runner:test("edge padding and margin", function()
    local root = yoga.node({
      width = 120,
      height = 90,
      flexDirection = "column",
      paddingLeft = 10,
      paddingRight = 20,
      paddingTop = 5,
      paddingBottom = 7,
      gap = 3,
    }, {
      yoga.node({ height = 10, marginLeft = 2, marginRight = 4, marginTop = 6, marginBottom = 8 }),
      yoga.node({ height = 12, marginHorizontal = 5 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 12, top = 11, width = 84, height = 10 }, "first child")
    helper.assert_layout(root.children[2], { left = 15, top = 32, width = 80, height = 12 }, "second child")
  end)

  runner:test("row flex grow distributes remaining width", function()
    local root = yoga.node({ width = 300, height = 80, flexDirection = "row", padding = 10, gap = 5 }, {
      yoga.node({ width = 50 }),
      yoga.node({ flexGrow = 1 }),
      yoga.node({ flex = 2 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 10, top = 10, width = 50, height = 60 }, "fixed child")
    helper.assert_layout(root.children[2], { left = 65, top = 10, width = 73.333333333333, height = 60 }, "grow child")
    helper.assert_layout(root.children[3], { left = 143.33333333333, top = 10, width = 146.66666666667, height = 60 }, "double grow child")
  end)

  runner:test("column flex grow distributes remaining height", function()
    local root = yoga.node({ width = 100, height = 200, flexDirection = "column", paddingVertical = 10, gap = 4 }, {
      yoga.node({ height = 40 }),
      yoga.node({ flex = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 10, width = 100, height = 40 }, "fixed child")
    helper.assert_layout(root.children[2], { left = 0, top = 54, width = 100, height = 136 }, "grow child")
  end)
end
