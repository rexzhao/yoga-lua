local yoga = require("yoga")

return function(runner, helper)
  runner:test("row wrap creates multiple lines and auto height", function()
    local root = yoga.node({ width = 100, flexDirection = "row", flexWrap = "wrap" }, {
      yoga.node({ width = 30, height = 30 }),
      yoga.node({ width = 30, height = 30 }),
      yoga.node({ width = 30, height = 30 }),
      yoga.node({ width = 30, height = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 60 }, "root")
    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 30, height = 30 }, "first")
    helper.assert_layout(root.children[2], { left = 30, top = 0, width = 30, height = 30 }, "second")
    helper.assert_layout(root.children[3], { left = 60, top = 0, width = 30, height = 30 }, "third")
    helper.assert_layout(root.children[4], { left = 0, top = 30, width = 30, height = 30 }, "fourth")
  end)

  runner:test("row wrap aligns items per line to flex end", function()
    local root = yoga.node({ width = 100, flexDirection = "row", flexWrap = "wrap", alignItems = "flex-end" }, {
      yoga.node({ width = 30, height = 10 }),
      yoga.node({ width = 30, height = 20 }),
      yoga.node({ width = 30, height = 30 }),
      yoga.node({ width = 30, height = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 60 }, "root")
    helper.assert_layout(root.children[1], { left = 0, top = 20, width = 30, height = 10 }, "first")
    helper.assert_layout(root.children[2], { left = 30, top = 10, width = 30, height = 20 }, "second")
    helper.assert_layout(root.children[3], { left = 60, top = 0, width = 30, height = 30 }, "third")
    helper.assert_layout(root.children[4], { left = 0, top = 30, width = 30, height = 30 }, "fourth")
  end)

  runner:test("row wrap aligns items per line to center", function()
    local root = yoga.node({ width = 100, flexDirection = "row", flexWrap = "wrap", alignItems = "center" }, {
      yoga.node({ width = 30, height = 10 }),
      yoga.node({ width = 30, height = 20 }),
      yoga.node({ width = 30, height = 30 }),
      yoga.node({ width = 30, height = 30 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 60 }, "root")
    helper.assert_layout(root.children[1], { left = 0, top = 10, width = 30, height = 10 }, "first")
    helper.assert_layout(root.children[2], { left = 30, top = 5, width = 30, height = 20 }, "second")
    helper.assert_layout(root.children[3], { left = 60, top = 0, width = 30, height = 30 }, "third")
    helper.assert_layout(root.children[4], { left = 0, top = 30, width = 30, height = 30 }, "fourth")
  end)

  runner:test("row wrap uses columnGap and rowGap", function()
    local children = {}

    for index = 1, 9 do
      children[index] = yoga.node({ width = 20, height = 20 })
    end

    local root = yoga.node({ width = 80, flexDirection = "row", flexWrap = "wrap", columnGap = 10, rowGap = 20 }, children)

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 80, height = 100 }, "root")
    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 20, height = 20 }, "first")
    helper.assert_layout(root.children[2], { left = 30, top = 0, width = 20, height = 20 }, "second")
    helper.assert_layout(root.children[3], { left = 60, top = 0, width = 20, height = 20 }, "third")
    helper.assert_layout(root.children[4], { left = 0, top = 40, width = 20, height = 20 }, "fourth")
    helper.assert_layout(root.children[9], { left = 60, top = 80, width = 20, height = 20 }, "ninth")
  end)

  runner:test("row wrap honors min width when flex basis would fit", function()
    local root = yoga.node({ width = 100, flexDirection = "row", flexWrap = "wrap" }, {
      yoga.node({ flexBasis = 50, minWidth = 55, height = 50 }),
      yoga.node({ flexBasis = 50, minWidth = 55, height = 50 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "root")
    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 55, height = 50 }, "first")
    helper.assert_layout(root.children[2], { left = 0, top = 50, width = 55, height = 50 }, "second")
  end)
end
