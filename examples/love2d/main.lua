local yoga
local ui

local unpack = table.unpack or unpack

local root
local current_case = 1
local mode = "menu"
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

local chrome = {
  top = 42,
  bottom = 44,
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
    source .. "/?.lua",
    source .. "/?/init.lua",
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

local layout_modules = {
  "layouts.inventory",
  "layouts.settings",
  "layouts.flex_spacing",
  "layouts.justify",
  "layouts.align",
}

local cases = {}
local layout_ctx
local menu_layout
local overlay_layout

local function layout_context()
  return {
    ui = ui,
    palette = palette,
    chrome = chrome,
    with_styles = with_styles,
    label = label,
    unpack = unpack,
  }
end

local function load_cases()
  layout_ctx = layout_context()
  menu_layout = require("layouts.menu")
  overlay_layout = require("layouts.overlay")
  cases = {}

  for _, module_name in ipairs(layout_modules) do
    local layout = require(module_name)
    cases[#cases + 1] = {
      id = layout.id,
      name = layout.name,
      build = function(width, height)
        return layout.build(layout_ctx, width, height)
      end,
    }
  end
end

local function offset_layout(node, dx, dy)
  node.layout.left = node.layout.left + dx
  node.layout.top = node.layout.top + dy

  for _, child in ipairs(node.children or {}) do
    offset_layout(child, dx, dy)
  end
end

local function rebuild()
  local width, window_height = love.graphics.getDimensions()
  local layout_height = math.max(1, window_height - chrome.top - chrome.bottom)

  if mode == "menu" then
    root = menu_layout.build(layout_ctx, width, layout_height, cases, current_case)
  else
    root = cases[current_case].build(width, layout_height)
  end

  yoga.calculateLayout(root, width, layout_height)
  offset_layout(root, 0, chrome.top)
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

local function find_case_at(node, x, y)
  if not inside(node, x, y) then
    return nil
  end

  for index = #(node.children or {}), 1, -1 do
    local child_case = find_case_at(node.children[index], x, y)
    if child_case then
      return child_case
    end
  end

  local props = node.props or {}
  return props.caseIndex
end

local function select_next(delta)
  current_case = (current_case + delta - 1) % #cases + 1
  rebuild()
end

local function open_case(index)
  if not cases[index] then
    return
  end

  current_case = index
  mode = "case"
  rebuild()
end

local function show_menu()
  mode = "menu"
  rebuild()
end

local function set_color(color)
  love.graphics.setColor(color[1], color[2], color[3], color[4] or 1.0)
end

local function draw_label(text, x, y, max_width, color)
  if not text or text == "" then
    return
  end

  set_color(color or palette.text)
  love.graphics.setFont(fonts.small)
  love.graphics.printf(text, x, y, max_width or 220, "left")
end

local function node_label(node, include_containers)
  if node.type == "text" then
    return node.text
  end

  if node.type == "button" then
    return node.label
  end

  if include_containers or #(node.children or {}) == 0 then
    return node.props and node.props.debugName
  end

  return nil
end

local function draw_node_label(node)
  local label = node_label(node, false)
  if not label then
    return
  end

  local layout = node.layout
  local props = node.props or {}
  draw_label(label, layout.left + 8, layout.top + 7, math.max(20, layout.width - 16), props.textColor)
end

local function hover_label(node)
  return node_label(node, true) or node.type or "node"
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

  if props.stroke ~= false then
    local line = node == hovered and palette.hover or palette.line
    set_color(line)
    love.graphics.setLineWidth(node == hovered and 3 or 1)
    love.graphics.rectangle("line", layout.left, layout.top, layout.width, layout.height, radius, radius)
  end

  draw_node_label(node)

  for _, child in ipairs(node.children or {}) do
    draw_node(child, depth + 1)
  end
end

local function draw_overlay()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  local title = mode == "menu" and "Select UI" or cases[current_case].name
  local hint = mode == "menu" and "Click, number, Up/Down, Enter" or "Esc to menu"
  local hover_text = ""

  if hovered then
    local layout = hovered.layout
    local name = hover_label(hovered)
    hover_text = string.format(
      "%s  x=%d y=%d w=%d h=%d",
      name,
      layout.left,
      layout.top,
      layout.width,
      layout.height
    )
  end

  local overlay = overlay_layout.build(layout_ctx, width, height, {
    title = title,
    hint = hint,
    hoverText = hover_text,
  })

  yoga.calculateLayout(overlay, width, height)
  draw_node(overlay, 0)
end

function love.load(args)
  configure_package_path()
  yoga = require("yoga")
  ui = require("ui")

  fonts.normal = love.graphics.newFont(14)
  fonts.small = love.graphics.newFont(12)
  love.graphics.setBackgroundColor(palette.background)

  load_cases()
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
  if mode == "menu" and (key == "right" or key == "down") then
    select_next(1)
  elseif mode == "menu" and (key == "left" or key == "up") then
    select_next(-1)
  elseif mode == "menu" and (key == "return" or key == "kpenter" or key == "space") then
    open_case(current_case)
  elseif mode == "menu" and tonumber(key) then
    local index = tonumber(key)
    open_case(index)
  elseif mode == "case" and key == "escape" then
    show_menu()
  elseif key == "r" then
    rebuild()
  end
end

function love.mousepressed(x, y, button)
  if mode ~= "menu" or button ~= 1 then
    return
  end

  local index = root and find_case_at(root, x, y)
  if index then
    open_case(index)
  end
end
