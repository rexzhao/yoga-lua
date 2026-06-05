local yoga = {}

local function shallow_copy(source)
  local copy = {}
  if source then
    for key, value in pairs(source) do
      copy[key] = value
    end
  end
  return copy
end

local function normalize_children(children)
  if children == nil then
    return {}
  end

  return children
end

function yoga.node(style, children)
  return {
    style = shallow_copy(style),
    children = normalize_children(children),
    layout = {
      left = 0,
      top = 0,
      width = 0,
      height = 0,
    },
    dirty = true,
  }
end

local function number_or_zero(value)
  if type(value) == "number" then
    return value
  end

  return 0
end

local function resolve_edge(style, prefix, edge, axis)
  local edge_key = prefix .. edge:sub(1, 1):upper() .. edge:sub(2)
  local axis_key = prefix .. axis:sub(1, 1):upper() .. axis:sub(2)

  if type(style[edge_key]) == "number" then
    return style[edge_key]
  end

  if type(style[axis_key]) == "number" then
    return style[axis_key]
  end

  return number_or_zero(style[prefix])
end

local function resolve_edges(style, prefix)
  return {
    left = resolve_edge(style, prefix, "left", "horizontal"),
    right = resolve_edge(style, prefix, "right", "horizontal"),
    top = resolve_edge(style, prefix, "top", "vertical"),
    bottom = resolve_edge(style, prefix, "bottom", "vertical"),
  }
end

local function clamp_size(value)
  return math.max(0, number_or_zero(value))
end

local function layout_node(node, left, top, available_width, available_height)
  local style = node.style or {}
  local width = style.width or available_width
  local height = style.height or available_height

  node.layout.left = left
  node.layout.top = top
  node.layout.width = clamp_size(width)
  node.layout.height = clamp_size(height)
  node.dirty = false

  local padding = resolve_edges(style, "padding")
  local gap = number_or_zero(style.gap)
  local direction = style.flexDirection or "column"
  local cursor = 0
  local inner_width = clamp_size(node.layout.width - padding.left - padding.right)
  local inner_height = clamp_size(node.layout.height - padding.top - padding.bottom)

  for _, child in ipairs(node.children or {}) do
    local child_style = child.style or {}
    local margin = resolve_edges(child_style, "margin")
    local child_left = left + padding.left + margin.left
    local child_top = top + padding.top + margin.top

    if direction == "row" then
      child_left = child_left + cursor
      layout_node(
        child,
        child_left,
        child_top,
        child_style.width or 0,
        child_style.height or inner_height - margin.top - margin.bottom
      )
      cursor = cursor + margin.left + child.layout.width + margin.right + gap
    else
      child_top = child_top + cursor
      layout_node(
        child,
        child_left,
        child_top,
        child_style.width or inner_width - margin.left - margin.right,
        child_style.height or 0
      )
      cursor = cursor + margin.top + child.layout.height + margin.bottom + gap
    end
  end

  return node
end

function yoga.calculateLayout(root, width, height)
  return layout_node(root, 0, 0, width or 0, height or 0)
end

return yoga
