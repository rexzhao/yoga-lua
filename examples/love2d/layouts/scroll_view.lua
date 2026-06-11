-- 普通滚动容器布局：展示 ScrollView 承载不同高度的普通子节点，并由外部状态控制滚动偏移。
local core_ui = require("ui")

local function card(ctx, styles, title, body, height, props)
  local palette = ctx.palette
  local with_styles = ctx.with_styles
  local label = ctx.label

  props = props or {}
  props.debugName = props.debugName or title
  props.fill = props.fill or palette.panel_alt
  local title_color = props.textColor or palette.text
  local body_color = props.bodyColor or palette.muted

  return with_styles(styles, "card", props, {
    label(title, {
      style = styles.card_title,
      textColor = title_color,
      fill = { 0, 0, 0, 0 },
      stroke = false,
    }),
    label(body, {
      style = { height = math.max(18, height - 44) },
      textColor = body_color,
      fill = { 0, 0, 0, 0 },
      stroke = false,
    }),
  })
end

local function find_scroll_view(node)
  while node do
    if node.type == "scrollView" and node.props and node.props.scrollId == "sidePanel" then
      return node
    end

    node = node.parent
  end

  return nil
end

return {
  id = "scroll-view",
  name = "Scroll View",

  createState = function()
    return {
      scrollOffset = 84,
      expanded = false,
    }
  end,

  hint = function()
    return "Controlled ScrollView"
  end,

  build = function(ctx, width, height, state)
    state = state or { scrollOffset = 0, expanded = false }
    local ui = ctx.ui
    local palette = ctx.palette
    local with_styles = ctx.with_styles
    local label = ctx.label

    local styles = ui.stylesheet({
      screen = {
        width = width,
        height = height,
        flexDirection = "row",
        paddingHorizontal = 18,
        paddingVertical = 18,
        gap = 14,
      },
      main = {
        flex = 1,
        flexDirection = "column",
        gap = 12,
      },
      hero = {
        height = 96,
        paddingHorizontal = 14,
        paddingVertical = 12,
        gap = 6,
      },
      log = {
        flex = 1,
        flexDirection = "column",
        gap = 10,
      },
      log_row = {
        height = 58,
        paddingHorizontal = 12,
        paddingVertical = 9,
      },
      side = {
        width = 430,
        height = math.max(120, height - 36),
        flexDirection = "column",
        gap = 10,
      },
      card = {
        flexDirection = "column",
        paddingHorizontal = 12,
        paddingVertical = 10,
        gap = 6,
      },
      card_title = {
        height = 20,
      },
      metric = {
        height = 70,
        flexDirection = "column",
        paddingHorizontal = 12,
        paddingVertical = 10,
        gap = 4,
      },
    })

    local panel_children = {
      with_styles(styles, "metric", {
        debugName = "scroll metrics",
        fill = palette.panel,
      }, {
        label("Offset " .. tostring(state.scrollOffset), {
          style = { height = 20 },
          textColor = palette.text,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
        label("The panel keeps its position in external state.", {
          style = { height = 18 },
          textColor = palette.muted,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
      }),
      card(ctx, styles, "Filters", "Compact chips, toggles, and field rows share the same side panel.", 92),
      card(ctx, styles, "Inspector", "This section is taller than its neighbors and keeps its own card height.", 130),
      card(ctx, styles, state.expanded and "Collapse Details" or "Expand Details", "A larger detail card can join or leave the panel.", 82, {
        action = "toggle-extra",
        fill = palette.accent,
      }),
    }

    if state.expanded then
      panel_children[#panel_children + 1] = card(
        ctx,
        styles,
        "Dynamic Section",
        "Expanded notes for the selected operation, with enough room for longer copy.",
        178,
        { fill = palette.panel }
      )
    end

    panel_children[#panel_children + 1] = card(ctx, styles, "Audit Trail", "Variable-height notes can sit below action rows.", 120)
    panel_children[#panel_children + 1] = card(ctx, styles, "Actions", "Reset is available for the side panel.", 104, {
      action = "reset-panel",
      fill = palette.gold,
      textColor = { 0.18, 0.13, 0.04, 1 },
      bodyColor = { 0.28, 0.20, 0.06, 1 },
    })

    local log_rows = {}
    for index = 1, 5 do
      log_rows[#log_rows + 1] = with_styles(styles, "log_row", {
        debugName = "activity " .. index,
        fill = index % 2 == 0 and palette.panel_alt or palette.panel,
      }, {
        label("Activity " .. index, {
          style = { height = 20 },
          textColor = palette.text,
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }),
      })
    end

    return with_styles(styles, "screen", {
      debugName = "scroll view screen",
      fill = palette.background,
      stroke = false,
    }, {
      with_styles(styles, "main", {
        debugName = "main area",
        fill = { 0, 0, 0, 0 },
        stroke = false,
      }, {
        with_styles(styles, "hero", {
          debugName = "summary",
          fill = palette.panel,
        }, {
          label("Generic ScrollView", {
            style = { height = 24 },
            textColor = palette.text,
            fill = { 0, 0, 0, 0 },
            stroke = false,
          }),
          label("Operations desk with a long side panel and mixed card heights.", {
            style = { height = 18 },
            textColor = palette.muted,
            fill = { 0, 0, 0, 0 },
            stroke = false,
          }),
        }),
        with_styles(styles, "log", {
          debugName = "activity log",
          fill = { 0, 0, 0, 0 },
          stroke = false,
        }, log_rows),
      }),
      ui.scrollView({
        scrollId = "sidePanel",
        scrollOffset = state.scrollOffset,
        axis = "y",
        style = styles.side,
        debugName = "side scroll panel",
        fill = palette.panel,
      }, panel_children),
    })
  end,

  handleClick = function(state, props)
    if props.action == "toggle-extra" then
      state.expanded = not state.expanded
      return true
    elseif props.action == "reset-panel" then
      state.scrollOffset = 0
      return true
    end

    return false
  end,

  wheelmoved = function(state, _x, y, hovered)
    local scroll_view = find_scroll_view(hovered)
    if not scroll_view then
      return false
    end

    state.scrollOffset = core_ui.scrollDelta(state.scrollOffset, -y * 44, scroll_view.scroll)
    return true
  end,
}
