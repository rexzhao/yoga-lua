-- 启动选择界面布局：使用 yoga 绘制可选 UI 示例列表和键盘/鼠标操作提示。
return {
  id = "menu",
  name = "Select UI",
  build = function(ctx, width, height, cases, selected_index)
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
      title = {
        height = 54,
        flexDirection = "column",
        paddingHorizontal = 12,
        paddingVertical = 8,
        gap = 4,
      },
      option = {
        height = 72,
        flexDirection = "row",
        paddingHorizontal = 12,
        paddingVertical = 10,
        gap = 10,
      },
      number = {
        width = 44,
        height = 52,
      },
      name = {
        flex = 1,
        height = 52,
      },
      hint = {
        height = 38,
      },
    })

    local children = {
      with_styles(styles, "title", { debugName = "selection title", fill = palette.panel }, {
        label("Select a UI layout", { style = { height = 22 }, fill = { 0, 0, 0, 0 } }),
        label("Use mouse wheel, PageUp/PageDown, click, or Up/Down + Enter.", {
          style = { height = 18 },
          fill = { 0, 0, 0, 0 },
        }),
      }),
    }

    for index, case in ipairs(cases) do
      local selected = index == selected_index
      local fill = selected and palette.accent or palette.panel_alt
      children[#children + 1] = with_styles(styles, "option", {
        debugName = case.name,
        caseIndex = index,
        fill = fill,
      }, {
        with_styles(styles, "number", {
          debugName = tostring(index),
          caseIndex = index,
          fill = selected and palette.gold or palette.panel,
        }),
        with_styles(styles, "name", {
          debugName = case.name,
          caseIndex = index,
          fill = { 0, 0, 0, 0 },
        }, {
          label(case.name, {
            debugName = case.name,
            caseIndex = index,
            style = { height = 24 },
            fill = { 0, 0, 0, 0 },
          }),
        }),
      })
    end

    children[#children + 1] = with_styles(styles, "hint", {
      debugName = "menu hint",
      fill = palette.panel,
    }, {
      label("Esc returns here from any UI screen.", { style = { height = 20 }, fill = { 0, 0, 0, 0 } }),
    })

    return with_styles(styles, "screen", {
      debugName = "selection screen",
      fill = palette.background,
      clipChildren = true,
    }, children)
  end,
}
