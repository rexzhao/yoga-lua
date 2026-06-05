-- 多行交叉轴对齐布局：展示 flexWrap 多行时 alignContent 如何分配行组在容器高度中的位置。
return {
  id = "align_content",
  name = "Align Content",
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
        gap = 10,
      },
      header = {
        height = 42,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 8,
      },
      row = {
        height = 132,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 12,
        gap = 10,
      },
      name = {
        width = 170,
        height = 108,
      },
      track = {
        flex = 1,
        height = 108,
        flexDirection = "row",
        flexWrap = "wrap",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        columnGap = 10,
        rowGap = 12,
      },
      chip = {
        width = 210,
        height = 24,
      },
      stretch_chip = {
        width = 210,
      },
    })

    local function copy_style(source)
      local target = {}
      for key, value in pairs(source) do
        target[key] = value
      end
      return target
    end

    local function chips(use_stretch)
      local class = use_stretch and "stretch_chip" or "chip"
      return {
        with_styles(styles, class, { debugName = "A", fill = palette.accent }),
        with_styles(styles, class, { debugName = "B", fill = palette.green }),
        with_styles(styles, class, { debugName = "C", fill = palette.gold }),
        with_styles(styles, class, { debugName = "D", fill = palette.red }),
        with_styles(styles, class, { debugName = "E", fill = palette.accent }),
        with_styles(styles, class, { debugName = "F", fill = palette.green }),
      }
    end

    local function demo_row(name, align_content, fill, use_stretch)
      local track_style = copy_style(styles.track)
      track_style.alignContent = align_content
      if use_stretch then
        track_style.alignItems = "stretch"
      end

      return with_styles(styles, "row", { debugName = name .. " row", fill = fill }, {
        with_styles(styles, "name", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = track_style, debugName = name .. " track", fill = palette.panel }, chips(use_stretch)),
      })
    end

    return with_styles(styles, "screen", { debugName = "align content screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "align content header", fill = palette.panel }, {
        label("alignContent distributes wrapped lines along the cross axis.", {
          style = { flex = 1, height = 26 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      demo_row("flex-start", "flex-start", palette.panel_alt),
      demo_row("center", "center", palette.panel),
      demo_row("space-between", "space-between", palette.panel_alt),
      demo_row("stretch", "stretch", palette.panel, true),
    })
  end,
}
