local yoga = require("yoga")

return function(runner, helper)
  runner:test("relative left and top shift without affecting sibling flow", function()
    local first = yoga.node({ width = 20, height = 20, left = 10, top = 5 })
    local second = yoga.node({ width = 20, height = 20 })
    local root = yoga.node({ width = 100, height = 80 }, { first, second })

    yoga.calculateLayout(root)

    helper.assert_layout(first, { left = 10, top = 5, width = 20, height = 20 }, "relative first")
    helper.assert_layout(second, { left = 0, top = 20, width = 20, height = 20 }, "flow sibling")
  end)

  runner:test("relative right and bottom move node in negative direction", function()
    local first = yoga.node({ width = 20, height = 20, right = 10, bottom = 5 })
    local second = yoga.node({ width = 20, height = 20 })
    local root = yoga.node({ width = 100, height = 50, flexDirection = "row" }, { first, second })

    yoga.calculateLayout(root)

    helper.assert_layout(first, { left = -10, top = -5, width = 20, height = 20 }, "relative first")
    helper.assert_layout(second, { left = 20, top = 0, width = 20, height = 20 }, "flow sibling")
  end)

  runner:test("relative percentage offsets use parent content size", function()
    local child = yoga.node({ width = "45%", height = "55%", left = "10%", top = "20%" })
    local root = yoga.node({ width = 400, height = 400, flexDirection = "row" }, { child })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 40, top = 80, width = 180, height = 220 }, "percentage relative child")
  end)

  runner:test("relative offset moves descendant subtree", function()
    local grandchild = yoga.node({ width = 10, height = 10 })
    local child = yoga.node({ width = 50, height = 50, left = 12, top = 8 }, { grandchild })
    local root = yoga.node({ width = 100, height = 100 }, { child })

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 12, top = 8, width = 50, height = 50 }, "relative parent")
    helper.assert_layout(grandchild, { left = 12, top = 8, width = 10, height = 10 }, "relative grandchild")
  end)
end
