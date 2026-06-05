-- 百分比布局：展示百分比尺寸、百分比 padding 和百分比 margin 随窗口变化的效果。
return {
  id = "percent",
  name = "Percent",
  build = function(ctx, width, height)
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
        padding = "3%",
        gap = 12,
      },
      header = {
        height = 48,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
      },
      row = {
        height = 118,
        flexDirection = "row",
        padding = "2%",
        gap = 10,
      },
      column = {
        height = 172,
        flexDirection = "column",
        padding = "2%",
        gap = 8,
      },
      label = {
        width = 170,
        height = 70,
      },
      half = {
        width = "50%",
        height = 70,
      },
      quarter = {
        width = "25%",
        height = 70,
      },
      padded = {
        flex = 1,
        height = 78,
        flexDirection = "row",
        paddingHorizontal = "5%",
        paddingVertical = 14,
        gap = 8,
      },
      inner = {
        width = "30%",
        height = "60%",
      },
      margin_box = {
        width = "30%",
        height = 58,
        margin = "3%",
      },
      h25 = {
        height = "25%",
      },
      h50 = {
        height = "50%",
      },
    })

    return with_styles(styles, "screen", { debugName = "percent screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "percent header", fill = palette.panel }, {
        label("Resize the window: percent sizes and spacing follow the parent width/height.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      with_styles(styles, "row", { debugName = "percentage width row", fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = "width labels", fill = { 0, 0, 0, 0 } }, {
          label("width: 50% / 25%", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        with_styles(styles, "half", { debugName = "width 50%", fill = palette.accent }),
        with_styles(styles, "quarter", { debugName = "width 25%", fill = palette.green }),
      }),
      with_styles(styles, "row", { debugName = "percentage padding row", fill = palette.panel }, {
        with_styles(styles, "label", { debugName = "padding label", fill = { 0, 0, 0, 0 } }, {
          label("paddingHorizontal: 5%", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        with_styles(styles, "padded", { debugName = "paddingHorizontal 5%", fill = palette.panel_alt }, {
          with_styles(styles, "inner", { debugName = "inner 30% x 60%", fill = palette.gold }),
          with_styles(styles, "inner", { debugName = "inner 30% x 60%", fill = palette.green }),
        }),
      }),
      with_styles(styles, "row", { debugName = "percentage margin row", fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = "margin label", fill = { 0, 0, 0, 0 } }, {
          label("margin: 3%", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        with_styles(styles, "margin_box", { debugName = "margin 3%", fill = palette.red }),
        with_styles(styles, "margin_box", { debugName = "margin 3%", fill = palette.gold }),
      }),
      with_styles(styles, "column", { debugName = "percentage height column", fill = palette.panel }, {
        label("height: 25% then 50%", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        with_styles(styles, "h25", { debugName = "height 25%", fill = palette.accent }),
        with_styles(styles, "h50", { debugName = "height 50%", fill = palette.green }),
      }),
    })
  end,
}
