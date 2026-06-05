local yoga
local ui

local unpack = table.unpack or unpack

local root
local current_case = 1
local mode = "menu"
local hovered
local hovered_rect
local menu_scroll = 0
local menu_scroll_max = 0
local screenshot_path
local screenshot_requested = false
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
  "layouts.axis_gap",
  "layouts.flex_basis",
  "layouts.flex_shrink",
  "layouts.flex_wrap",
  "layouts.align_content",
  "layouts.aspect_ratio",
  "layouts.justify",
  "layouts.align",
  "layouts.baseline",
  "layouts.percent",
  "layouts.measure",
  "layouts.minmax",
  "layouts.display",
  "layouts.absolute",
  "layouts.relative",
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
    measureText = function(text)
      local font = fonts.small
      return font:getWidth(text) + 16, font:getHeight() + 14
    end,
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
end

local function offset_children(node, dx, dy)
  for _, child in ipairs(node.children or {}) do
    offset_layout(child, dx, dy)
  end
end

local function clamp_menu_scroll()
  menu_scroll = math.max(0, math.min(menu_scroll, menu_scroll_max))
end

local function update_menu_scroll_limits()
  if mode ~= "menu" or not root then
    menu_scroll = 0
    menu_scroll_max = 0
    return
  end

  local content_bottom = 0
  for _, child in ipairs(root.children or {}) do
    content_bottom = math.max(content_bottom, child.layout.top + child.layout.height)
  end

  menu_scroll_max = math.max(0, content_bottom - root.layout.height)
  clamp_menu_scroll()
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

  if mode == "menu" then
    update_menu_scroll_limits()
    offset_children(root, 0, -menu_scroll)
  end
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

local function arg_value(args, flag)
  local sources = { args, _G.arg }

  for _, source in ipairs(sources) do
    if source then
      for index, value in ipairs(source) do
        if value == flag then
          return source[index + 1]
        end

        local inline = value:match("^" .. flag .. "=(.+)$")
        if inline then
          return inline
        end
      end
    end
  end

  return nil
end

local function case_key(value)
  return tostring(value or ""):lower():gsub("[%s_-]+", "")
end

local function find_case_index(value)
  local target = case_key(value)
  local number = tonumber(value)

  if number and cases[number] then
    return number
  end

  for index, case in ipairs(cases) do
    if case_key(case.id) == target or case_key(case.name) == target then
      return index
    end
  end

  return nil
end

local function apply_startup_args(args)
  local requested_case = arg_value(args, "--case") or arg_value(args, "--ui")
  screenshot_path = arg_value(args, "--screenshot")

  if not requested_case then
    return
  end

  local index = find_case_index(requested_case)
  if not index then
    error("unknown Love2D UI case: " .. tostring(requested_case))
  end

  current_case = index
  mode = "case"
end

local function save_screenshot(path, image_data)
  local file_data = image_data:encode("png")
  local file = assert(io.open(path, "wb"))
  file:write(file_data:getString())
  file:close()
  print("ok - love2d screenshot saved " .. path)
  love.event.quit(0)
end

local function absolute_rect(node, parent_left, parent_top)
  local layout = node.layout
  return (parent_left or 0) + layout.left, (parent_top or 0) + layout.top, layout.width, layout.height
end

local function point_in_rect(x, y, left, top, width, height)
  if width <= 0 or height <= 0 then
    return false
  end

  return x >= left and y >= top and x <= left + width and y <= top + height
end

local function find_deepest(node, x, y, parent_left, parent_top)
  local left, top, width, height = absolute_rect(node, parent_left, parent_top)
  local has_box = width > 0 and height > 0
  local hit = has_box and point_in_rect(x, y, left, top, width, height)

  if hit or not has_box then
    for index = #(node.children or {}), 1, -1 do
      local child, rect = find_deepest(node.children[index], x, y, left, top)
      if child then
        return child, rect
      end
    end
  end

  if hit then
    return node, { left = left, top = top, width = width, height = height }
  end

  return nil
end

local function find_case_at(node, x, y, parent_left, parent_top)
  local left, top, width, height = absolute_rect(node, parent_left, parent_top)
  local has_box = width > 0 and height > 0

  if has_box and not point_in_rect(x, y, left, top, width, height) then
    return nil
  end

  for index = #(node.children or {}), 1, -1 do
    local child_case = find_case_at(node.children[index], x, y, left, top)
    if child_case then
      return child_case
    end
  end

  local props = node.props or {}
  return props.caseIndex
end

local function selected_menu_node()
  if mode ~= "menu" or not root then
    return nil
  end

  for _, child in ipairs(root.children or {}) do
    local props = child.props or {}
    if props.caseIndex == current_case then
      return child
    end
  end

  return nil
end

