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

  runner:test("function components return reusable node trees", function()
    local styles = ui.stylesheet({
      screen = { width = 240, height = 80, flexDirection = "row", gap = 8 },
      slot = { width = 40, height = 40 },
    })

    local function Slot(props)
      return ui.div({ class = "slot", styles = styles, itemId = props.itemId })
    end

    local function InventoryRow(props)
      local children = {}

      for index, item_id in ipairs(props.items) do
        children[index] = Slot({ itemId = item_id })
      end

      return ui.div({ class = "screen", styles = styles, debugName = "inventory row" }, children)
    end

    local root = InventoryRow({ items = { "sword", "shield", "potion" } })

    yoga.calculateLayout(root)

    helper.assert_equal(root.props.debugName, "inventory row", "root prop")
    helper.assert_equal(root.children[2].props.itemId, "shield", "child prop")
    helper.assert_layout(root.children[1], { left = 0, top = 0, width = 40, height = 40 }, "first slot")
    helper.assert_layout(root.children[2], { left = 48, top = 0, width = 40, height = 40 }, "second slot")
    helper.assert_layout(root.children[3], { left = 96, top = 0, width = 40, height = 40 }, "third slot")
  end)

  runner:test("event props are preserved on UI nodes", function()
    local clicked = false
    local function on_click()
      clicked = true
    end

    local button = ui.button("Equip", {
      onClick = on_click,
      onHover = function() end,
      style = { width = 96, height = 32 },
    })

    helper.assert_equal(button.type, "button", "button type")
    helper.assert_equal(button.props.onClick, on_click, "onClick prop")
    helper.assert_equal(type(button.props.onHover), "function", "onHover prop")

    button.props.onClick()

    helper.assert_equal(clicked, true, "event callback remains callable")
  end)
end
