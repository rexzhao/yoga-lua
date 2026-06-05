local yoga = require("yoga")

return function(runner, helper)
  runner:test("display none child is excluded from flex grow", function()
    local hidden = yoga.node({ flexGrow = 1, display = "none" })
    local root = yoga.node({ width = 100, height = 100, flexDirection = "row" }, {
      yoga.node({ flexGrow = 1 }),
      hidden,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 100, height = 100 }, "visible child")
    helper.assert_layout(hidden, { left = 0, top = 0, width = 0, height = 0 }, "hidden child")
  end)

  runner:test("display none child ignores size margin and gap", function()
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row", gap = 10 }, {
      yoga.node({ width = 20 }),
      yoga.node({ width = 20, height = 20, margin = 10, display = "none" }),
      yoga.node({ width = 20 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 20, height = 20 }, "first visible child")
    helper.assert_layout(root.children[2], { left = 0, top = 0, width = 0, height = 0 }, "hidden child")
    helper.assert_layout(root.children[3], { left = 30, top = 0, width = 20, height = 20 }, "second visible child")
  end)

  runner:test("display none zeroes hidden subtree", function()
    local hidden_child = yoga.node({ width = 20, height = 20 })
    local hidden = yoga.node({ flexGrow = 1, display = "none" }, {
      hidden_child,
    })
    local root = yoga.node({ width = 100, height = 100, flexDirection = "row" }, {
      yoga.node({ flexGrow = 1 }),
      hidden,
      yoga.node({ flexGrow = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 50, height = 100 }, "first visible child")
    helper.assert_layout(hidden, { left = 0, top = 0, width = 0, height = 0 }, "hidden parent")
    helper.assert_layout(hidden_child, { left = 0, top = 0, width = 0, height = 0 }, "hidden child")
    helper.assert_layout(root.children[3], { left = 50, top = 0, width = 50, height = 100 }, "second visible child")
  end)

  runner:test("display none root zeroes entire tree", function()
    local root_child = yoga.node({ width = 20, height = 20 })
    local root = yoga.node({ width = 100, height = 100, display = "none" }, {
      root_child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 0, height = 0 }, "hidden root")
    helper.assert_layout(root_child, { left = 0, top = 0, width = 0, height = 0 }, "hidden root child")
  end)
end
