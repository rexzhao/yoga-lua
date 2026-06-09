-- Love2D RPG UI asset contract: renderer behavior, target metrics, and AI output sizes.
local metrics = {
  grid = 4,
  screenPadding = 16,
  gap = 12,
  rowGap = 8,
  panelPadding = 12,
  panelGap = 8,
  navHeight = 44,
  navButtonWidth = 126,
  buttonHeight = 34,
  smallButtonHeight = 30,
  buttonPaddingX = 12,
  buttonPaddingY = 7,
  smallButtonPaddingX = 8,
  smallButtonPaddingY = 6,
  slotWidth = 104,
  slotHeight = 80,
  slotPadding = 8,
  textLabelHeight = 18,
  textControlHeight = 20,
  textBodyHeight = 24,
  textTitleHeight = 30,
  statGroupHeight = 38,
  statLabelHeight = 18,
  statGap = 4,
  barHeight = 12,
  messageHeight = 60,
  messagePadding = 12,
  messageTextHeight = 36,
}

local style_pack = "moonlit_v2/"

local function nine(file, width, height, slice, border, min_width, min_height)
  return {
    file = style_pack .. file,
    size = { width = width, height = height },
    mode = "nine",
    slice = slice,
    border = border,
    minWidth = min_width,
    minHeight = min_height,
    filter = "linear",
  }
end

return {
  metrics = metrics,
  assets = {
    panel = nine(
      "panel",
      512,
      217,
      { left = 88, right = 88, top = 64, bottom = 64 },
      { left = 24, right = 24, top = 22, bottom = 22 },
      96,
      72
    ),
    parchment = nine(
      "parchment",
      512,
      265,
      { left = 86, right = 86, top = 72, bottom = 72 },
      { left = 24, right = 24, top = 24, bottom = 24 },
      104,
      80
    ),
    slot = nine(
      "slot",
      256,
      246,
      { left = 58, right = 58, top = 58, bottom = 58 },
      { left = 14, right = 14, top = 14, bottom = 14 },
      64,
      52
    ),
    button = nine(
      "button",
      512,
      164,
      { left = 108, right = 108, top = 52, bottom = 52 },
      { left = 18, right = 18, top = 11, bottom = 11 },
      72,
      30
    ),
    button_gold = nine(
      "button_gold",
      512,
      138,
      { left = 108, right = 108, top = 44, bottom = 44 },
      { left = 18, right = 18, top = 10, bottom = 10 },
      72,
      30
    ),

    bar_bg = {
      file = style_pack .. "bar_bg",
      size = { width = 512, height = 96 },
      mode = "threeX",
      slice = { left = 62, right = 62 },
      border = { left = 8, right = 8 },
      minWidth = 24,
      minHeight = metrics.barHeight,
      filter = "linear",
    },
    bar_fill = {
      file = style_pack .. "bar_fill",
      size = { width = 384, height = 41 },
      mode = "threeX",
      slice = { left = 46, right = 46 },
      border = { left = 7, right = 7 },
      minWidth = 18,
      minHeight = metrics.barHeight,
      filter = "linear",
    },

    portrait = { file = style_pack .. "portrait", size = { width = 256, height = 300 }, mode = "cover", filter = "linear" },
    pouch = { file = style_pack .. "pouch", size = { width = 256, height = 263 }, mode = "contain", filter = "linear" },
    map_camp = { file = "map_camp", size = { width = 384, height = 351 }, mode = "cover", filter = "linear" },
    map_forest = { file = "map_forest", size = { width = 384, height = 354 }, mode = "cover", filter = "linear" },
    map_river = { file = "map_river", size = { width = 384, height = 379 }, mode = "cover", filter = "linear" },
    map_ruins = { file = "map_ruins", size = { width = 384, height = 326 }, mode = "cover", filter = "linear" },
  },
}
