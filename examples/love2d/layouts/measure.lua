-- 测量布局：展示文本节点通过 Love2D 字体测量获得天然尺寸，并与显式尺寸和 flex 增长一起工作。
return {
  id = "measure",
  name = "Measure",
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
        height = 104,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 12,
        paddingVertical = 14,
        gap = 10,
      },
      label = {
        width = 180,
        height = 76,
      },
      stage = {
        flex = 1,
        height = 76,
        flexDirection = "row",
        alignItems = "flex-start",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      centered_stage = {
        flex = 1,
        height = 76,
        flexDirection = "row",
        alignItems = "center",
        paddingHorizontal = 10,
        paddingVertical = 10,
        gap = 10,
      },
      tall_box = {
        width = 54,
        height = 56,
      },
    })

    local function measured_text(text, fill, style)
      return ui.text(text, {
        style = style,
        debugName = text,
        fill = fill,
        measure = function()
          local measured_width, measured_height = ctx.measureText(text)
          return { width = measured_width, height = measured_height }
        end,
      })
    end

    local function measure_row(name, stage_style, children)
      return with_styles(styles, "row", { debugName = name, fill = palette.panel_alt }, {
        with_styles(styles, "label", { debugName = name .. " label", fill = { 0, 0, 0, 0 } }, {
          label(name, { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
        }),
        ui.div({ style = stage_style, debugName = name .. " stage", fill = palette.panel }, children),
      })
    end

    return with_styles(styles, "screen", { debugName = "measure screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "measure header", fill = palette.panel }, {
        label("Text nodes can measure their natural size before Yoga places them.", {
          style = { flex = 1, height = 28 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
      measure_row("natural text sizes", styles.stage, {
        measured_text("short", palette.accent),
        measured_text("measured label", palette.green),
        measured_text("a much longer measured label", palette.gold),
      }),
      measure_row("center aligned", styles.centered_stage, {
        measured_text("natural", palette.accent),
        with_styles(styles, "tall_box", { debugName = "fixed tall", fill = palette.red }),
        measured_text("centered by cross axis", palette.green),
      }),
      measure_row("explicit width wins", styles.stage, {
        measured_text("natural width", palette.gold),
        measured_text("forced to 150", palette.accent, { width = 150 }),
        measured_text("natural again", palette.green),
      }),
      measure_row("measured flex grows", styles.stage, {
        measured_text("base", palette.red),
        measured_text("flex grows from measured base", palette.accent, { flex = 1 }),
      }),
    })
  end,
}
