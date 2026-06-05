-- 弹性换行布局：展示 flexWrap 在 row 主轴上分行、行内对齐、行列 gap 和 minWidth 换行。
return {
  id = "flex_wrap",
  name = "Flex Wrap",
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
        height = 128,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 12,
        gap = 10,
      },
      label = {
        width = 190,
        height = 104,
      },
      stage = {
        flex = 1,
        height = 104,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        columnGap = 12,
        rowGap = 8,
      },
      center_stage = {
        flex = 1,
        height = 104,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "center",
        paddingHorizontal = 10,
        paddingVertical = 10,
        columnGap = 12,
        rowGap = 8,
      },
      gap_stage = {
        flex = 1,
        height = 104,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        columnGap = 22,
        rowGap = 18,
      },
      chip = {
        width = 220,
        height = 30,
      },
      small = {
        width = 220,
        height = 28,
      },
      tall = {
        width = 220,
        height = 48,
      },
      basis_min = {
        flexBasis = 390,
        minWidth = 430,
        height = 28,
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

    return with_styles(styles, "screen", { debugName = "flex wrap screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "flex wrap header", fill = palette.panel }, {
        label("flexWrap creates new rows when the current line runs out of main-axis space.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("row wrap", "stage", {
        with_styles(styles, "chip", { debugName = "item 1", fill = palette.accent }),
        with_styles(styles, "chip", { debugName = "item 2", fill = palette.green }),
        with_styles(styles, "chip", { debugName = "item 3", fill = palette.gold }),
        with_styles(styles, "chip", { debugName = "item 4", fill = palette.red }),
      }),
      demo_row("align center per line", "center_stage", {
        with_styles(styles, "small", { debugName = "short", fill = palette.accent }),
        with_styles(styles, "tall", { debugName = "tall", fill = palette.green }),
        with_styles(styles, "small", { debugName = "short", fill = palette.gold }),
        with_styles(styles, "small", { debugName = "next line", fill = palette.red }),
      }),
      demo_row("columnGap 22 rowGap 18", "gap_stage", {
        with_styles(styles, "small", { debugName = "A", fill = palette.accent }),
        with_styles(styles, "small", { debugName = "B", fill = palette.green }),
        with_styles(styles, "small", { debugName = "C", fill = palette.gold }),
        with_styles(styles, "small", { debugName = "D", fill = palette.red }),
      }),
      demo_row("minWidth wraps basis", "stage", {
        with_styles(styles, "basis_min", { debugName = "basis 390 minW 430", fill = palette.gold }),
        with_styles(styles, "basis_min", { debugName = "basis 390 minW 430", fill = palette.green }),
      }),
    })
  end,
}
