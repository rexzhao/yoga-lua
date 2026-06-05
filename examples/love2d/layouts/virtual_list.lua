-- 虚拟列表布局：展示固定高度长列表只构建可见行、overscan 行和上下 spacer，并用 scrollOffset 直接跳转。
return {
  id = "virtual-list",
  name = "Virtual List",
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
        height = 54,
        flexDirection = "column",
        paddingHorizontal = 10,
        paddingVertical = 8,
        gap = 4,
      },
      body = {
        flex = 1,
        flexDirection = "row",
        gap = 12,
      },
      list_panel = {
        flex = 1,
        flexDirection = "column",
        padding = 10,
      },
      list = {
        flex = 1,
        overflow = "scroll",
      },
      row = {
        height = 28,
        flexDirection = "row",
        paddingHorizontal = 10,
        paddingVertical = 5,
        gap = 8,
      },
      row_number = {
        width = 72,
        height = 18,
      },
      row_label = {
        flex = 1,
        height = 18,
      },
      stats = {
        width = 230,
        flexDirection = "column",
        padding = 10,
        gap = 8,
      },
      stat = {
        height = 44,
        paddingHorizontal = 8,
        paddingVertical = 8,
      },
    })

    local item_count = 10000
    local item_height = 28
    local viewport_height = math.max(120, height - 160)
    local scroll_offset = 7340
    local rendered = 0

    local list = ui.virtualList({
      itemCount = item_count,
      itemHeight = item_height,
      viewportHeight = viewport_height,
      scrollOffset = scroll_offset,
      overscan = 2,
      style = styles.list,
      debugName = "virtual list",
      fill = palette.panel,
      clipChildren = true,
      renderItem = function(index)
        rendered = rendered + 1
        local fill = index % 2 == 0 and palette.panel_alt or palette.panel

        return with_styles(styles, "row", {
          debugName = "row " .. index,
          fill = fill,
        }, {
          with_styles(styles, "row_number", {
            debugName = "#" .. index,
            fill = palette.accent,
          }, {
            label("#" .. index, {
              style = { height = 18 },
              textColor = palette.text,
              fill = { 0, 0, 0, 0 },
              stroke = false,
            }),
          }),
          with_styles(styles, "row_label", {
            debugName = "visible item " .. index,
            fill = { 0, 0, 0, 0 },
            stroke = false,
          }, {
            label("inventory record " .. index, {
              style = { height = 18 },
              textColor = palette.text,
              fill = { 0, 0, 0, 0 },
              stroke = false,
            }),
          }),
        })
      end,
    })

    local virtual = list.virtual

    local function stat(name, value)
      return with_styles(styles, "stat", {
        debugName = name,
        fill = palette.panel,
      }, {
        label(name .. ": " .. value, {
          style = { height = 20 },
          textColor = palette.text,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
      })
    end

    return with_styles(styles, "screen", { debugName = "virtual list screen", fill = palette.background }, {
      with_styles(styles, "header", { debugName = "virtual list header", fill = palette.panel }, {
        label("Fixed-height virtualization keeps the tree small while preserving scrollable content size.", {
          style = { height = 20 },
          fill = { 0, 0, 0, 0 },
        }),
        label("This view jumps directly into a 10,000-row list and renders only the visible window.", {
          style = { height = 18 },
          textColor = palette.muted,
          fill = { 0, 0, 0, 0 },
        }),
      }),
      with_styles(styles, "body", { debugName = "virtual list body", fill = { 0, 0, 0, 0 }, stroke = false }, {
        with_styles(styles, "list_panel", { debugName = "virtual list panel", fill = palette.panel_alt }, {
          list,
        }),
        with_styles(styles, "stats", { debugName = "virtual list stats", fill = palette.panel_alt }, {
          stat("items", tostring(virtual.itemCount)),
          stat("visible", virtual.visibleStart .. "-" .. virtual.visibleEnd),
          stat("rendered", tostring(rendered)),
          stat("top spacer", tostring(virtual.topSpacerHeight)),
          stat("max scroll", tostring(virtual.maxScroll)),
        }),
      }),
    })
  end,
}
