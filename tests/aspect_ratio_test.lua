local yoga = require("yoga")

return function(runner, helper)
  runner:test("root derives height from width and aspect ratio", function()
    local root = yoga.node({ width = 120, aspectRatio = 2 })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 120, height = 60 }, "root")
  end)

  runner:test("row child derives cross height from main width", function()
    local root = yoga.node({ width = 200, height = 120, flexDirection = "row" }, {
      yoga.node({ width = 80, aspectRatio = 2 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 80, height = 40 }, "child")
  end)

  runner:test("row child derives main width from explicit height", function()
    local root = yoga.node({ width = 200, height = 120, flexDirection = "row" }, {
      yoga.node({ height = 30, aspectRatio = 3 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 90, height = 30 }, "child")
  end)

  runner:test("column child derives main height from explicit width", function()
    local root = yoga.node({ width = 120, height = 200 }, {
      yoga.node({ width = 80, aspectRatio = 4 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 80, height = 20 }, "child")
  end)

  runner:test("flex grow width drives aspect ratio height", function()
    local root = yoga.node({ width = 180, height = 120, flexDirection = "row" }, {
      yoga.node({ flex = 1, aspectRatio = 3 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 180, height = 60 }, "child")
  end)

  runner:test("zero aspect ratio behaves like auto", function()
    local root = yoga.node({ width = 120, height = 120 }, {
      yoga.node({ width = 50, aspectRatio = 0 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 50, height = 0 }, "child")
  end)
end
