local yoga
local ui

local unpack = table.unpack or unpack

local root
local current_case = 1
local hovered
local fonts = {}

local palette = {
  background = { 0.08, 0.09, 0.10, 1.0 },
  panel = { 0.16, 0.18, 0.21, 1.0 },
  panel_alt = { 0.20, 0.22, 0.26, 1.0 },
  accent = { 0.20, 0.48, 0.86, 1.0 },
  green = { 0.22, 0.62, 0.42, 1.0 },
  gold = { 0.88, 0.66, 0.24, 1.0 },
  red = { 0.76, 0.28, 0.28, 1.0 },
  text = { 0.92, 0.94, 0.96, 1.0 },
  muted = { 0.58, 0.64, 0.70, 1.0 },
  line = { 0.34, 0.38, 0.44, 1.0 },
  hover = { 1.00, 1.00, 1.00, 1.0 },
}

local function normalize_path(path)
  return (path:gsub("\\", "/"))
end

local function dirname(path)
  path = path:gsub("/+$", "")
  return path:match("^(.*)/[^/]*$") or "."
end

local function configure_package_path()
  local source = normalize_path(love.filesystem.getSource())
  local repo_root = dirname(dirname(source))
  package.path = table.concat({
    repo_root .. "/src/?.lua",
    repo_root .. "/src/?/init.lua",
    package.path,
  }, ";")
end

local function with_styles(styles, class, props, children)
  props = props or {}
  props.class = class
  props.styles = styles
  return ui.div(props, children)
end

local function label(text, props)
  props = props or {}
  props.style = props.style or { height = 24 }
  props.debugName = props.debugName or text
  props.fill = props.fill or { 0, 0, 0, 0 }
  return ui.text(text, props)
end

local function build_inventory(width, height)
  local outer_padding = 16
  local toolbar_height = 48
  local body_height = height - outer_padding * 2 - toolbar_height - 12
  local body_width = width - outer_padding * 2
  local sidebar_width = 230
  local detail_width = 300
  local grid_width = body_width - sidebar_width - detail_width - 24

  local styles = ui.stylesheet({
    screen = {
      width = width,
      height = height,
      flexDirection = "column",
      padding = outer_padding,
      gap = 12,
    },
    toolbar = {
      height = toolbar_height,
      flexDirection = "row",
      padding = 8,
      gap = 8,
    },
    body = {
      width = body_width,
      height = body_height,
      flexDirection = "row",
      gap = 12,
    },
    sidebar = {
      width = sidebar_width,
      height = body_height,
      flexDirection = "column",
      padding = 10,
      gap = 8,
    },
    grid = {
      width = grid_width,
      height = body_height,
      flexDirection = "column",
      padding = 10,
      gap = 8,
    },
    row = {
      height = 72,
      flexDirection = "row",
      gap = 8,
    },
    slot = {
      width = 72,
      height = 72,
    },
    detail = {
      width = detail_width,
      height = body_height,
      flexDirection = "column",
      padding = 12,
      gap = 10,
    },
    detail_block = {
      height = 92,
    },
  })

  local rows = {}
  for row_index = 1, 4 do
    local slots = {}
    for slot_index = 1, 6 do
      slots[#slots + 1] = with_styles(styles, "slot", {
        debugName = "slot " .. row_index .. "." .. slot_index,
        fill = slot_index == 2 and palette.gold or palette.panel_alt,
      })
    end
    rows[#rows + 1] = with_styles(styles, "row", { debugName = "item row " .. row_index, fill = { 0, 0, 0, 0 } }, slots)
  end

  return with_styles(styles, "screen", { debugName = "inventory screen", fill = palette.background }, {
    with_styles(styles, "toolbar", { debugName = "toolbar", fill = palette.panel }, {
      ui.button("Equip", { style = { width = 120, height = 32 }, debugName = "Equip button", fill = palette.accent }),
      ui.button("Sort", { style = { width = 100, height = 32 }, debugName = "Sort button", fill = palette.green }),
      ui.button("Close", { style = { width = 100, height = 32 }, debugName = "Close button", fill = palette.red }),
    }),
    with_styles(styles, "body", { debugName = "body", fill = { 0, 0, 0, 0 } }, {
      with_styles(styles, "sidebar", { debugName = "category sidebar", fill = palette.panel }, {
        label("Weapons", { style = { height = 30 }, fill = palette.accent }),
        label("Armor", { style = { height = 30 }, fill = palette.panel_alt }),
        label("Consumables", { style = { height = 30 }, fill = palette.panel_alt }),
        label("Materials", { style = { height = 30 }, fill = palette.panel_alt }),
      }),
      with_styles(styles, "grid", { debugName = "inventory grid", fill = palette.panel }, rows),
      with_styles(styles, "detail", { debugName = "item detail", fill = palette.panel }, {
        label("Selected Item", { style = { height = 28 }, fill = palette.accent }),
        with_styles(styles, "detail_block", { debugName = "item preview", fill = palette.panel_alt }),
        with_styles(styles, "detail_block", { debugName = "item stats", fill = palette.panel_alt }),
        with_styles(styles, "detail_block", { debugName = "item actions", fill = palette.panel_alt }),
      }),
    }),
  })
end

local function build_settings(width, height)
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
      padding = 8,
      gap = 8,
    },
    title = {
      width = 280,
      height = 38,
    },
    control = {
      width = 180,
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
end

local function build_row_wrap_placeholder(width, height)
  local outer_padding = 18
  local content_width = width - outer_padding * 2
  local styles = ui.stylesheet({
    screen = {
      width = width,
      height = height,
      flexDirection = "column",
      padding = outer_padding,
      gap = 12,
    },
    strip = {
      width = content_width,
      height = 96,
      flexDirection = "row",
      padding = 10,
      gap = 10,
    },
    chip = {
      width = 132,
      height = 76,
    },
  })

  local strips = {}
  for strip_index = 1, 5 do
    local chips = {}
    for chip_index = 1, 6 do
      chips[#chips + 1] = with_styles(styles, "chip", {
        debugName = "chip " .. strip_index .. "." .. chip_index,
        fill = ({ palette.accent, palette.green, palette.gold, palette.red })[((chip_index - 1) % 4) + 1],
      })
    end
    strips[#strips + 1] = with_styles(styles, "strip", {
      debugName = "row layout strip " .. strip_index,
      fill = strip_index % 2 == 0 and palette.panel or palette.panel_alt,
    }, chips)
  end

  return with_styles(styles, "screen", { debugName = "row layout screen", fill = palette.background }, strips)
