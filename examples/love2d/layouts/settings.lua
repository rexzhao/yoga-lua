-- 设置界面布局：展示纵向列表、固定标题列和使用 flex 撑开的控制区域。
return {
  id = "settings",
  name = "Settings",
  build = function(ctx, width, height)
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label
    local unpack = ctx.unpack
    local outer_padding = 18
    local row_height = 54

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "column",
        padding = outer_padding,
        gap = 10,
      },
      header = {
        height = 52,
      },
      row = {
        height = row_height,
        flexDirection = "row",
        paddingHorizontal = 8,
        paddingVertical = 8,
        gap = 8,
      },
      title = {
        width = 280,
        height = 38,
      },
      control = {
        flex = 1,
        height = 38,
      },
    })

    local rows = {}
    local names = { "Master volume", "Music", "Effects", "Voice", "Brightness", "Camera shake", "Subtitles" }
    for index, name in ipairs(names) do
      rows[#rows + 1] = with_styles(styles, "row", {
        debugName = "setting row " .. index,
        fill = index % 2 == 0 and palette.panel or palette.panel_alt,
      }, {
        with_styles(styles, "title", { debugName = name, fill = { 0, 0, 0, 0 } }, {
          label(name),
        }),
        with_styles(styles, "control", { debugName = name .. " control", fill = index > 5 and palette.green or palette.accent }),
      })
    end

    return with_styles(styles, "screen", { debugName = "settings screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "settings header", fill = palette.panel }, {
        label("Settings", { style = { height = 32 }, fill = { 0, 0, 0, 0 } }),
      }),
      unpack(rows),
    })
  end,
}

