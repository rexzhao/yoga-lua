-- 交叉轴对齐布局：展示 alignItems 与 alignSelf 在 row 容器中的上下对齐效果。
return {
  id = "align",
  name = "Align",
  build = function(ctx, width, height)
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label
    local outer_padding = 18

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
        paddingHorizontal = outer_padding,
        paddingVertical = outer_padding,
        gap = 10,
      },
      row = {
        height = 84,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
        gap = 10,
      },
      name = {
        width = 150,
        height = 68,
      },
      track = {
        flex = 1,
        height = 68,
        flexDirection = "row",
        paddingHorizontal = 8,
        paddingVertical = 8,
        gap = 8,
      },
      chip = {
        width = 58,
        height = 28,
      },
      tall_chip = {
        width = 58,
        height = 44,
      },
      stretch_chip = {
        width = 58,
      },
      self_chip = {
        width = 58,
        height = 24,
      },
    })

    local function copy_style(source)
      local target = {}
      for key, value in pairs(source) do
        target[key] = value
      end
      return target
    end

    local function aligned_row(name, align, fill, children)
      local track_style = copy_style(styles.track)
      track_style.alignItems = align

      return with_styles(styles, "row", { debugName = "align " .. name, fill = fill }, {
        with_styles(styles, "name", { debugName = name, fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = track_style, debugName = name .. " track", fill = palette.panel }, children),
      })
    end

    return with_styles(styles, "screen", { debugName = "align screen", fill = palette.background }, {
      aligned_row("stretch", "stretch", palette.panel_alt, {
        with_styles(styles, "stretch_chip", { debugName = "stretch A", fill = palette.accent }),
        with_styles(styles, "stretch_chip", { debugName = "stretch B", fill = palette.green }),
        with_styles(styles, "stretch_chip", { debugName = "stretch C", fill = palette.gold }),
      }),
      aligned_row("flex-start", "flex-start", palette.panel, {
        with_styles(styles, "chip", { debugName = "A", fill = palette.accent }),
        with_styles(styles, "tall_chip", { debugName = "B", fill = palette.green }),
        with_styles(styles, "chip", { debugName = "C", fill = palette.gold }),
      }),
      aligned_row("center", "center", palette.panel_alt, {
        with_styles(styles, "chip", { debugName = "A", fill = palette.accent }),
        with_styles(styles, "tall_chip", { debugName = "B", fill = palette.green }),
        with_styles(styles, "chip", { debugName = "C", fill = palette.gold }),
      }),
      aligned_row("flex-end", "flex-end", palette.panel, {
        with_styles(styles, "chip", { debugName = "A", fill = palette.accent }),
        with_styles(styles, "tall_chip", { debugName = "B", fill = palette.green }),
        with_styles(styles, "chip", { debugName = "C", fill = palette.gold }),
      }),
      aligned_row("alignSelf", "center", palette.panel_alt, {
        ui.div({ style = { width = 58, height = 24, alignSelf = "flex-start" }, debugName = "self start", fill = palette.accent }),
        with_styles(styles, "self_chip", { debugName = "parent center", fill = palette.green }),
        ui.div({ style = { width = 58, height = 24, alignSelf = "flex-end" }, debugName = "self end", fill = palette.gold }),
        ui.div({ style = { width = 58, alignSelf = "stretch" }, debugName = "self stretch", fill = palette.red }),
      }),
    })
  end,
}

