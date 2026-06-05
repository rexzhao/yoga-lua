-- 显示属性布局：展示 display = "none" 隐藏子树，以及 display = "contents" 将子节点提升到父级布局流。
return {
  id = "display",
  name = "Display",
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
        alignItems = "stretch",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      fixed_stage = {
        flex = 1,
        height = 88,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 16,
      },
      flex_box = {
        flex = 1,
      },
      fixed_box = {
        width = 86,
        height = 52,
      },
      hidden_box = {
        width = 120,
        height = 52,
        margin = 16,
        display = "none",
      },
      hidden_flex = {
        flex = 1,
        display = "none",
      },
      hidden_parent = {
        flex = 1,
        display = "none",
      },
      hidden_child = {
        width = 60,
        height = 40,
      },
      contents_parent = {
        display = "contents",
      },
      contents_child = {
        flex = 1,
        height = 58,
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

    return with_styles(styles, "screen", { debugName = "display screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "display header", fill = palette.panel }, {
        label("display none removes boxes; display contents promotes child boxes into parent flow.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("flex ignores hidden middle", styles.stage, {
        with_styles(styles, "flex_box", { debugName = "visible flex A", fill = palette.accent }),
        with_styles(styles, "hidden_flex", { debugName = "hidden flex", fill = palette.red }),
        with_styles(styles, "flex_box", { debugName = "visible flex B", fill = palette.green }),
      }),
      demo_row("gap ignores hidden middle", styles.fixed_stage, {
        with_styles(styles, "fixed_box", { debugName = "visible A", fill = palette.gold }),
        with_styles(styles, "hidden_box", { debugName = "hidden with margin", fill = palette.red }),
        with_styles(styles, "fixed_box", { debugName = "visible B", fill = palette.accent }),
      }),
      demo_row("hidden subtree is zero", styles.stage, {
        with_styles(styles, "flex_box", { debugName = "visible left", fill = palette.green }),
        with_styles(styles, "hidden_parent", { debugName = "hidden parent", fill = palette.red }, {
          with_styles(styles, "hidden_child", { debugName = "hidden child", fill = palette.gold }),
        }),
        with_styles(styles, "flex_box", { debugName = "visible right", fill = palette.accent }),
      }),
      demo_row("contents children join parent flow", styles.stage, {
        with_styles(styles, "flex_box", { debugName = "outer left", fill = palette.accent }),
        with_styles(styles, "contents_parent", { debugName = "contents wrapper", fill = palette.red }, {
          with_styles(styles, "contents_child", { debugName = "contents child A", fill = palette.gold }),
          with_styles(styles, "contents_child", { debugName = "contents child B", fill = palette.green }),
        }),
        with_styles(styles, "flex_box", { debugName = "outer right", fill = palette.red }),
      }),
    })
  end,
}
