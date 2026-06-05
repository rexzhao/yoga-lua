-- 调试浮层布局：使用 yoga 绘制顶部标题栏、操作提示和底部 hover 节点信息。
return {
  id = "overlay",
  name = "Overlay",
  build = function(ctx, width, height, state)
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label
    local chrome = ctx.chrome
    local hover_text = state.hoverText or ""
    local has_hover = hover_text ~= ""

    local styles = ctx.ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
      },
      top_bar = {
        height = 34,
        flexDirection = "row",
        paddingHorizontal = 12,
        paddingVertical = 6,
        gap = 10,
      },
      title = {
        flex = 1,
        height = 22,
      },
      hint = {
        width = 240,
        height = 22,
      },
      spacer = {
        flex = 1,
      },
      bottom_safe = {
        height = chrome.bottom,
        paddingHorizontal = 12,
        paddingVertical = 6,
      },
      hover_bar = {
        height = 26,
        paddingHorizontal = 10,
        paddingVertical = 4,
      },
      hover_text = {
        flex = 1,
        height = 18,
      },
    })

    local bottom_fill = has_hover and { 0.05, 0.06, 0.07, 0.92 } or { 0, 0, 0, 0 }

    return with_styles(styles, "screen", {
      debugName = "overlay screen",
      fill = { 0, 0, 0, 0 },
      stroke = false,
    }, {
      with_styles(styles, "top_bar", {
        debugName = "overlay top bar",
        fill = { 0.05, 0.06, 0.07, 0.88 },
        stroke = false,
      }, {
        label("yoga-lua / Love2D visualizer - " .. state.title, {
          style = styles.title,
          textColor = palette.text,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
        label(state.hint, {
          style = styles.hint,
          textColor = palette.muted,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
      }),
      with_styles(styles, "spacer", {
        fill = { 0, 0, 0, 0 },
        stroke = false,
      }),
      with_styles(styles, "bottom_safe", {
        debugName = "overlay bottom safe area",
        fill = { 0, 0, 0, 0 },
        stroke = false,
      }, {
        with_styles(styles, "hover_bar", {
          debugName = "overlay hover bar",
          fill = bottom_fill,
          stroke = has_hover,
        }, {
          label(hover_text, {
            style = styles.hover_text,
            textColor = palette.text,
            fill = { 0, 0, 0, 0 },
            stroke = false,
          }),
        }),
      }),
    })
  end,
}
