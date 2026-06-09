local yoga = require("yoga")

local ui = {}

local function is_array(value)
  if type(value) ~= "table" then
    return false
  end

  return value[1] ~= nil or next(value) == nil
end

local function class_names(class)
  if type(class) ~= "table" then
    return { class }
  end

  local indexes = {}
  for index in pairs(class) do
    if type(index) == "number" then
      indexes[#indexes + 1] = index
    end
  end
  table.sort(indexes)

  local names = {}
  for _, index in ipairs(indexes) do
    local class_name = class[index]
    if class_name then
      names[#names + 1] = class_name
    end
  end

  return names
end

local function merge_style(props)
  props = props or {}
  local style = {}
  local styles = props.styles
  local class = props.class

  if styles and class then
    for _, class_name in ipairs(class_names(class)) do
      local class_style = styles[class_name]
      if class_style then
        for key, value in pairs(class_style) do
          style[key] = value
        end
      end
    end
  end

  if props.style then
    for key, value in pairs(props.style) do
      style[key] = value
    end
  end

  return style
end

local function normalize_args(props, children)
  if type(props) == "string" then
    props = { class = props:sub(1, 1) == "." and props:sub(2) or props }
  elseif is_array(props) and children == nil then
    children = props
    props = {}
  else
    props = props or {}
  end

  return props, children or {}
end

local function attach_measure(node, props)
  if type(props.measure) == "function" then
    node.measure = props.measure
  end

  return node
end

function ui.stylesheet(definitions)
  return definitions or {}
end

function ui.createRuntime(options)
  return require("ui.runtime").create(options)
end

function ui.div(props, children)
  props, children = normalize_args(props, children)
  local node = yoga.node(merge_style(props), children)
  node.type = "div"
  node.props = props
  return attach_measure(node, props)
end

function ui.text(value, props)
  props = props or {}
  local node = yoga.node(merge_style(props), {})
  node.type = "text"
  node.text = value
  node.props = props
  return attach_measure(node, props)
end

function ui.image(props)
  props = props or {}
  local node = yoga.node(merge_style(props), {})
  node.type = "image"
  node.props = props
  return attach_measure(node, props)
end

function ui.button(label, props)
  props = props or {}
  local node = yoga.node(merge_style(props), {
    ui.text(label),
  })
  node.type = "button"
  node.label = label
  node.props = props
  return attach_measure(node, props)
end

function ui.virtualList(props)
  props = props or {}

  local item_count = math.max(0, math.floor(tonumber(props.itemCount) or 0))
  local item_height = math.max(0, tonumber(props.itemHeight) or 0)
  local viewport_height = math.max(0, tonumber(props.viewportHeight) or 0)
  local scroll_offset = math.max(0, tonumber(props.scrollOffset) or 0)
  local overscan = math.max(0, math.floor(tonumber(props.overscan) or 0))
  local render_item = props.renderItem
  local content_height = item_count * item_height
  local max_scroll = math.max(0, content_height - viewport_height)

  scroll_offset = math.min(scroll_offset, max_scroll)

  local visible_start = 1
  local visible_end = 0

  if item_count > 0 and item_height > 0 and viewport_height > 0 then
    visible_start = math.max(1, math.floor(scroll_offset / item_height) + 1 - overscan)
    visible_end = math.min(item_count, math.ceil((scroll_offset + viewport_height) / item_height) + overscan)
  end

  local top_height = (visible_start - 1) * item_height
  local bottom_height = math.max(0, content_height - top_height - (visible_end - visible_start + 1) * item_height)
  local children = {}

  children[#children + 1] = ui.div({
    role = "virtual-spacer",
    spacer = "top",
    style = { height = top_height },
  })

  if type(render_item) == "function" then
    for index = visible_start, visible_end do
      local item = render_item(index)
      if item then
        children[#children + 1] = item
      end
    end
  end

  children[#children + 1] = ui.div({
    role = "virtual-spacer",
    spacer = "bottom",
    style = { height = bottom_height },
  })

  local style = merge_style(props)
  style.height = style.height or viewport_height
  style.overflow = style.overflow or "scroll"
  style.flexDirection = style.flexDirection or "column"

  local node = yoga.node(style, children)
  node.type = "virtualList"
  node.props = props
  node.virtual = {
    itemCount = item_count,
    itemHeight = item_height,
    viewportHeight = viewport_height,
    scrollOffset = scroll_offset,
    maxScroll = max_scroll,
    visibleStart = visible_start,
    visibleEnd = visible_end,
    topSpacerHeight = top_height,
    bottomSpacerHeight = bottom_height,
  }

  return attach_measure(node, props)
end

return ui
