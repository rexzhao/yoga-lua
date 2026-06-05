-- 宽高比布局：展示 aspectRatio 根据已知宽度、高度或 flex 后主轴尺寸推导另一个维度。
return {
  id = "aspect_ratio",
  name = "Aspect Ratio",
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
        height = 116,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 88,
      },
      stage = {
        flex = 1,
        height = 88,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 14,
      },
      column_stage = {
        flex = 1,
        height = 88,
        flexDirection = "column",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 8,
      },
      square = {
        width = 72,
        aspectRatio = 1,
      },
      wide_from_height = {
        height = 48,
        aspectRatio = 3,
      },
      flex_ratio = {
        flex = 1,
        aspectRatio = 12,
      },
      fixed_neighbor = {
        width = 96,
        height = 48,
      },
      tall_from_width = {
        width = 64,
        aspectRatio = 0.75,
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

    return with_styles(styles, "screen", { debugName = "aspect ratio screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "aspect ratio header", fill = palette.panel }, {
        label("aspectRatio fills a missing dimension from width, height, or flexed main-axis size.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("width 72 ratio 1", "stage", {
        with_styles(styles, "square", { debugName = "72 x 72", fill = palette.accent }),
        with_styles(styles, "fixed_neighbor", { debugName = "fixed neighbor", fill = palette.green }),
      }),
      demo_row("height 48 ratio 3", "stage", {
        with_styles(styles, "wide_from_height", { debugName = "144 x 48", fill = palette.gold }),
        with_styles(styles, "square", { debugName = "square", fill = palette.accent }),
      }),
      demo_row("flex width ratio 12", "stage", {
        with_styles(styles, "fixed_neighbor", { debugName = "fixed 96", fill = palette.red }),
        with_styles(styles, "flex_ratio", { debugName = "flex ratio 12", fill = palette.green }),
      }),
      demo_row("column width ratio .75", "column_stage", {
        with_styles(styles, "tall_from_width", { debugName = "64 x 85", fill = palette.gold }),
      }),
    })
  end,
}
