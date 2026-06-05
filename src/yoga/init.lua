local yoga = {}

yoga.MEASURE_MODE_UNDEFINED = "undefined"
yoga.MEASURE_MODE_AT_MOST = "at-most"

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

local function is_display_none(node)
  return (node.style or {}).display == "none"
end

local function zero_layout_tree(node)
  node.layout.left = 0
  node.layout.top = 0
  node.layout.width = 0
  node.layout.height = 0
  node.dirty = false

  for _, child in ipairs(node.children or {}) do
    zero_layout_tree(child)
  end
end

function yoga.node(style, children)
  local node_style = shallow_copy(style)
  local measure = node_style.measure
  node_style.measure = nil

  return {
    style = node_style,
    children = normalize_children(children),
    layout = {
      left = 0,
      top = 0,
      width = 0,
      height = 0,
    },
    measure = measure,
    dirty = true,
  }
end

local function number_or_zero(value)
  if type(value) == "number" then
    return value
  end

  return 0
end

local function resolve_value(value, owner_size)
  if type(value) == "number" then
    return value
  end

  if type(value) == "string" then
    local percent = value:match("^%s*([+-]?%d+%.?%d*)%%%s*$")
    if percent and type(owner_size) == "number" then
      return owner_size * tonumber(percent) / 100
    end
  end

  return nil
end

local function resolve_edge(style, prefix, edge, axis, owner_size)
  local edge_key = prefix .. edge:sub(1, 1):upper() .. edge:sub(2)
  local axis_key = prefix .. axis:sub(1, 1):upper() .. axis:sub(2)

  local edge_value = resolve_value(style[edge_key], owner_size)
  if edge_value ~= nil then
    return edge_value
  end

  local axis_value = resolve_value(style[axis_key], owner_size)
  if axis_value ~= nil then
    return axis_value
  end

  return resolve_value(style[prefix], owner_size) or number_or_zero(style[prefix])
end

local function resolve_edges(style, prefix, owner_size)
  return {
    left = resolve_edge(style, prefix, "left", "horizontal", owner_size),
    right = resolve_edge(style, prefix, "right", "horizontal", owner_size),
    top = resolve_edge(style, prefix, "top", "vertical", owner_size),
    bottom = resolve_edge(style, prefix, "bottom", "vertical", owner_size),
  }
end

local function clamp_size(value, owner_size)
  return math.max(0, resolve_value(value, owner_size) or number_or_zero(value))
end

local function constrain_size(value, style, dimension, owner_size)
  value = clamp_size(value)

  local min_key = dimension == "width" and "minWidth" or "minHeight"
  local max_key = dimension == "width" and "maxWidth" or "maxHeight"
  local min_value = resolve_value(style[min_key], owner_size)
  local max_value = resolve_value(style[max_key], owner_size)

  if min_value ~= nil then
    value = math.max(value, min_value)
  end

  if max_value ~= nil then
    value = math.min(value, max_value)
  end

  return math.max(0, value)
end

local function flex_grow(style)
  return number_or_zero(style.flexGrow or style.flex)
end

local function measure_node(node, available_width, available_height)
  if type(node.measure) ~= "function" then
    return nil
  end

  local width_mode = type(available_width) == "number" and yoga.MEASURE_MODE_AT_MOST or yoga.MEASURE_MODE_UNDEFINED
  local height_mode = type(available_height) == "number" and yoga.MEASURE_MODE_AT_MOST or yoga.MEASURE_MODE_UNDEFINED
  local width, height = node.measure(available_width, width_mode, available_height, height_mode, node)

  if type(width) == "table" then
    return {
      width = width.width,
      height = width.height,
    }
  end

  return {
    width = width,
    height = height,
  }
end

local function main_size(style, direction, owner_size, measured)
  if direction == "row" then
    local width = resolve_value(style.width, owner_size) or number_or_zero(measured and measured.width)
    return constrain_size(width, style, "width", owner_size)
  end

  local height = resolve_value(style.height, owner_size) or number_or_zero(measured and measured.height)
  return constrain_size(height, style, "height", owner_size)
end

local function build_child_specs(children, direction, gap, inner_width, inner_height)
  local specs = {}
  local total_grow = 0
  local used_main = 0
  local visible_count = 0
  local available_main = direction == "row" and inner_width or inner_height

  for index, child in ipairs(children) do
    if is_display_none(child) then
      specs[index] = {
        hidden = true,
        grow = 0,
        main = 0,
      }
    else
      local style = child.style or {}
      local margin = resolve_edges(style, "margin", inner_width)
      local grow = flex_grow(style)
      local measured = measure_node(child, inner_width, inner_height)
      local base_main = main_size(style, direction, available_main, measured)

      specs[index] = {
        margin = margin,
        grow = grow,
        base_main = base_main,
        measured = measured,
      }

      if visible_count > 0 then
        used_main = used_main + gap
      end

      if direction == "row" then
        used_main = used_main + margin.left + base_main + margin.right
      else
        used_main = used_main + margin.top + base_main + margin.bottom
      end

      visible_count = visible_count + 1
      total_grow = total_grow + grow
    end
  end

  local remaining = math.max(0, available_main - used_main)

  for _, spec in ipairs(specs) do
    spec.main = spec.base_main
    if total_grow > 0 and spec.grow > 0 then
      spec.main = spec.main + remaining * spec.grow / total_grow
    end
  end

  return specs
