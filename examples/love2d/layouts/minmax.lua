-- 最小最大尺寸布局：展示 minWidth/maxWidth/minHeight/maxHeight 对显式尺寸、stretch 和百分比尺寸的约束。
return {
  id = "minmax",
  name = "Min/Max",
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
        paddingHorizontal = 18,
        paddingVertical = 18,
        gap = 12,
      },
      header = {
        height = 48,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
      },
      row = {
        height = 122,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 94,
      },
      stage = {
        flex = 1,
        height = 94,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      stretch_stage = {
        flex = 1,
        height = 94,
        flexDirection = "row",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      fixed = {
        width = 96,
        height = 50,
      },
      wide_min = {
        width = 64,
        height = 50,
        minWidth = 132,
      },
      narrow_max = {
        width = 180,
        height = 50,
        maxWidth = 96,
      },
      tall_min = {
        width = 72,
        height = 32,
        minHeight = 70,
      },
      short_max = {
        width = 72,
        height = 86,
        maxHeight = 44,
      },
      stretch_cap = {
        width = 120,
        maxHeight = 54,
      },
      percent_box = {
        minWidth = "18%",
        maxWidth = "18%",
        minHeight = "42%",
        maxHeight = "42%",
      },
    })

    local function demo_row(name, stage_style, children)
      return with_styles(styles, "row", { debugName = name, fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = stage_style, debugName = name .. " stage", fill = palette.panel }, children),
      })
    end

    return with_styles(styles, "screen", { debugName = "minmax screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "minmax header", fill = palette.panel }, {
        label("Min and max constraints clamp explicit, stretched, measured, and percentage sizes.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("explicit width clamp", styles.stage, {
        with_styles(styles, "fixed", { debugName = "fixed 96", fill = palette.panel_alt }),
        with_styles(styles, "wide_min", { debugName = "w64 minW132", fill = palette.accent }),
        with_styles(styles, "narrow_max", { debugName = "w180 maxW96", fill = palette.green }),
      }),
      demo_row("explicit height clamp", styles.stage, {
        with_styles(styles, "tall_min", { debugName = "h32 minH70", fill = palette.gold }),
        with_styles(styles, "short_max", { debugName = "h86 maxH44", fill = palette.red }),
      }),
      demo_row("stretch capped by maxHeight", styles.stretch_stage, {
        with_styles(styles, "stretch_cap", { debugName = "stretch maxH54", fill = palette.accent }),
        ui.div({ style = { width = 120 }, debugName = "normal stretch", fill = palette.green }),
      }),
      demo_row("percentage min/max", styles.stage, {
        with_styles(styles, "percent_box", { debugName = "18% x 42%", fill = palette.gold }),
        with_styles(styles, "percent_box", { debugName = "18% x 42%", fill = palette.green }),
      }),
    })
  end,
}
