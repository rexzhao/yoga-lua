local yoga
local ui

local unpack = table.unpack or unpack

local root
local root_instance
local overlay_instance
local content_runtime
local overlay_runtime
local layout_ctx
local current_case = 1
local hovered
local hovered_rect
local screenshot_path
local screenshot_requested = false
local fonts = {}
local images = {}
local debug_layout = false
local ui_asset_spec = { assets = {} }

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
  local active_ui = layout_ctx and layout_ctx.ui or ui
  return active_ui.div(props, children)
end

local function label(text, props)
  props = props or {}
  props.style = props.style or { height = 24 }
  props.debugName = props.debugName or text
  props.fill = props.fill or { 0, 0, 0, 0 }
  local active_ui = layout_ctx and layout_ctx.ui or ui
  return active_ui.text(text, props)
end

local layout_modules = {
  "layouts.rpg_game",
}

local cases = {}
local overlay_layout

local function layout_context(active_ui)
  return {
    ui = active_ui or ui,
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
  layout_ctx = layout_context(content_runtime:ui())
  overlay_layout = require("layouts.overlay")
  cases = {}

  for _, module_name in ipairs(layout_modules) do
    local layout = require(module_name)
    local state = layout.createState and layout.createState(layout_ctx) or nil
    cases[#cases + 1] = {
      id = layout.id,
      name = layout.name,
      state = state,
      build = function(width, height)
        return layout.build(layout_ctx, width, height, state)
      end,
      handleClick = layout.handleClick,
      keypressed = layout.keypressed,
      applyArgs = layout.applyArgs,
      hint = layout.hint,
    }
  end
end

local function offset_layout(node, dx, dy)
  node.layout.left = node.layout.left + dx
  node.layout.top = node.layout.top + dy
end

local function rebuild()
  local width, window_height = love.graphics.getDimensions()
  local layout_height = math.max(1, window_height - chrome.top - chrome.bottom)

  root_instance = content_runtime:render(cases[current_case].build(width, layout_height), width, layout_height)
  root = root_instance.yogaNode
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
  debug_layout = has_flag(args, "--debug-layout")
  local requested_screen = arg_value(args, "--screen")

  if requested_case then
    local index = find_case_index(requested_case)
    if not index then
      error("unknown Love2D UI case: " .. tostring(requested_case))
    end

    current_case = index
  end

  local case = cases[current_case]
  if case and case.applyArgs then
    case.applyArgs(case.state, {
      screen = requested_screen,
    })
  end
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

local function clips_children(node, has_box)
  if not has_box then
    return false
  end

  local props = node.props or {}
  local style = node.style or {}
  return props.clipChildren == true or style.overflow == "hidden" or style.overflow == "scroll"
end

local function find_deepest(node, x, y, parent_left, parent_top)
  local left, top, width, height = absolute_rect(node, parent_left, parent_top)
  local has_box = width > 0 and height > 0
  local hit = has_box and point_in_rect(x, y, left, top, width, height)
  local clipped = clips_children(node, has_box)

  if hit or not has_box or not clipped then
    local child_parent_top = top - ((node.virtual and node.virtual.scrollOffset) or 0)
    for index = #(node.children or {}), 1, -1 do
      local child, rect = find_deepest(node.children[index], x, y, left, child_parent_top)
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

local function set_color(color)
  love.graphics.setColor(color[1], color[2], color[3], color[4] or 1.0)
end

local function load_images()
  ui_asset_spec = require("ui_assets")

  for name, definition in pairs(ui_asset_spec.assets or {}) do
    local file = definition.file or name
    local path = "assets/ui/" .. file .. ".png"
    if not love.filesystem.getInfo(path) then
      error("missing Love2D UI asset: " .. path)
    end

    local image = love.graphics.newImage(path)
    local expected_size = definition.size
    if expected_size and (image:getWidth() ~= expected_size.width or image:getHeight() ~= expected_size.height) then
      error(string.format(
        "Love2D UI asset %s size mismatch: expected %dx%d, got %dx%d",
        path,
        expected_size.width,
        expected_size.height,
        image:getWidth(),
        image:getHeight()
      ))
    end

    local filter = definition.filter or "linear"
    image:setFilter(filter, filter)
    images[name] = {
      image = image,
      definition = definition,
    }
  end
end

local function edge_value(box, key)
  return (box and box[key]) or 0
end

local function fit_edges(total, before, after)
  if before + after <= total then
    return before, after, math.max(0, total - before - after)
  end

  if before + after <= 0 then
    return 0, 0, total
  end

  local scale = total / (before + after)
  return before * scale, after * scale, 0
end

local function draw_quad(image, sx, sy, sw, sh, dx, dy, dw, dh)
  if sw <= 0 or sh <= 0 or dw <= 0 or dh <= 0 then
    return
  end

  local quad = love.graphics.newQuad(sx, sy, sw, sh, image:getWidth(), image:getHeight())
  love.graphics.draw(image, quad, dx, dy, 0, dw / sw, dh / sh)
end

local function draw_nine_image(image, definition, left, top, width, height)
  local source_width = image:getWidth()
  local source_height = image:getHeight()
  local slice = definition.slice or {}
  local border = definition.border or slice
  local source_left = math.min(edge_value(slice, "left"), source_width)
  local source_right = math.min(edge_value(slice, "right"), source_width - source_left)
  local source_top = math.min(edge_value(slice, "top"), source_height)
  local source_bottom = math.min(edge_value(slice, "bottom"), source_height - source_top)
  local target_left, target_right, target_center_width =
    fit_edges(width, edge_value(border, "left"), edge_value(border, "right"))
  local target_top, target_bottom, target_center_height =
    fit_edges(height, edge_value(border, "top"), edge_value(border, "bottom"))

  local source_center_width = math.max(0, source_width - source_left - source_right)
  local source_center_height = math.max(0, source_height - source_top - source_bottom)
  local source_x = { 0, source_left, source_width - source_right }
  local source_y = { 0, source_top, source_height - source_bottom }
  local source_w = { source_left, source_center_width, source_right }
  local source_h = { source_top, source_center_height, source_bottom }
  local target_x = { left, left + target_left, left + width - target_right }
  local target_y = { top, top + target_top, top + height - target_bottom }
  local target_w = { target_left, target_center_width, target_right }
  local target_h = { target_top, target_center_height, target_bottom }

  for row = 1, 3 do
    for column = 1, 3 do
      draw_quad(
        image,
        source_x[column],
        source_y[row],
        source_w[column],
        source_h[row],
        target_x[column],
        target_y[row],
        target_w[column],
        target_h[row]
      )
    end
  end
end

local function draw_three_x_image(image, definition, left, top, width, height)
  local source_width = image:getWidth()
  local source_height = image:getHeight()
  local slice = definition.slice or {}
  local border = definition.border or slice
  local source_left = math.min(edge_value(slice, "left"), source_width)
  local source_right = math.min(edge_value(slice, "right"), source_width - source_left)
  local target_left, target_right, target_center_width =
    fit_edges(width, edge_value(border, "left"), edge_value(border, "right"))
  local source_center_width = math.max(0, source_width - source_left - source_right)

  draw_quad(image, 0, 0, source_left, source_height, left, top, target_left, height)
  draw_quad(
    image,
    source_left,
    0,
    source_center_width,
    source_height,
    left + target_left,
    top,
    target_center_width,
    height
  )
  draw_quad(
    image,
    source_width - source_right,
    0,
    source_right,
    source_height,
    left + width - target_right,
    top,
    target_right,
    height
  )
end

local function image_mode(name, fit)
  if fit then
    return fit
  end

  local entry = images[name]
  if entry and entry.definition then
    return entry.definition.mode
  end

  error("unknown Love2D UI asset: " .. tostring(name))
end

local function draw_image(name, left, top, width, height, tint, fit)
  local entry = images[name]
  if not entry then
    error("unknown Love2D UI asset: " .. tostring(name))
  end

  local image = entry.image
  local definition = entry.definition or {}
  local mode = image_mode(name, fit)

  set_color(tint or { 1, 1, 1, 1 })
  if mode == "contain" then
    local scale = math.min(width / image:getWidth(), height / image:getHeight())
    local draw_width = image:getWidth() * scale
    local draw_height = image:getHeight() * scale
    love.graphics.draw(image, left + (width - draw_width) / 2, top + (height - draw_height) / 2, 0, scale, scale)
  elseif mode == "cover" then
    local previous_x, previous_y, previous_width, previous_height = love.graphics.getScissor()
    local scale = math.max(width / image:getWidth(), height / image:getHeight())
    local draw_width = image:getWidth() * scale
    local draw_height = image:getHeight() * scale
    local clip_left = math.floor(left)
    local clip_top = math.floor(top)
    local clip_right = math.ceil(left + width)
    local clip_bottom = math.ceil(top + height)

    if previous_x then
      clip_left = math.max(clip_left, previous_x)
      clip_top = math.max(clip_top, previous_y)
      clip_right = math.min(clip_right, previous_x + previous_width)
      clip_bottom = math.min(clip_bottom, previous_y + previous_height)
    end

    love.graphics.setScissor(clip_left, clip_top, math.max(0, clip_right - clip_left), math.max(0, clip_bottom - clip_top))
    love.graphics.draw(image, left + (width - draw_width) / 2, top + (height - draw_height) / 2, 0, scale, scale)
    if previous_x then
      love.graphics.setScissor(previous_x, previous_y, previous_width, previous_height)
    else
      love.graphics.setScissor()
    end
  elseif mode == "nine" then
    draw_nine_image(image, definition, left, top, width, height)
  elseif mode == "threeX" then
    draw_three_x_image(image, definition, left, top, width, height)
  else
    love.graphics.draw(image, left, top, 0, width / image:getWidth(), height / image:getHeight())
  end
  return true
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

  if debug_layout and (include_containers or #(node.children or {}) == 0) then
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
  return node_label(node, true) or (node.props and node.props.debugName) or node.type or "node"
end

local function case_action_node(node)
  while node do
    if node.props and node.props.action then
      return node
    end

    node = node.parent
  end

  return nil
end

local function draw_node(node, depth, parent_left, parent_top)
  local left, top, width, height = absolute_rect(node, parent_left, parent_top)
  local has_box = width > 0 and height > 0
  local props = node.props or {}

  if has_box then
    local fill = props.fill or palette.panel
    local radius = node.type == "text" and 0 or 6
    local filled = false

    if props.image and image_mode(props.image, props.imageFit) == "contain" and fill[4] ~= 0 then
      set_color(fill)
      love.graphics.rectangle("fill", left, top, width, height, radius, radius)
      filled = true
    end

    local has_image = props.image and draw_image(props.image, left, top, width, height, props.tint, props.imageFit)

    if not has_image and not filled and fill[4] ~= 0 then
      set_color(fill)
      love.graphics.rectangle("fill", left, top, width, height, radius, radius)
    end

    if debug_layout and props.stroke ~= false then
      local line = node == hovered and palette.hover or palette.line
      set_color(line)
      love.graphics.setLineWidth(node == hovered and 3 or 1)
      love.graphics.rectangle("line", left, top, width, height, radius, radius)
    end

    draw_node_label(node, left, top)
  end

  local props_clip_children = clips_children(node, has_box)
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

  local child_parent_top = top - ((node.virtual and node.virtual.scrollOffset) or 0)

  for _, child in ipairs(node.children or {}) do
    draw_node(child, depth + 1, left, child_parent_top)
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
  local case = cases[current_case]
  local title = case.name
  local hint = "C K I Q M H switch panels"
  local hover_text = ""

  if case.hint then
    hint = case.hint(case.state)
  end

  if debug_layout and hovered and hovered_rect then
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

  overlay_instance = overlay_runtime:render(overlay, width, height)
  draw_node(overlay_instance.yogaNode, 0)
end

function love.load(args)
  configure_package_path()
  yoga = require("yoga")
  ui = require("ui")
  content_runtime = ui.createRuntime()
  overlay_runtime = ui.createRuntime()

  fonts.normal = love.graphics.newFont(14)
  fonts.small = love.graphics.newFont(12)
  load_images()
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
  local case = cases[current_case]

  if case and case.keypressed and case.keypressed(case.state, key) then
    rebuild()
  elseif key == "escape" then
    rebuild()
  elseif key == "r" then
    rebuild()
  end
end

function love.mousepressed(x, y, button)
  if button ~= 1 then
    return
  end

  local case = cases[current_case]
  local node = root and find_deepest(root, x, y)
  local action_node = case_action_node(node)

  if case and case.handleClick and action_node and case.handleClick(case.state, action_node.props, action_node) then
    rebuild()
  end
end
