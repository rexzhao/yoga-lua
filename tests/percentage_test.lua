local yoga = require("yoga")

return function(runner, helper)
  runner:test("percentage strings accept leading and trailing decimal forms", function()
    local absolute = yoga.node({ position = "absolute", left = "-.5%", top = 0, width = 10, height = 10 })
    local root = yoga.node({ width = 200, height = 100, alignItems = "flex-start" }, {
      yoga.node({ width = ".5%", height = 10 }),
      yoga.node({ width = "50%", height = 10 }),
      yoga.node({ width = "50.5%", height = 10 }),
      yoga.node({ width = "50.%", height = 10 }),
      absolute,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 1, height = 10 }, "leading decimal")
    helper.assert_layout(root.children[2], { left = 0, top = 10, width = 100, height = 10 }, "integer percent")
    helper.assert_layout(root.children[3], { left = 0, top = 20, width = 101, height = 10 }, "decimal percent")
    helper.assert_layout(root.children[4], { left = 0, top = 30, width = 100, height = 10 }, "trailing decimal")
    helper.assert_layout(absolute, { left = -1, top = 0, width = 10, height = 10 }, "negative leading decimal")
  end)

  runner:test("malformed percentage strings are treated as unset", function()
    local root = yoga.node({ width = 200, height = 100, alignItems = "flex-start" }, {
      yoga.node({ width = "%", height = 10 }),
      yoga.node({ width = ".", height = 10 }),
      yoga.node({ width = ".%", height = 10 }),
      yoga.node({ width = "abc%", height = 10 }),
    })

    yoga.calculateLayout(root)

    for index, child in ipairs(root.children) do
      helper.assert_equal(child.layout.width, 0, "malformed percent child " .. index)
    end
  end)
end
