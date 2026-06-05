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

local function layout_node(node, left, top, available_width, available_height)
  local style = node.style or {}
  local width = style.width or available_width
  local height = style.height or available_height

  node.layout.left = left
  node.layout.top = top
  node.layout.width = number_or_zero(width)
  node.layout.height = number_or_zero(height)
  node.dirty = false

  local padding = number_or_zero(style.padding)
  local gap = number_or_zero(style.gap)
  local direction = style.flexDirection or "column"
  local cursor = 0

  for _, child in ipairs(node.children or {}) do
    local child_style = child.style or {}
    local child_left = left + padding
    local child_top = top + padding

    if direction == "row" then
      child_left = child_left + cursor
      layout_node(
        child,
        child_left,
        child_top,
        child_style.width or 0,
        child_style.height or node.layout.height - padding * 2
      )
      cursor = cursor + child.layout.width + gap
    else
      child_top = child_top + cursor
      layout_node(
        child,
        child_left,
        child_top,
        child_style.width or node.layout.width - padding * 2,
        child_style.height or 0
      )
      cursor = cursor + child.layout.height + gap
    end
  end

  return node
end

function yoga.calculateLayout(root, width, height)
  return layout_node(root, 0, 0, width or 0, height or 0)
end

return yoga

