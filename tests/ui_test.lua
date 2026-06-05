local yoga = require("yoga")
local ui = require("ui")

return function(runner, helper)
  runner:test("component style merge", function()
    local styles = ui.stylesheet({
      screen = { width = 320, height = 240, flexDirection = "row", padding = 8, gap = 4 },
      sidebar = { width = 64 },
    })

    local root = ui.div({ class = "screen", styles = styles }, {
      ui.div({ class = "sidebar", styles = styles }),
      ui.div({ style = { width = 100 } }),
    })

    yoga.calculateLayout(root)

    helper.assert_equal(root.type, "div", "root type")
    helper.assert_equal(root.layout.width, 320, "component root width")
    helper.assert_equal(root.children[1].layout.width, 64, "class width")
    helper.assert_equal(root.children[2].layout.left, 76, "second component left")
  end)
end