local function ensure_current_case_visible()
  local selected = selected_menu_node()
  if not selected then
    return
  end

  local padding = 8
  local viewport_top = root.layout.top + padding
  local viewport_bottom = root.layout.top + root.layout.height - padding
  local item_top = root.layout.top + selected.layout.top
  local item_bottom = item_top + selected.layout.height
  local next_scroll = menu_scroll

  if item_top < viewport_top then
    next_scroll = menu_scroll - (viewport_top - item_top)
  elseif item_bottom > viewport_bottom then
    next_scroll = menu_scroll + (item_bottom - viewport_bottom)
  end

  next_scroll = math.max(0, math.min(next_scroll, menu_scroll_max))
  if next_scroll ~= menu_scroll then
    menu_scroll = next_scroll
    rebuild()
  end
end

local function select_next(delta)
  current_case = (current_case + delta - 1) % #cases + 1
  rebuild()
  ensure_current_case_visible()
end

local function jump_to_case(index)
  current_case = math.max(1, math.min(index, #cases))
  rebuild()
  ensure_current_case_visible()
end

local function scroll_menu(delta)
  if mode ~= "menu" then
    return
  end

  local next_scroll = math.max(0, math.min(menu_scroll + delta, menu_scroll_max))
  if next_scroll ~= menu_scroll then
    menu_scroll = next_scroll
    rebuild()
  end
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

local function draw_node_label(node, left, top)
  local label = node_label(node, false)
  if not label then
    return
  end

  local layout = node.layout
  local props = node.props or {}
  draw_label(label, left + 8, top + 7, math.max(20, layout.width - 16), props.textColor)
end

local function hover_label(node)
  return node_label(node, true) or node.type or "node"
end

local function draw_node(node, depth, parent_left, parent_top)
  local left, top, width, height = absolute_rect(node, parent_left, parent_top)
  local has_box = width > 0 and height > 0
  local props = node.props or {}

  if has_box then
    local fill = props.fill or palette.panel
    local radius = node.type == "text" and 0 or 6

    if fill[4] ~= 0 then
      set_color(fill)
      love.graphics.rectangle("fill", left, top, width, height, radius, radius)
    end

    if props.stroke ~= false then
      local line = node == hovered and palette.hover or palette.line
      set_color(line)
      love.graphics.setLineWidth(node == hovered and 3 or 1)
      love.graphics.rectangle("line", left, top, width, height, radius, radius)
    end

    draw_node_label(node, left, top)
  end

  local props_clip_children = has_box and props.clipChildren
  local previous_x, previous_y, previous_width, previous_height

  if props_clip_children then
    previous_x, previous_y, previous_width, previous_height = love.graphics.getScissor()
    love.graphics.setScissor(
      math.floor(left),
      math.floor(top),
      math.ceil(width),
      math.ceil(height)
    )
  end

  for _, child in ipairs(node.children or {}) do
    draw_node(child, depth + 1, left, top)
  end

  if props_clip_children then
    if previous_x then
      love.graphics.setScissor(previous_x, previous_y, previous_width, previous_height)
    else
      love.graphics.setScissor()
    end
  end
end

local function draw_overlay()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  local title = mode == "menu" and "Select UI" or cases[current_case].name
  local hint = mode == "menu" and "Wheel, click, Up/Down, Enter" or "Esc to menu"
  local hover_text = ""

  if hovered and hovered_rect then
    local name = hover_label(hovered)
    hover_text = string.format(
      "%s  x=%d y=%d w=%d h=%d",
      name,
      hovered_rect.left,
      hovered_rect.top,
      hovered_rect.width,
      hovered_rect.height
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
  apply_startup_args(args)
  rebuild()

  if has_flag(args, "--smoke") then
    print("ok - love2d visualizer loaded")
    love.event.quit(0)
  end
end

function love.update()
  local x, y = love.mouse.getPosition()
  if root then
    hovered, hovered_rect = find_deepest(root, x, y)
  else
    hovered = nil
    hovered_rect = nil
  end
end

function love.draw()
  if root then
    draw_node(root, 0)
  end

  draw_overlay()

  if screenshot_path and not screenshot_requested then
    screenshot_requested = true
    love.graphics.captureScreenshot(function(image_data)
      save_screenshot(screenshot_path, image_data)
    end)
  end
end

function love.resize()
  rebuild()
end

function love.keypressed(key)
  if mode == "menu" and (key == "right" or key == "down") then
    select_next(1)
  elseif mode == "menu" and (key == "left" or key == "up") then
    select_next(-1)
  elseif mode == "menu" and key == "pagedown" then
    scroll_menu(240)
  elseif mode == "menu" and key == "pageup" then
    scroll_menu(-240)
  elseif mode == "menu" and key == "home" then
    jump_to_case(1)
  elseif mode == "menu" and key == "end" then
    jump_to_case(#cases)
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

function love.wheelmoved(_, y)
  scroll_menu(-y * 64)
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
