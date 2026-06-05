local yoga = require("yoga")

return function(runner, helper)
  runner:test("absolute child is excluded from flex flow", function()
    local absolute = yoga.node({ position = "absolute", left = 10, top = 15, width = 20, height = 25 })
    local root = yoga.node({ width = 100, height = 80, flexDirection = "row" }, {
      yoga.node({ flexGrow = 1 }),
      absolute,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 100, height = 80 }, "flow child")
    helper.assert_layout(absolute, { left = 10, top = 15, width = 20, height = 25 }, "absolute child")
  end)

  runner:test("absolute child supports right and bottom offsets", function()
    local child = yoga.node({ position = "absolute", right = 5, bottom = 6, width = 10, height = 20 })
    local root = yoga.node({ width = 100, height = 80 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 85, top = 54, width = 10, height = 20 }, "right bottom child")
  end)

  runner:test("absolute child derives size from opposing insets", function()
    local child = yoga.node({ position = "absolute", left = 10, right = 15, top = 5, bottom = 25 })
    local root = yoga.node({ width = 100, height = 80 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 10, top = 5, width = 75, height = 50 }, "inset child")
  end)

  runner:test("absolute child supports percentage offsets and size", function()
    local child = yoga.node({
      position = "absolute",
      left = "10%",
      top = "20%",
      width = "25%",
      height = "30%",
    })
    local root = yoga.node({ width = 200, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 20, top = 20, width = 50, height = 30 }, "percentage absolute child")
  end)

  runner:test("absolute child uses parent alignment when offsets are absent", function()
    local child = yoga.node({ position = "absolute", width = 60, height = 40 })
    local root = yoga.node({ width = 110, height = 100, alignItems = "center", justifyContent = "center" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 25, top = 30, width = 60, height = 40 }, "aligned absolute child")
  end)

  runner:test("absolute child is positioned inside parent padding", function()
    local child = yoga.node({ position = "absolute", width = 20, height = 20 })
    local root = yoga.node({ width = 100, height = 100, padding = 10 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 10, top = 10, width = 20, height = 20 }, "padded absolute child")
  end)
end
