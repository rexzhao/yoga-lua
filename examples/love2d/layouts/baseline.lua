-- 基线对齐布局：展示 row 容器中 alignItems/alignSelf = "baseline" 按子树基线垂直对齐。
return {
  id = "baseline",
  name = "Baseline",
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
        height = 170,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 134,
      },
      stage = {
        flex = 1,
        height = 134,
        flexDirection = "row",
        alignItems = "baseline",
        paddingHorizontal = 10,
        paddingVertical = 12,
        gap = 14,
      },
      guide = {
        position = "absolute",
        left = 10,
        right = 10,
        top = 92,
        height = 2,
      },
      tall = {
        width = 150,
        height = 80,
      },
      short = {
        width = 150,
        height = 36,
      },
      nested = {
        width = 170,
        height = 58,
        alignSelf = "baseline",
        flexDirection = "column",
      },
      nested_child = {
        width = 130,
        height = 24,
      },
      self_stage = {
        flex = 1,
        height = 134,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 12,
        gap = 14,
      },
    })

    local function demo_row(name, stage_style, children)
      return with_styles(styles, "row", { debugName = name, fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 44 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = stage_style, debugName = name .. " stage", fill = palette.panel }, children),
      })
    end

    return with_styles(styles, "screen", { debugName = "baseline screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "baseline header", fill = palette.panel }, {
        label("Baseline alignment lowers shorter boxes so their baselines match the tallest item.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("alignItems baseline", styles.stage, {
        with_styles(styles, "guide", { fill = palette.line, stroke = false }),
        with_styles(styles, "tall", { debugName = "height 80", fill = palette.accent }),
        with_styles(styles, "short", { debugName = "height 36", fill = palette.gold }),
        with_styles(styles, "short", { debugName = "height 36", fill = palette.green }),
      }),
      demo_row("alignSelf baseline with subtree", styles.self_stage, {
        with_styles(styles, "guide", { fill = palette.line, stroke = false }),
        with_styles(styles, "tall", { debugName = "self baseline 80", fill = palette.accent, style = { alignSelf = "baseline" } }),
        with_styles(styles, "nested", { debugName = "nested baseline parent", fill = palette.gold }, {
          with_styles(styles, "nested_child", { debugName = "nested child baseline", fill = palette.green }),
        }),
      }),
    })
  end,
}
