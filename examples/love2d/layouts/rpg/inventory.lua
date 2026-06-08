-- RPG 背包界面布局：展示分类、物品格子、选中物品详情以及使用/查看操作。
local common = require("layouts.rpg.common")

local function item_slot(ctx, styles, item, selected)
  local palette = ctx.palette
  local fill = selected and palette.accent or (item.rarity == "rare" and palette.gold or palette.panel_alt)

  return common.box(ctx, styles, "panel", {
    action = "select-item",
    itemId = item.id,
    debugName = item.name,
    image = "slot",
    tint = selected and { 0.62, 0.82, 1, 1 } or (item.rarity == "rare" and { 1, 0.86, 0.48, 1 } or nil),
    fill = fill,
    style = { width = 96, height = 76, padding = 8, gap = 4 },
  }, {
    common.text(ctx, item.name, {
      action = "select-item",
      itemId = item.id,
      style = { height = 32 },
      fill = { 0, 0, 0, 0 },
    }),
    common.text(ctx, "x" .. item.qty, {
      action = "select-item",
      itemId = item.id,
      style = { height = 18 },
      fill = { 0, 0, 0, 0 },
      textColor = palette.muted,
    }),
  })
end

local function item_rows(ctx, styles, state)
  local rows = {}
  local row = {}

  for index, item in ipairs(state.inventory) do
    row[#row + 1] = item_slot(ctx, styles, item, item.id == state.selectedItemId)
    if #row == 5 or index == #state.inventory then
      rows[#rows + 1] = common.box(ctx, styles, "row", {
        debugName = "inventory row",
        fill = { 0, 0, 0, 0 },
        style = { height = 80 },
      }, row)
      row = {}
    end
  end

  return rows
end

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local selected = state:getSelectedItem()

    return common.box(ctx, styles, "screen", { debugName = "inventory screen", fill = palette.background }, {
      common.nav(ctx, styles, state, "inventory"),
      common.box(ctx, styles, "body", { debugName = "inventory body", fill = { 0, 0, 0, 0 } }, {
        common.panel(ctx, styles, {
          debugName = "inventory categories",
          fill = palette.panel,
          style = { width = 210, flex = 0 },
        }, {
          common.text(ctx, "Categories", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
          common.text(ctx, "Consumables", { style = { height = 30 }, fill = palette.accent }),
          common.text(ctx, "Equipment", { style = { height = 30 }, fill = palette.panel_alt }),
          common.text(ctx, "Materials", { style = { height = 30 }, fill = palette.panel_alt }),
          common.text(ctx, "Quest Items", { style = { height = 30 }, fill = palette.panel_alt }),
          common.button(ctx, styles, "Sort", "sort-items", {
            fill = palette.green,
            style = { height = 32 },
          }),
        }),
        common.panel(ctx, styles, {
          debugName = "inventory grid",
          fill = palette.panel,
          style = { flex = 1 },
        }, item_rows(ctx, styles, state)),
        common.panel(ctx, styles, {
          debugName = "item detail",
          fill = palette.panel,
          style = { width = 320, flex = 0 },
        }, {
          common.text(ctx, selected.name, { style = { height = 30 }, fill = { 0, 0, 0, 0 } }),
          common.text(ctx, selected.type .. " / " .. selected.rarity, {
            style = { height = 24 },
            fill = palette.panel_alt,
            textColor = palette.muted,
          }),
          common.panel(ctx, styles, {
            debugName = "item preview",
            image = "pouch",
            fill = selected.rarity == "rare" and palette.gold or palette.panel_alt,
            style = { height = 110 },
          }),
          common.text(ctx, selected.description, {
            style = { height = 86 },
            fill = { 0, 0, 0, 0 },
            textColor = palette.text,
          }),
          common.box(ctx, styles, "row", { debugName = "item actions", fill = { 0, 0, 0, 0 }, style = { height = 36 } }, {
            common.button(ctx, styles, "Use", "use-item", {
              itemId = selected.id,
              fill = selected.usable and palette.green or palette.panel_alt,
              style = { flex = 1, height = 34 },
            }),
            common.button(ctx, styles, "View", "inspect-item", {
              itemId = selected.id,
              fill = palette.accent,
              style = { flex = 1, height = 34 },
            }),
          }),
        }),
      }),
      common.message(ctx, styles, state),
    })
  end,
}
