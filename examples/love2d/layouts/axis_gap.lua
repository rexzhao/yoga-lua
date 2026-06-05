-- 轴向间距布局：展示 rowGap、columnGap 与通用 gap 在主轴上的差异。
return {
  id = "axis_gap",
  name = "Axis Gap",
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
        height = 44,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
      },
      row = {
        height = 160,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 132,
      },
      row_stage = {
        flex = 1,
        height = 132,
        flexDirection = "row",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        columnGap = 28,
        rowGap = 4,
      },
      column_stage = {
        flex = 1,
        height = 132,
        flexDirection = "column",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        rowGap = 20,
        columnGap = 4,
      },
      fallback_stage = {
        flex = 1,
        height = 132,
        flexDirection = "row",
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 14,
      },
      row_chip = {
        width = 120,
      },
      column_chip = {
        height = 24,
      },
    })

    local function demo_row(name, stage_class, children)
      return with_styles(styles, "row", { debugName = name, fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        with_styles(styles, stage_class, { debugName = name .. " stage", fill = palette.panel }, children),
      })
    end

    return with_styles(styles, "screen", { debugName = "axis gap screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "axis gap header", fill = palette.panel }, {
        label("row uses columnGap; column uses rowGap; gap remains the fallback.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("row: columnGap 28", "row_stage", {
        with_styles(styles, "row_chip", { debugName = "A", fill = palette.accent }),
        with_styles(styles, "row_chip", { debugName = "B", fill = palette.green }),
        with_styles(styles, "row_chip", { debugName = "C", fill = palette.gold }),
      }),
      demo_row("column: rowGap 20", "column_stage", {
        with_styles(styles, "column_chip", { debugName = "top", fill = palette.accent }),
        with_styles(styles, "column_chip", { debugName = "middle", fill = palette.green }),
        with_styles(styles, "column_chip", { debugName = "bottom", fill = palette.gold }),
      }),
      demo_row("fallback: gap 14", "fallback_stage", {
        with_styles(styles, "row_chip", { debugName = "left", fill = palette.accent }),
        with_styles(styles, "row_chip", { debugName = "middle", fill = palette.red }),
        with_styles(styles, "row_chip", { debugName = "right", fill = palette.green }),
      }),
    })
  end,
}
