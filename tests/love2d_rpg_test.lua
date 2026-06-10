local ui = require("ui")

package.path = "examples/love2d/?.lua;examples/love2d/?/init.lua;" .. package.path

local rpg = require("layouts.rpg_game")

local function palette()
  return {
    background = { 0, 0, 0, 1 },
    panel = { 0.1, 0.1, 0.1, 1 },
    panel_alt = { 0.2, 0.2, 0.2, 1 },
    accent = { 0.2, 0.4, 0.8, 1 },
    green = { 0.2, 0.6, 0.4, 1 },
    gold = { 0.8, 0.6, 0.2, 1 },
    muted = { 0.5, 0.5, 0.5, 1 },
    text = { 1, 1, 1, 1 },
  }
end

local function find_node(node, predicate)
  if predicate(node) then
    return node
  end

  for _, child in ipairs(node.children or {}) do
    local found = find_node(child, predicate)
    if found then
      return found
    end
  end

  return nil
end

return function(runner, helper)
  runner:test("rpg inventory category click filters visible items", function()
    local state = rpg.createState()

    helper.assert_equal(state.selectedInventoryCategory, "all", "initial category")
    helper.assert_equal(#state:getInventoryItems(), 7, "initial all count")

    helper.assert_equal(rpg.handleClick(state, { action = "select-category", category = "materials" }), true, "category click handled")
    helper.assert_equal(state.selectedInventoryCategory, "materials", "selected category")
    helper.assert_equal(#state:getInventoryItems(), 1, "materials count")
    helper.assert_equal(state:getSelectedItem().id, "ironwood", "selected item moves into category")
    helper.assert_equal(state.message, "Showing Materials.", "category message")

    helper.assert_equal(rpg.handleClick(state, { action = "select-category", category = "all" }), true, "all category click handled")
    helper.assert_equal(#state:getInventoryItems(), 7, "all count")
    helper.assert_equal(state:getSelectedItem().id, "ironwood", "all keeps selected visible item")

    helper.assert_equal(rpg.handleClick(state, { action = "select-category", category = "missing" }), false, "invalid category ignored")
    helper.assert_equal(state.selectedInventoryCategory, "all", "invalid category preserves state")
  end)

  runner:test("rpg inventory category nodes carry click action props", function()
    local state = rpg.createState()
    state.screen = "inventory"

    local root = rpg.build({
      ui = ui,
      palette = palette(),
      unpack = table.unpack or unpack,
    }, 1100, 634, state)
    local materials = find_node(root, function(node)
      return node.props and node.props.category == "materials"
    end)

    helper.assert_equal(materials ~= nil, true, "materials category node exists")
    helper.assert_equal(materials.props.action, "select-category", "materials category action")
    helper.assert_equal(rpg.handleClick(state, materials.props), true, "materials category props are handled")
    helper.assert_equal(state.selectedInventoryCategory, "materials", "materials category selected")
  end)

  runner:test("rpg inventory keyed items flip when resize changes wrapping", function()
    local runtime = ui.createRuntime()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local state = rpg.createState()
    state.screen = "inventory"
    local ctx = {
      ui = runtime:ui(),
      palette = palette(),
      unpack = table.unpack or unpack,
    }

    local root = runtime:render(rpg.build(ctx, 1100, 600, state), 1100, 600)
    animator:sync(root)
    root = runtime:render(rpg.build(ctx, 900, 600, state), 900, 600)
    animator:sync(root)

    local animated = find_node(root, function(node)
      return node.props and type(node.props.flip) == "string" and animator:visual(node) ~= nil
    end)

    helper.assert_equal(animated ~= nil, true, "resized inventory item animates")
  end)
end
