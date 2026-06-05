-- 主轴对齐布局：展示 justifyContent 在 row 容器中的多种空间分布方式。
return {
  id = "justify",
  name = "Justify",
  build = function(ctx, width, height)
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label
    local outer_padding = 18

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
        paddingHorizontal = outer_padding,
        paddingVertical = outer_padding,
        gap = 10,
      },
      row = {
        height = 78,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      name = {
        width = 156,
        height = 58,
      },
      track = {
        flex = 1,
        height = 58,
        flexDirection = "row",
        paddingHorizontal = 8,
        paddingVertical = 8,
        gap = 6,
      },
      chip = {
        width = 42,
        height = 42,
      },
    })

    local values = {
      "flex-start",
      "center",
      "flex-end",
      "space-between",
      "space-around",
      "space-evenly",
    }

    local rows = {}
    for index, value in ipairs(values) do
      local track_style = {}
      for key, item in pairs(styles.track) do
        track_style[key] = item
      end
      track_style.justifyContent = value

      rows[#rows + 1] = with_styles(styles, "row", {
        debugName = "justify " .. value,
        fill = index % 2 == 0 and palette.panel or palette.panel_alt,
      }, {
        with_styles(styles, "name", { debugName = value, fill = { 0, 0, 0, 0 } }, {
          label(value, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = track_style, debugName = value .. " track", fill = palette.panel }, {
          with_styles(styles, "chip", { debugName = "A", fill = palette.accent }),
          with_styles(styles, "chip", { debugName = "B", fill = palette.green }),
          with_styles(styles, "chip", { debugName = "C", fill = palette.gold }),
        }),
      })
    end

    return with_styles(styles, "screen", { debugName = "justify screen", fill = palette.background }, rows)
  end,
}

