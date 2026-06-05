-- 弹性收缩布局：展示 flexShrink 在主轴内容超过父容器时按基础尺寸比例收缩。
return {
  id = "flex_shrink",
  name = "Flex Shrink",
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
        height = 110,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 82,
      },
      stage = {
        flex = 1,
        height = 82,
        flexDirection = "row",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      column_stage = {
        flex = 1,
        height = 82,
        flexDirection = "column",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 8,
        gap = 8,
      },
      equal_shrink = {
        width = 520,
        flexShrink = 1,
      },
      fixed_wide = {
        width = 520,
      },
      shrink_only = {
        width = 520,
        flexShrink = 1,
      },
      basis_shrink = {
        flexBasis = 520,
        flexShrink = 1,
      },
      basis_fixed = {
        flexBasis = 260,
      },
      column_shrink = {
        height = 60,
        flexShrink = 1,
      },
      column_fixed = {
        height = 60,
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

    return with_styles(styles, "screen", { debugName = "flex shrink screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "flex shrink header", fill = palette.panel }, {
        label("flexShrink reduces main-axis sizes when base content is wider or taller than the parent.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("equal shrink", styles.stage, {
        with_styles(styles, "equal_shrink", { debugName = "width 520 shrink 1", fill = palette.accent }),
        with_styles(styles, "equal_shrink", { debugName = "width 520 shrink 1", fill = palette.green }),
      }),
      demo_row("one item shrinks", styles.stage, {
        with_styles(styles, "fixed_wide", { debugName = "width 520", fill = palette.gold }),
        with_styles(styles, "shrink_only", { debugName = "width 520 shrink 1", fill = palette.red }),
      }),
      demo_row("basis shrink", styles.stage, {
        with_styles(styles, "basis_shrink", { debugName = "basis 520 shrink 1", fill = palette.accent }),
        with_styles(styles, "basis_fixed", { debugName = "basis 260", fill = palette.green }),
      }),
      demo_row("column shrink", styles.column_stage, {
        with_styles(styles, "column_fixed", { debugName = "height 60", fill = palette.gold }),
        with_styles(styles, "column_shrink", { debugName = "height 60 shrink 1", fill = palette.accent }),
        with_styles(styles, "column_fixed", { debugName = "height 60", fill = palette.red }),
      }),
    })
  end,
}