end

local function used_main_size(specs, direction, gap)
  local used = 0
  local visible_count = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden then
      local margin = spec.margin

      if visible_count > 0 then
        used = used + gap
      end

      if direction == "row" then
        used = used + margin.left + spec.main + margin.right
      else
        used = used + margin.top + spec.main + margin.bottom
      end

      visible_count = visible_count + 1
    end
  end

  return used
end

local function visible_spec_count(specs)
  local count = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden then
      count = count + 1
    end
  end

  return count
end

local function justify_offsets(style, specs, direction, gap, inner_width, inner_height)
  local available_main = direction == "row" and inner_width or inner_height
  local remaining = math.max(0, available_main - used_main_size(specs, direction, gap))
  local justify = style.justifyContent or "flex-start"
  local visible_count = visible_spec_count(specs)
  local leading = 0
  local between = gap

  if justify == "center" then
    leading = remaining / 2
  elseif justify == "flex-end" then
    leading = remaining
  elseif justify == "space-between" and visible_count > 1 then
    between = gap + remaining / (visible_count - 1)
  elseif justify == "space-around" and visible_count > 0 then
    local space = remaining / visible_count
    leading = space / 2
    between = gap + space
  elseif justify == "space-evenly" and visible_count > 0 then
    local space = remaining / (visible_count + 1)
    leading = space
    between = gap + space
  end

  return leading, between
end

local function cross_axis_layout(parent_style, child_style, direction, margin, inner_width, inner_height, measured)
  local align = child_style.alignSelf or parent_style.alignItems or "stretch"
  local available
  local explicit
  local before
  local after
  local measured_size
  local dimension

  if direction == "row" then
    available = inner_height
    explicit = resolve_value(child_style.height, inner_height)
    before = margin.top
    after = margin.bottom
    measured_size = measured and measured.height
    dimension = "height"
  else
    available = inner_width
    explicit = resolve_value(child_style.width, inner_width)
    before = margin.left
    after = margin.right
    measured_size = measured and measured.width
    dimension = "width"
  end

  local size
  local available_without_margin = clamp_size(available - before - after)

  if explicit ~= nil then
    size = clamp_size(explicit)
  elseif align == "stretch" then
    size = available_without_margin
  else
    size = clamp_size(measured_size)
  end

  size = constrain_size(size, child_style, dimension, available)

  local remaining = clamp_size(available - before - size - after)
  local offset = before

  if align == "center" then
    offset = before + remaining / 2
  elseif align == "flex-end" then
    offset = before + remaining
  end

  return size, offset
end

local function layout_node(node, left, top, available_width, available_height, owner_width, owner_height, measured)
  if is_display_none(node) then
    zero_layout_tree(node)
    return node
  end

  local style = node.style or {}
  local measured_size = measured or measure_node(node, available_width, available_height)
  local width = resolve_value(style.width, owner_width) or available_width or (measured_size and measured_size.width)
  local height = resolve_value(style.height, owner_height) or available_height or (measured_size and measured_size.height)

  node.layout.left = left
  node.layout.top = top
  node.layout.width = constrain_size(width, style, "width", owner_width)
  node.layout.height = constrain_size(height, style, "height", owner_height)
  node.dirty = false

  local padding = resolve_edges(style, "padding", node.layout.width)
  local gap = number_or_zero(style.gap)
  local direction = style.flexDirection or "column"
  local cursor = 0
  local inner_width = clamp_size(node.layout.width - padding.left - padding.right)
  local inner_height = clamp_size(node.layout.height - padding.top - padding.bottom)
  local children = node.children or {}
  local specs = build_child_specs(children, direction, gap, inner_width, inner_height)
  local leading, between = justify_offsets(style, specs, direction, gap, inner_width, inner_height)

  for index, child in ipairs(children) do
    local child_style = child.style or {}
    local spec = specs[index]

    if spec.hidden then
      zero_layout_tree(child)
    else
      local margin = spec.margin
      local child_left = left + padding.left
      local child_top = top + padding.top

      if direction == "row" then
        local child_height, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured)
        child_left = child_left + leading + cursor + margin.left
        child_top = child_top + cross_offset
        layout_node(
          child,
          child_left,
          child_top,
          spec.main,
          child_height,
          inner_width,
          inner_height,
          spec.measured
        )
        cursor = cursor + margin.left + child.layout.width + margin.right + between
      else
        local child_width, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured)
        child_left = child_left + cross_offset
        child_top = child_top + leading + cursor + margin.top
        layout_node(
          child,
          child_left,
          child_top,
          child_width,
          spec.main,
          inner_width,
          inner_height,
          spec.measured
        )
        cursor = cursor + margin.top + child.layout.height + margin.bottom + between
      end
    end
  end

  return node
end

function yoga.calculateLayout(root, width, height)
  return layout_node(root, 0, 0, width, height, width, height)
end

return yoga
