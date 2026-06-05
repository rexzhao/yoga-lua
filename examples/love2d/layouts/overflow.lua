-- 溢出裁剪布局：展示 overflow = "visible"、"hidden"、"scroll" 在 Love2D 渲染层对子节点绘制范围的影响。
return {
  id = "overflow",
  name = "Overflow",
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
        height = 126,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 190,
        height = 92,
      },
      stage = {
        width = 330,
        height = 92,
        paddingHorizontal = 12,
        paddingVertical = 12,
      },
      child = {
        width = 420,
        height = 68,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      chip = {
        width = 120,
        height = 44,
      },
    })

    local function chip(name, fill)
      return with_styles(styles, "chip", { debugName = name, fill = fill }, {
        label(name, { style = { height = 22 }, fill = { 0, 0, 0, 0 } }),
      })
    end

    local function row(name, overflow, fill)
      return with_styles(styles, "row", { debugName = name, fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        with_styles(styles, "stage", {
          debugName = name .. " viewport",
          fill = fill,
          style = { overflow = overflow },
        }, {
          with_styles(styles, "child", { debugName = name .. " overflowing child", fill = palette.panel }, {
            chip(name .. " A", palette.accent),
            chip(name .. " B", palette.green),
            chip(name .. " C", palette.gold),
          }),
        }),
      })
    end

    return with_styles(styles, "screen", { debugName = "overflow screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "overflow header", fill = palette.panel }, {
        label("Overflow clips rendering when hidden or scroll; visible leaves child content unconstrained.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      row("visible", "visible", palette.panel),
      row("hidden", "hidden", palette.panel),
      row("scroll", "scroll", palette.panel),
    })
  end,
}
