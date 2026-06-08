local yoga = require("yoga")

return function(runner, helper)
  runner:test("row flex shrink distributes overflow equally", function()
    local root = yoga.node({ width = 500, height = 100, flexDirection = "row" }, {
      yoga.node({ width = 500, height = 40, flexShrink = 1 }),
      yoga.node({ width = 500, height = 40, flexShrink = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 250, height = 40 }, "first shrink child")
    helper.assert_layout(root.children[2], { left = 250, top = 0, width = 250, height = 40 }, "second shrink child")
  end)

  runner:test("column flex shrink can shrink one child to zero", function()
    local root = yoga.node({ width = 50, height = 75 }, {
      yoga.node({ width = 50, height = 50 }),
      yoga.node({ width = 50, height = 50, flexShrink = 1 }),
      yoga.node({ width = 50, height = 50 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 50, height = 50 }, "first child")
    helper.assert_layout(root.children[2], { left = 0, top = 50, width = 50, height = 0 }, "shrink child")
    helper.assert_layout(root.children[3], { left = 0, top = 50, width = 50, height = 50 }, "overflow child")
  end)

  runner:test("flex shrink scales by base size", function()
    local root = yoga.node({ width = 200, height = 40, flexDirection = "row" }, {
      yoga.node({ width = 200, flexShrink = 1 }),
      yoga.node({ width = 100, flexShrink = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 133, height = 40 }, "large shrink child")
    helper.assert_layout(root.children[2], { left = 133, top = 0, width = 67, height = 40 }, "small shrink child")
  end)

  runner:test("flex shrink uses flex basis as base size", function()
    local root = yoga.node({ width = 100, height = 40, flexDirection = "row" }, {
      yoga.node({ flexBasis = 80, flexShrink = 1 }),
      yoga.node({ flexBasis = 80, flexShrink = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 50, height = 40 }, "first basis shrink child")
    helper.assert_layout(root.children[2], { left = 50, top = 0, width = 50, height = 40 }, "second basis shrink child")
  end)

  runner:test("negative flex shorthand resolves to flex shrink", function()
    local root = yoga.node({ width = 100, height = 40, flexDirection = "row" }, {
      yoga.node({ flex = -1, width = 200 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 100, height = 40 }, "negative flex child")
  end)
end
