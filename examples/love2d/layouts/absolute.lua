-- 绝对定位布局：展示 absolute 节点脱离 flex 流、边缘锚定、双边 inset、百分比定位和默认居中对齐。
return {
  id = "absolute",
  name = "Absolute",
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
        gap = 10,
      },
      center_stage = {
        flex = 1,
        height = 88,
        flexDirection = "column",
        alignItems = "center",
        justifyContent = "center",
        paddingHorizontal = 10,
        paddingVertical = 10,
      },
      flex_box = {
        flex = 1,
        height = 56,
      },
      fixed_box = {
        width = 116,
        height = 56,
      },
      absolute_badge = {
        position = "absolute",
        right = 12,
        top = 12,
        width = 128,
        height = 38,
      },
      top_left = {
        position = "absolute",
        left = 12,
        top = 10,
        width = 112,
        height = 38,
      },
      bottom_right = {
        position = "absolute",
        right = 12,
        bottom = 10,
        width = 126,
        height = 38,
      },
      inset_fill = {
        position = "absolute",
        left = 44,
        right = 44,
        top = 14,
        bottom = 14,
      },
      percent_box = {
        position = "absolute",
        left = "14%",
        top = "28%",
        width = "38%",
        height = "44%",
      },
      centered_box = {
        position = "absolute",
        width = 210,
        height = 48,
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

    return with_styles(styles, "screen", { debugName = "absolute screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "absolute header", fill = palette.panel }, {
        label("absolute children are positioned against the parent padding box and do not consume flex space.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("out of flow", styles.stage, {
        with_styles(styles, "flex_box", { debugName = "flow A", fill = palette.accent }),
        with_styles(styles, "absolute_badge", { debugName = "absolute badge", fill = palette.red }),
        with_styles(styles, "flex_box", { debugName = "flow B", fill = palette.green }),
      }),
      demo_row("edge anchors", styles.stage, {
        with_styles(styles, "top_left", { debugName = "left top", fill = palette.accent }),
        with_styles(styles, "bottom_right", { debugName = "right bottom", fill = palette.gold }),
      }),
      demo_row("opposing insets", styles.stage, {
        with_styles(styles, "inset_fill", { debugName = "left/right/top/bottom", fill = palette.green }),
      }),
      demo_row("percent offsets", styles.stage, {
        with_styles(styles, "percent_box", { debugName = "14% 28% 38% 44%", fill = palette.gold }),
      }),
      demo_row("default alignment", styles.center_stage, {
        with_styles(styles, "centered_box", { debugName = "centered absolute", fill = palette.accent }),
      }),
    })
  end,
}
