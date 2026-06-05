-- 背包界面布局：展示固定侧栏、弹性物品网格、详情面板和基础工具栏。
return {
  id = "inventory",
  name = "Inventory",
  build = function(ctx, width, height)
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label
    local outer_padding = 16
    local toolbar_height = 48
    local sidebar_width = 230
    local detail_width = 300

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
        padding = outer_padding,
        gap = 12,
      },
      toolbar = {
        height = toolbar_height,
        flexDirection = "row",
        padding = 8,
        gap = 8,
      },
      body = {
        flex = 1,
        flexDirection = "row",
        gap = 12,
      },
      sidebar = {
        width = sidebar_width,
        flexDirection = "column",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 8,
      },
      grid = {
        flex = 1,
        flexDirection = "column",
        padding = 10,
        gap = 8,
      },
      row = {
        height = 72,
        flexDirection = "row",
        gap = 8,
      },
      slot = {
        width = 72,
        height = 72,
      },
      detail = {
        width = detail_width,
        flexDirection = "column",
        padding = 12,
        gap = 10,
      },
      detail_block = {
        height = 92,
      },
      detail_flex_block = {
        flex = 1,
      },
    })

    local rows = {}
    for row_index = 1, 4 do
      local slots = {}
      for slot_index = 1, 6 do
        slots[#slots + 1] = with_styles(styles, "slot", {
          debugName = "slot " .. row_index .. "." .. slot_index,
          fill = slot_index == 2 and palette.gold or palette.panel_alt,
        })
      end
      rows[#rows + 1] = with_styles(styles, "row", { debugName = "item row " .. row_index, fill = { 0, 0, 0, 0 } }, slots)
    end

    return with_styles(styles, "screen", { debugName = "inventory screen", fill = palette.background }, {
      with_styles(styles, "toolbar", { debugName = "toolbar", fill = palette.panel }, {
        ui.button("Equip", { style = { width = 120, height = 32 }, debugName = "Equip button", fill = palette.accent }),
        ui.button("Sort", { style = { width = 100, height = 32 }, debugName = "Sort button", fill = palette.green }),
        ui.button("Close", { style = { width = 100, height = 32 }, debugName = "Close button", fill = palette.red }),
      }),
      with_styles(styles, "body", { debugName = "body", fill = { 0, 0, 0, 0 } }, {
        with_styles(styles, "sidebar", { debugName = "category sidebar", fill = palette.panel }, {
          label("Weapons", { style = { height = 30 }, fill = palette.accent }),
          label("Armor", { style = { height = 30 }, fill = palette.panel_alt }),
          label("Consumables", { style = { height = 30 }, fill = palette.panel_alt }),
          label("Materials", { style = { height = 30 }, fill = palette.panel_alt }),
        }),
        with_styles(styles, "grid", { debugName = "inventory grid", fill = palette.panel }, rows),
        with_styles(styles, "detail", { debugName = "item detail", fill = palette.panel }, {
          label("Selected Item", { style = { height = 28 }, fill = palette.accent }),
          with_styles(styles, "detail_block", { debugName = "item preview", fill = palette.panel_alt }),
          with_styles(styles, "detail_flex_block", { debugName = "item stats flex=1", fill = palette.panel_alt }),
          with_styles(styles, "detail_block", { debugName = "item actions", fill = palette.panel_alt }),
        }),
      }),
    })
  end,
}