end

local cases = {
  { name = "Inventory", build = build_inventory },
  { name = "Settings", build = build_settings },
  { name = "Rows", build = build_row_wrap_placeholder },
}

local function rebuild()
  local width, height = love.graphics.getDimensions()
  root = cases[current_case].build(width, height)
  yoga.calculateLayout(root, width, height)
end

local function has_flag(args, flag)
  local sources = { args, _G.arg }

  for _, source in ipairs(sources) do
    if source then
      for _, value in pairs(source) do
        if value == flag then
          return true
        end
      end
    end
  end

  return false
end

local function inside(node, x, y)
  local layout = node.layout
  return x >= layout.left
    and y >= layout.top
    and x <= layout.left + layout.width
    and y <= layout.top + layout.height
end

local function find_deepest(node, x, y)
  if not inside(node, x, y) then
    return nil
  end

  for index = #(node.children or {}), 1, -1 do
    local child = find_deepest(node.children[index], x, y)
    if child then
      return child
    end
  end

  return node
end

local function set_color(color)
  love.graphics.setColor(color[1], color[2], color[3], color[4] or 1.0)
end

local function draw_label(text, x, y, max_width)
  if not text or text == "" then
    return
  end

  set_color(palette.text)
  love.graphics.setFont(fonts.small)
  love.graphics.printf(text, x, y, max_width or 220, "left")
end

local function node_label(node)
  if node.type == "text" then
    return node.text
  end

  if node.type == "button" then
    return node.label
  end

  return node.props and node.props.debugName
end

local function draw_node(node, depth)
  local layout = node.layout
  local props = node.props or {}
  local fill = props.fill or palette.panel
  local radius = node.type == "text" and 0 or 6

  if fill[4] ~= 0 then
    set_color(fill)
    love.graphics.rectangle("fill", layout.left, layout.top, layout.width, layout.height, radius, radius)
  end

  local line = node == hovered and palette.hover or palette.line
  set_color(line)
  love.graphics.setLineWidth(node == hovered and 3 or 1)
  love.graphics.rectangle("line", layout.left, layout.top, layout.width, layout.height, radius, radius)

  local text = node_label(node)
  if text then
    draw_label(text, layout.left + 8, layout.top + 7, math.max(20, layout.width - 16))
  end

  for _, child in ipairs(node.children or {}) do
    draw_node(child, depth + 1)
  end
end

local function draw_overlay()
  local width = love.graphics.getWidth()
  local case = cases[current_case]

  set_color({ 0.05, 0.06, 0.07, 0.88 })
  love.graphics.rectangle("fill", 0, 0, width, 34)

  set_color(palette.text)
  love.graphics.setFont(fonts.normal)
  love.graphics.print("yoga-lua / Love2D visualizer - " .. case.name, 12, 8)

  set_color(palette.muted)
  love.graphics.setFont(fonts.small)
  love.graphics.print("Left/Right or 1-3", width - 145, 10)

  if hovered then
    local layout = hovered.layout
    local name = node_label(hovered) or hovered.type or "node"
    local text = string.format(
      "%s  x=%d y=%d w=%d h=%d",
      name,
      layout.left,
      layout.top,
      layout.width,
      layout.height
    )

    set_color({ 0.05, 0.06, 0.07, 0.92 })
    love.graphics.rectangle("fill", 12, love.graphics.getHeight() - 36, width - 24, 26, 6, 6)
    set_color(palette.text)
    love.graphics.print(text, 22, love.graphics.getHeight() - 30)
  end
end

function love.load(args)
  configure_package_path()
  yoga = require("yoga")
  ui = require("ui")

  fonts.normal = love.graphics.newFont(14)
  fonts.small = love.graphics.newFont(12)
  love.graphics.setBackgroundColor(palette.background)

  rebuild()

  if has_flag(args, "--smoke") then
    print("ok - love2d visualizer loaded")
    love.event.quit(0)
  end
end

function love.update()
  local x, y = love.mouse.getPosition()
  hovered = root and find_deepest(root, x, y) or nil
end

function love.draw()
  if root then
    draw_node(root, 0)
  end

  draw_overlay()
end

function love.resize()
  rebuild()
end

function love.keypressed(key)
  if key == "right" then
    current_case = current_case % #cases + 1
    rebuild()
  elseif key == "left" then
    current_case = (current_case - 2) % #cases + 1
    rebuild()
  elseif key == "1" or key == "2" or key == "3" then
    local index = tonumber(key)
    if cases[index] then
      current_case = index
      rebuild()
    end
  elseif key == "r" then
    rebuild()
  end
end
