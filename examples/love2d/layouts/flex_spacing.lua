-- 弹性和间距布局：集中展示 padding、gap、margin 与 flexGrow 的可视化效果。
return {
  id = "flex_spacing",
  name = "Flex/Spacing",
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
        gap = 12,
      },
      header = {
        height = 44,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
        gap = 10,
      },
      strip = {
        height = 96,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      chip = {
        width = 132,
        height = 76,
      },
      small_chip = {
        width = 96,
        height = 76,
      },
      flex_chip = {
        flex = 1,
        height = 76,
      },
      double_flex_chip = {
        flex = 2,
        height = 76,
      },
      margin_chip = {
        width = 132,
        height = 76,
        marginLeft = 24,
        marginRight = 8,
      },
    })

    return with_styles(styles, "screen", { debugName = "spacing and flex screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "supported layout header", fill = palette.panel }, {
        label("Now showing: paddingHorizontal, paddingVertical, gap, marginLeft, flex=1, flex=2", {
          style = { flex = 1, height = 28 },
        }),
      }),
      with_styles(styles, "strip", { debugName = "gap and padding strip", fill = palette.panel_alt }, {
        with_styles(styles, "chip", { debugName = "fixed 132", fill = palette.accent }),
        with_styles(styles, "chip", { debugName = "gap 10", fill = palette.green }),
        with_styles(styles, "chip", { debugName = "padding edges", fill = palette.gold }),
      }),
      with_styles(styles, "strip", { debugName = "flex grow strip", fill = palette.panel }, {
        with_styles(styles, "small_chip", { debugName = "fixed 96", fill = palette.accent }),
        with_styles(styles, "flex_chip", { debugName = "flex=1", fill = palette.green }),
        with_styles(styles, "double_flex_chip", { debugName = "flex=2", fill = palette.gold }),
      }),
      with_styles(styles, "strip", { debugName = "margin strip", fill = palette.panel_alt }, {
        with_styles(styles, "small_chip", { debugName = "fixed", fill = palette.accent }),
        with_styles(styles, "margin_chip", { debugName = "marginLeft 24", fill = palette.red }),
        with_styles(styles, "flex_chip", { debugName = "flex fills rest", fill = palette.green }),
      }),
      with_styles(styles, "strip", { debugName = "mixed inventory-like strip", fill = palette.panel }, {
        with_styles(styles, "small_chip", { debugName = "icon", fill = palette.gold }),
        with_styles(styles, "flex_chip", { debugName = "name flex=1", fill = palette.panel_alt }),
        with_styles(styles, "chip", { debugName = "action 132", fill = palette.accent }),
      }),
    })
  end,
}

