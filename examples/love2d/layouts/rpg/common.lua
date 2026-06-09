-- RPG 公共布局辅助：提供按钮、导航、面板和状态条等可复用 Yoga 节点。
local ui_assets = require("ui_assets")

local common = {}
common.metrics = ui_assets.metrics

local function transparent()
  return { 0, 0, 0, 0 }
end

function common.styles(ctx, width, height)
  local metrics = common.metrics

  return ctx.ui.stylesheet({
    screen = {
      width = width,
      height = height,
      flexDirection = "column",
      padding = metrics.screenPadding,
      gap = metrics.gap,
    },
    nav = {
      height = metrics.navHeight,
      flexDirection = "row",
      gap = metrics.rowGap,
    },
    body = {
      flex = 1,
      flexDirection = "row",
      gap = metrics.gap,
    },
    column = {
      flex = 1,
      flexDirection = "column",
      gap = metrics.gap,
    },
    panel = {
      flexDirection = "column",
      padding = metrics.panelPadding,
      gap = metrics.panelGap,
    },
    row = {
      flexDirection = "row",
      gap = metrics.rowGap,
    },
    title = {
      height = metrics.textTitleHeight,
    },
    text = {
      height = metrics.textBodyHeight,
    },
    button = {
      height = metrics.buttonHeight,
      paddingHorizontal = metrics.buttonPaddingX,
      paddingVertical = metrics.buttonPaddingY,
    },
    small_button = {
      height = metrics.smallButtonHeight,
      paddingHorizontal = metrics.smallButtonPaddingX,
      paddingVertical = metrics.smallButtonPaddingY,
    },
    bar = {
      height = metrics.barHeight,
      flexDirection = "row",
    },
    bar_fill = {
      height = metrics.barHeight,
    },
  })
end

function common.text(ctx, text, props)
  props = props or {}
  props.style = props.style or { height = common.metrics.textBodyHeight }
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
      style = { height = props.small and common.metrics.textLabelHeight or common.metrics.textControlHeight },
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
      style = { width = common.metrics.navButtonWidth, height = common.metrics.buttonHeight },
    })
  end

  buttons[#buttons + 1] = common.box(ctx, styles, "button", {
    debugName = "gold",
    fill = palette.gold,
    image = "button_gold",
    style = { flex = 1, height = common.metrics.buttonHeight },
  }, {
    common.text(ctx, "Gold " .. state.hero.gold, { style = { height = common.metrics.textControlHeight }, fill = transparent() }),
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
    style = { height = common.metrics.statGroupHeight, gap = common.metrics.statGap },
  }, {
    common.text(ctx, string.format("%s %d/%d", label, value, max_value), {
      style = { height = common.metrics.statLabelHeight },
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
        style = { width = tostring(math.floor(percent * 100)) .. "%", height = common.metrics.barHeight },
        stroke = false,
      }),
    }),
  })
end

function common.message(ctx, styles, state)
  return common.panel(ctx, styles, {
    debugName = "message log",
    fill = ctx.palette.panel,
    style = { height = common.metrics.messageHeight, padding = common.metrics.messagePadding },
  }, {
    common.text(ctx, state.message or "", {
      style = { height = common.metrics.messageTextHeight },
      fill = transparent(),
      textColor = ctx.palette.text,
    }),
  })
end

return common
