-- 相对定位布局：展示普通流节点使用 left/top/right/bottom 偏移时仍保留原来的布局占位。
return {
  id = "relative",
  name = "Relative",
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
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 14,
      },
      column_stage = {
        flex = 1,
        height = 82,
        flexDirection = "column",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 8,
      },
      flow_box = {
        width = 132,
        height = 44,
      },
      shifted_positive = {
        width = 132,
        height = 44,
        left = 34,
        top = 14,
      },
      shifted_negative = {
        width = 132,
        height = 44,
        right = 8,
        bottom = 8,
      },
      percent_box = {
        width = "36%",
        height = "54%",
        left = "12%",
        top = "18%",
      },
      nested_parent = {
        width = 178,
        height = 54,
        left = 42,
        top = 10,
        paddingHorizontal = 12,
        paddingVertical = 10,
      },
      nested_child = {
        width = 88,
        height = 26,
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

    return with_styles(styles, "screen", { debugName = "relative screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "relative header", fill = palette.panel }, {
        label("relative offsets move the rendered box while siblings keep using the original flow slot.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("left/top offset", styles.stage, {
        with_styles(styles, "shifted_positive", { debugName = "left 34 top 14", fill = palette.accent }),
        with_styles(styles, "flow_box", { debugName = "next flow slot", fill = palette.green }),
      }),
      demo_row("right/bottom offset", styles.stage, {
        with_styles(styles, "shifted_negative", { debugName = "right 8 bottom 8", fill = palette.gold }),
        with_styles(styles, "flow_box", { debugName = "next flow slot", fill = palette.red }),
      }),
      demo_row("percent offset", styles.stage, {
        with_styles(styles, "percent_box", { debugName = "12% 18%", fill = palette.accent }),
        with_styles(styles, "flow_box", { debugName = "flow neighbor", fill = palette.green }),
      }),
      demo_row("subtree moves together", styles.column_stage, {
        with_styles(styles, "nested_parent", { debugName = "relative parent", fill = palette.gold }, {
          with_styles(styles, "nested_child", { debugName = "child follows", fill = palette.accent }),
        }),
      }),
    })
  end,
}
