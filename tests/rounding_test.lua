local yoga = require("yoga")

return function(runner, helper)
  runner:test("nested absolute coordinates round without re-adding parent offset", function()
    local grandchild = yoga.node({ height = 10, flexGrow = 1 })
    local middle = yoga.node({ height = 10, flexGrow = 1 }, { grandchild })
    local root = yoga.node({ width = 320, flexDirection = "row" }, {
      yoga.node({ height = 10, flexGrow = 1 }),
      middle,
      yoga.node({ height = 10, flexGrow = 1 }),
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 320, height = 10 }, "root")
    helper.assert_layout(middle, { left = 107, top = 0, width = 106, height = 10 }, "middle")
    helper.assert_layout(grandchild, { left = 107, top = 0, width = 106, height = 10 }, "grandchild")
  end)
end
