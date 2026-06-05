-- 弹性基准布局：展示 flexBasis 作为主轴基础尺寸，并和 flexGrow 一起分配剩余空间。
return {
  id = "flex_basis",
  name = "Flex Basis",
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
      basis_large = {
        flexGrow = 1,
        flexBasis = 180,
      },
      basis_small = {
        flexGrow = 1,
        flexBasis = 70,
      },
      percent_half = {
        flexGrow = 1,
        flexBasis = "50%",
      },
      percent_quarter = {
        flexGrow = 1,
        flexBasis = "25%",
      },
      width_overridden = {
        width = 52,
        flexBasis = 150,
      },
      remaining_fill = {
        flexGrow = 1,
      },
      column_half = {
        flexGrow = 1,
        flexBasis = "50%",
      },
      column_quarter = {
        flexGrow = 1,
        flexBasis = "25%",
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

    return with_styles(styles, "screen", { debugName = "flex basis screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "flex basis header", fill = palette.panel }, {
        label("flexBasis sets the main-axis base size before flexGrow receives remaining space.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("numeric basis + grow", styles.stage, {
        with_styles(styles, "basis_large", { debugName = "basis 180 grow 1", fill = palette.accent }),
        with_styles(styles, "basis_small", { debugName = "basis 70 grow 1", fill = palette.green }),
      }),
      demo_row("percentage basis", styles.stage, {
        with_styles(styles, "percent_half", { debugName = "basis 50%", fill = palette.gold }),
        with_styles(styles, "percent_quarter", { debugName = "basis 25%", fill = palette.accent }),
      }),
      demo_row("basis overrides width", styles.stage, {
        with_styles(styles, "width_overridden", { debugName = "width 52 basis 150", fill = palette.red }),
        with_styles(styles, "remaining_fill", { debugName = "remaining flex", fill = palette.green }),
      }),
      demo_row("column basis", styles.column_stage, {
        with_styles(styles, "column_half", { debugName = "basis 50%", fill = palette.accent }),
        with_styles(styles, "column_quarter", { debugName = "basis 25%", fill = palette.gold }),
      }),
    })
  end,
}
