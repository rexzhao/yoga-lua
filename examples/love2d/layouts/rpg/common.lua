-- RPG 公共布局辅助：提供按钮、导航、面板和状态条等可复用 Yoga 节点。
local common = {}

local function transparent()
  return { 0, 0, 0, 0 }
end

function common.styles(ctx, width, height)
  return ctx.ui.stylesheet({
    screen = {
      width = width,
      height = height,
      flexDirection = "column",
      padding = 14,
      gap = 10,
    },
    nav = {
      height = 44,
      flexDirection = "row",
      gap = 8,
    },
    body = {
      flex = 1,
      flexDirection = "row",
      gap = 10,
    },
    column = {
      flex = 1,
      flexDirection = "column",
      gap = 10,
    },
    panel = {
      flexDirection = "column",
      padding = 10,
      gap = 8,
    },
    row = {
      flexDirection = "row",
      gap = 8,
    },
    title = {
      height = 30,
    },
    text = {
      height = 24,
    },
    button = {
      height = 34,
      paddingHorizontal = 10,
      paddingVertical = 7,
    },
    small_button = {
      height = 30,
      paddingHorizontal = 8,
      paddingVertical = 6,
    },
    bar = {
      height = 12,
      flexDirection = "row",
    },
    bar_fill = {
      height = 12,
    },
  })
end

function common.text(ctx, text, props)
  props = props or {}
  props.style = props.style or { height = 24 }
  props.debugName = props.debugName or text
  props.fill = props.fill or transparent()
  return ctx.ui.text(text, props)
end

function common.box(ctx, styles, class, props, children)
  props = props or {}
  props.class = class
  props.styles = styles
  return ctx.ui.div(props, children or {})
end

function common.panel(ctx, styles, props, children)
  props = props or {}
  props.fill = props.fill or ctx.palette.panel
  props.debugName = props.debugName or "panel"
  if props.image ~= false then
    props.image = props.image or "panel"
  end
  return common.box(ctx, styles, "panel", props, children)
end

function common.button(ctx, styles, label, action, props)
  props = props or {}
  props.action = action
  props.debugName = props.debugName or label
  props.fill = props.fill or ctx.palette.panel_alt
  props.image = props.image or "button"
  props.tint = props.tint or props.fill
  props.stroke = props.stroke
  return common.box(ctx, styles, props.small and "small_button" or "button", props, {
    common.text(ctx, label, {
      action = action,
      screen = props.screen,
      itemId = props.itemId,
      skillId = props.skillId,
      questId = props.questId,
      shopId = props.shopId,
      debugName = label,
      style = { height = props.small and 18 or 20 },
      fill = transparent(),
      textColor = props.textColor,
    }),
  })
end

function common.nav(ctx, styles, state, active)
  local palette = ctx.palette
  local screens = {
    { id = "hud", label = "Field" },
    { id = "character", label = "Character" },
    { id = "skills", label = "Skills" },
    { id = "inventory", label = "Bag" },
    { id = "quests", label = "Quests" },
    { id = "camp", label = "Camp" },
  }
  local buttons = {}

  for _, screen in ipairs(screens) do
    buttons[#buttons + 1] = common.button(ctx, styles, screen.label, "nav", {
      screen = screen.id,
      fill = screen.id == active and palette.accent or palette.panel_alt,
      style = { width = 126, height = 34 },
    })
  end

  buttons[#buttons + 1] = common.box(ctx, styles, "button", {
    debugName = "gold",
    fill = palette.gold,
    image = "button_gold",
    style = { flex = 1, height = 34 },
  }, {
    common.text(ctx, "Gold " .. state.hero.gold, { style = { height = 20 }, fill = transparent() }),
  })

  return common.box(ctx, styles, "nav", { debugName = "rpg navigation", fill = transparent() }, buttons)
end

function common.stat_bar(ctx, styles, label, value, max_value, color)
  local percent = 0
  if max_value and max_value > 0 then
    percent = math.max(0, math.min(1, value / max_value))
  end

  return common.box(ctx, styles, "column", {
    debugName = label .. " bar group",
    fill = transparent(),
    style = { height = 38, gap = 4 },
  }, {
    common.text(ctx, string.format("%s %d/%d", label, value, max_value), {
      style = { height = 18 },
      fill = transparent(),
    }),
    common.box(ctx, styles, "bar", {
      debugName = label .. " bar",
      fill = ctx.palette.panel_alt,
      image = "bar_bg",
      tint = { 0.45, 0.46, 0.48, 1 },
    }, {
      common.box(ctx, styles, "bar_fill", {
        fill = color,
        image = "bar_fill",
        tint = color,
        style = { width = tostring(math.floor(percent * 100)) .. "%", height = 12 },
        stroke = false,
      }),
    }),
  })
end

function common.message(ctx, styles, state)
  return common.panel(ctx, styles, {
    debugName = "message log",
    fill = ctx.palette.panel,
    style = { height = 58, padding = 10 },
  }, {
    common.text(ctx, state.message or "", {
      style = { height = 36 },
      fill = transparent(),
      textColor = ctx.palette.text,
    }),
  })
end

return common
