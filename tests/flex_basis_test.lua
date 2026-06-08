local yoga = require("yoga")

return function(runner, helper)
  runner:test("row flex basis participates in grow distribution", function()
    local root = yoga.node({ width = 200, height = 40, flexDirection = "row" }, {
      yoga.node({ flexGrow = 1, flexBasis = 100 }),
      yoga.node({ flexGrow = 1, flexBasis = 50 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 125, height = 40 }, "first basis child")
    helper.assert_layout(root.children[2], { left = 125, top = 0, width = 75, height = 40 }, "second basis child")
  end)

  runner:test("column flex basis participates in grow distribution", function()
    local root = yoga.node({ width = 40, height = 200 }, {
      yoga.node({ flexGrow = 1, flexBasis = 100 }),
      yoga.node({ flexGrow = 1, flexBasis = 50 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 40, height = 125 }, "first basis child")
    helper.assert_layout(root.children[2], { left = 0, top = 125, width = 40, height = 75 }, "second basis child")
  end)

  runner:test("flex basis overrides explicit main-axis size", function()
    local root = yoga.node({ width = 200, height = 40, flexDirection = "row" }, {
      yoga.node({ width = 20, flexBasis = 80 }),
      yoga.node({ flexGrow = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 80, height = 40 }, "basis overrides width")
    helper.assert_layout(root.children[2], { left = 80, top = 0, width = 120, height = 40 }, "remaining child")
  end)

  runner:test("percentage flex basis resolves against parent main size", function()
    local root = yoga.node({ width = 200, height = 40, flexDirection = "row" }, {
      yoga.node({ flexGrow = 1, flexBasis = "50%" }),
      yoga.node({ flexGrow = 1, flexBasis = "25%" }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 125, height = 40 }, "first percent basis")
    helper.assert_layout(root.children[2], { left = 125, top = 0, width = 75, height = 40 }, "second percent basis")
  end)

  runner:test("flex grow below one consumes partial remaining space", function()
    local root = yoga.node({ width = 200, height = 500 }, {
      yoga.node({ flexGrow = 0.2, flexBasis = 40 }),
      yoga.node({ flexGrow = 0.2 }),
      yoga.node({ flexGrow = 0.4 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 200, height = 132 }, "first partial grow child")
    helper.assert_layout(root.children[2], { left = 0, top = 132, width = 200, height = 92 }, "second partial grow child")
    helper.assert_layout(root.children[3], { left = 0, top = 224, width = 200, height = 184 }, "third partial grow child")
  end)

  runner:test("positive flex uses zero as implicit flex basis", function()
    local root = yoga.node({ width = 300, height = 40, flexDirection = "row" }, {
      yoga.node({ flex = 1, width = 100 }),
      yoga.node({ flex = 1, width = 200 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 150, height = 40 }, "first flex shorthand child")
    helper.assert_layout(root.children[2], { left = 150, top = 0, width = 150, height = 40 }, "second flex shorthand child")
  end)
end
