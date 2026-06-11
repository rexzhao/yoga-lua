local scroll = {}

local function number_or(value, fallback)
  local number = tonumber(value)
  if number == nil then
    return fallback
  end

  return number
end

local function clamp(value, min_value, max_value)
  if value < min_value then
    return min_value
  end

  if value > max_value then
    return max_value
  end

  return value
end

function scroll.normalizeAxis(axis)
  if axis == "x" or axis == "horizontal" then
    return "x"
  end

  return "y"
end

function scroll.applyContainerStyle(style, axis)
  style.overflow = style.overflow or "scroll"

  if style.flexDirection == nil then
    style.flexDirection = scroll.normalizeAxis(axis) == "x" and "row" or "column"
  end

  return style
end

function scroll.initialMetrics(props)
  props = props or {}
  local requested = number_or(props.scrollOffset, 0)

  return {
    type = "scrollView",
    axis = scroll.normalizeAxis(props.axis),
    requestedScrollOffset = requested,
    scrollOffset = math.max(0, requested),
    maxScroll = 0,
    contentWidth = 0,
    contentHeight = 0,
    viewportWidth = 0,
    viewportHeight = 0,
  }
end

function scroll.virtualMetrics(values)
  values = values or {}

  return {
    type = "virtualList",
    axis = "y",
    requestedScrollOffset = number_or(values.scrollOffset, 0),
    scrollOffset = number_or(values.scrollOffset, 0),
    maxScroll = number_or(values.maxScroll, 0),
    contentWidth = number_or(values.contentWidth, 0),
    contentHeight = number_or(values.contentHeight, 0),
    viewportWidth = number_or(values.viewportWidth, 0),
    viewportHeight = number_or(values.viewportHeight, 0),
  }
end

function scroll.contentSize(node)
  local content_width = 0
  local content_height = 0

  for _, child in ipairs(node.children or {}) do
    local layout = child.layout
    if layout then
      content_width = math.max(content_width, number_or(layout.left, 0) + number_or(layout.width, 0))
      content_height = math.max(content_height, number_or(layout.top, 0) + number_or(layout.height, 0))
    end
  end

  return math.max(0, content_width), math.max(0, content_height)
end

function scroll.updateNodeMetrics(node)
  local current = node and node.scroll
  if not current or (current.type ~= "scrollView" and node.type ~= "scrollView") then
    return current
  end

  local layout = node.layout or {}
  local viewport_width = math.max(0, number_or(layout.width, 0))
  local viewport_height = math.max(0, number_or(layout.height, 0))
  local content_width, content_height = scroll.contentSize(node)
  local axis = scroll.normalizeAxis(current.axis or (node.props and node.props.axis))
  local requested = current.requestedScrollOffset

  if requested == nil and node.props then
    requested = node.props.scrollOffset
  end

  requested = number_or(requested, 0)

  local scroll_extent = axis == "x" and content_width - viewport_width or content_height - viewport_height
  local max_scroll = math.max(0, scroll_extent)
  local metrics = {
    type = "scrollView",
    axis = axis,
    requestedScrollOffset = requested,
    scrollOffset = clamp(requested, 0, max_scroll),
    maxScroll = max_scroll,
    contentWidth = content_width,
    contentHeight = content_height,
    viewportWidth = viewport_width,
    viewportHeight = viewport_height,
  }

  node.scroll = metrics
  return metrics
end

function scroll.updateTree(node)
  if not node then
    return nil
  end

  local metrics = scroll.updateNodeMetrics(node)
  for _, child in ipairs(node.children or {}) do
    scroll.updateTree(child)
  end

  return metrics
end

function scroll.offset(metrics)
  if not metrics then
    return 0, 0
  end

  local offset = number_or(metrics.scrollOffset, 0)
  if scroll.normalizeAxis(metrics.axis) == "x" then
    return offset, 0
  end

  return 0, offset
end

function scroll.delta(scroll_state, delta, metrics)
  local current
  if type(scroll_state) == "table" then
    current = scroll_state.scrollOffset
  else
    current = scroll_state
  end

  local max_scroll = metrics and metrics.maxScroll or 0
  return clamp(number_or(current, 0) + number_or(delta, 0), 0, math.max(0, number_or(max_scroll, 0)))
end

return scroll
