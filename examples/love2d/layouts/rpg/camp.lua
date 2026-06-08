-- RPG 营地界面布局：展示商店、制作材料、休息操作和路线情报。
local common = require("layouts.rpg.common")

local function shop_row(ctx, styles, item)
  local palette = ctx.palette

  return common.box(ctx, styles, "row", {
    action = "buy-item",
    shopId = item.id,
    debugName = item.name,
    fill = palette.panel_alt,
    style = { height = 52, padding = 8 },
  }, {
    common.text(ctx, item.name, {
      action = "buy-item",
      shopId = item.id,
      style = { flex = 1, height = 20 },
      fill = { 0, 0, 0, 0 },
    }),
    common.text(ctx, item.price .. "g", {
      action = "buy-item",
      shopId = item.id,
      style = { width = 70, height = 20 },
      fill = { 0, 0, 0, 0 },
      textColor = palette.gold,
    }),
  })
end

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local shop_rows = {}

    for _, item in ipairs(state.shop) do
      shop_rows[#shop_rows + 1] = shop_row(ctx, styles, item)
    end

    return common.box(ctx, styles, "screen", { debugName = "camp screen", fill = palette.background }, {
      common.nav(ctx, styles, state, "camp"),
      common.box(ctx, styles, "body", { debugName = "camp body", fill = { 0, 0, 0, 0 } }, {
        common.panel(ctx, styles, {
          debugName = "camp services",
          fill = palette.panel,
          style = { width = 320, flex = 0 },
        }, {
          common.text(ctx, "Camp Services", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
          common.button(ctx, styles, "Rest at Fire", "rest", {
            fill = palette.green,
            style = { height = 34 },
          }),
          common.button(ctx, styles, "Open Quests", "nav", {
            screen = "quests",
            fill = palette.accent,
            style = { height = 34 },
          }),
          common.button(ctx, styles, "Pack Bag", "nav", {
            screen = "inventory",
            fill = palette.panel_alt,
            style = { height = 34 },
          }),
          common.panel(ctx, styles, {
            debugName = "camp fire illustration",
            fill = { 0.46, 0.25, 0.16, 1 },
            style = { flex = 1 },
          }),
        }),
        common.panel(ctx, styles, {
          debugName = "shop",
          fill = palette.panel,
          style = { width = 340, flex = 0 },
        }, {
          common.text(ctx, "Traveling Merchant", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
          ctx.unpack(shop_rows),
        }),
        common.box(ctx, styles, "column", { debugName = "camp right column", fill = { 0, 0, 0, 0 } }, {
          common.panel(ctx, styles, {
            debugName = "crafting",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, "Crafting Bench", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, "Ironwood: " .. state.materials.ironwood, { style = { height = 28 }, fill = palette.panel_alt }),
            common.text(ctx, "Moon Thread: " .. state.materials.thread, { style = { height = 28 }, fill = palette.panel_alt }),
            common.text(ctx, "Crystal Dust: " .. state.materials.dust, { style = { height = 28 }, fill = palette.panel_alt }),
            common.panel(ctx, styles, {
              debugName = "recipe cards",
              fill = { 0.14, 0.16, 0.19, 1 },
              style = { flex = 1 },
            }, {
              common.text(ctx, "Recipe: Trail Tonic", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
              common.text(ctx, "Recipe: Warden Arrow", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            }),
          }),
          common.panel(ctx, styles, {
            debugName = "route intel",
            fill = palette.panel,
            style = { height = 152 },
          }, {
            common.text(ctx, "Route Intel", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, "North gate: locked", { style = { height = 24 }, fill = palette.panel_alt }),
            common.text(ctx, "River road: safe after dusk", { style = { height = 24 }, fill = palette.panel_alt }),
            common.text(ctx, "Ruins: scout reports arcane wards", { style = { height = 24 }, fill = palette.panel_alt }),
          }),
        }),
      }),
      common.message(ctx, styles, state),
    })
  end,
}
