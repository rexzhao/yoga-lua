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

local function is_display_contents(node)
  return (node.style or {}).display == "contents"
end

local function is_absolute_position(node)
  return (node.style or {}).position == "absolute"
end

local function is_row_direction(direction)
  return direction == "row" or direction == "row-reverse"
end

local function normalize_layout_direction(direction)
  if direction == "rtl" or direction == "RTL" then
    return "rtl"
  end

  return "ltr"
end

local function is_rtl(layout_direction)
  return normalize_layout_direction(layout_direction) == "rtl"
end

local function is_main_axis_reversed(direction, layout_direction)
  if direction == "row" then
    return is_rtl(layout_direction)
  end

  if direction == "row-reverse" then
    return not is_rtl(layout_direction)
  end

  return direction == "column-reverse"
end

local function zero_layout_box(node)
  node.layout.left = 0
  node.layout.top = 0
  node.layout.width = 0
  node.layout.height = 0
  node.dirty = false
end

local function zero_layout_tree(node)
  zero_layout_box(node)

  for _, child in ipairs(node.children or {}) do
    zero_layout_tree(child)
  end
end

local function collect_layout_items(children, out)
  out = out or {}

  for _, child in ipairs(children or {}) do
    if is_display_contents(child) then
      zero_layout_box(child)
      collect_layout_items(child.children, out)
    else
      out[#out + 1] = child
    end
  end

  return out
end

local function offset_layout_box(node, dx, dy)
  node.layout.left = node.layout.left + dx
  node.layout.top = node.layout.top + dy
end

local function round_to_pixel_grid(value)
  local rounded

  if value >= 0 then
    rounded = math.floor(value + 0.5)
  else
    rounded = math.ceil(value - 0.5)
  end

  if rounded == 0 then
    return 0
  end

  return rounded
end

local function round_layout_tree(node, absolute_left, absolute_top)
  absolute_left = absolute_left or 0
  absolute_top = absolute_top or 0

  local raw_left = node.layout.left
  local raw_top = node.layout.top
  local raw_width = node.layout.width
  local raw_height = node.layout.height
  local node_absolute_left = absolute_left + raw_left
  local node_absolute_top = absolute_top + raw_top
  local rounded_left = round_to_pixel_grid(node_absolute_left)
  local rounded_top = round_to_pixel_grid(node_absolute_top)
  local rounded_right = round_to_pixel_grid(node_absolute_left + raw_width)
  local rounded_bottom = round_to_pixel_grid(node_absolute_top + raw_height)

  node.layout.left = round_to_pixel_grid(raw_left)
  node.layout.top = round_to_pixel_grid(raw_top)
  node.layout.width = math.max(0, rounded_right - rounded_left)
  node.layout.height = math.max(0, rounded_bottom - rounded_top)

  for _, child in ipairs(node.children or {}) do
    round_layout_tree(child, node_absolute_left, node_absolute_top)
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

local function relative_axis_offset(style, start_key, end_key, owner_size)
  local start = resolve_value(style[start_key], owner_size)
  if start ~= nil then
    return start
  end

  local ending = resolve_value(style[end_key], owner_size)
  if ending ~= nil then
    return -ending
  end

  return 0
end

local function logical_horizontal_edge(edge, layout_direction)
  if edge == "left" then
    return is_rtl(layout_direction) and "End" or "Start"
  end

  return is_rtl(layout_direction) and "Start" or "End"
end

local function resolve_horizontal_position_offsets(style, owner_size, layout_direction)
  local left = resolve_value(style.left, owner_size)
  local right = resolve_value(style.right, owner_size)

  if left == nil and right == nil then
    local start = resolve_value(style.start, owner_size)
    local ending = resolve_value(style["end"], owner_size)

    if is_rtl(layout_direction) then
      left = ending
      right = start
    else
      left = start
      right = ending
    end
  end

  return left, right
end

local function horizontal_relative_offset(style, owner_size, layout_direction)
  local left, right = resolve_horizontal_position_offsets(style, owner_size, layout_direction)

  if left ~= nil then
    return left
  end

  if right ~= nil then
    return -right
  end

  return 0
end

local function relative_offsets(style, owner_width, owner_height, layout_direction)
  return horizontal_relative_offset(style, owner_width, layout_direction),
    relative_axis_offset(style, "top", "bottom", owner_height)
end

local function resolve_edge(style, prefix, edge, axis, owner_size, layout_direction)
  local edge_key = prefix .. edge:sub(1, 1):upper() .. edge:sub(2)
  local axis_key = prefix .. axis:sub(1, 1):upper() .. axis:sub(2)

  local edge_value = resolve_value(style[edge_key], owner_size)
  if edge_value ~= nil then
    return edge_value
  end

  if edge == "left" or edge == "right" then
    local logical_key = prefix .. logical_horizontal_edge(edge, layout_direction)
    local logical_value = resolve_value(style[logical_key], owner_size)
    if logical_value ~= nil then
      return logical_value
    end
  end

  local axis_value = resolve_value(style[axis_key], owner_size)
  if axis_value ~= nil then
    return axis_value
  end

  return resolve_value(style[prefix], owner_size) or number_or_zero(style[prefix])
end

local function resolve_edges(style, prefix, owner_size, layout_direction)
  return {
    left = resolve_edge(style, prefix, "left", "horizontal", owner_size, layout_direction),
    right = resolve_edge(style, prefix, "right", "horizontal", owner_size, layout_direction),
    top = resolve_edge(style, prefix, "top", "vertical", owner_size, layout_direction),
    bottom = resolve_edge(style, prefix, "bottom", "vertical", owner_size, layout_direction),
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

local function flex_shrink(style)
  return number_or_zero(style.flexShrink)
end

local function aspect_ratio(style)
  if type(style.aspectRatio) == "number" and style.aspectRatio > 0 then
    return style.aspectRatio
  end

  return nil
end

local function main_axis_gap(style, direction)
  if is_row_direction(direction) then
    return number_or_zero(style.columnGap or style.gap)
  end

  return number_or_zero(style.rowGap or style.gap)
end

local function cross_axis_gap(style, direction)
  if is_row_direction(direction) then
    return number_or_zero(style.rowGap or style.gap)
  end

  return number_or_zero(style.columnGap or style.gap)
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

local function main_size(style, direction, owner_size, cross_owner_size, measured)
  local ratio = aspect_ratio(style)

  if is_row_direction(direction) then
    local basis = resolve_value(style.flexBasis, owner_size)
    if basis ~= nil then
      return constrain_size(basis, style, "width", owner_size)
    end

    local width = resolve_value(style.width, owner_size)
    if width == nil and ratio then
      local height = resolve_value(style.height, cross_owner_size) or (measured and measured.height)
      if height ~= nil then
        width = height * ratio
      end
    end

    width = width or number_or_zero(measured and measured.width)
    return constrain_size(width, style, "width", owner_size)
  end

  local basis = resolve_value(style.flexBasis, owner_size)
  if basis ~= nil then
    return constrain_size(basis, style, "height", owner_size)
  end

  local height = resolve_value(style.height, owner_size)
  if height == nil and ratio then
    local width = resolve_value(style.width, cross_owner_size) or (measured and measured.width)
    if width ~= nil then
      height = width / ratio
    end
  end

  height = height or number_or_zero(measured and measured.height)
  return constrain_size(height, style, "height", owner_size)
end

local function has_auto_main_size(style, direction, owner_size, cross_owner_size, measured)
  if resolve_value(style.flexBasis, owner_size) ~= nil then
    return false
  end

  local ratio = aspect_ratio(style)

  if is_row_direction(direction) then
    if resolve_value(style.width, owner_size) ~= nil or (measured and measured.width) ~= nil then
      return false
    end

    return not (ratio and resolve_value(style.height, cross_owner_size) ~= nil)
  end

  if resolve_value(style.height, owner_size) ~= nil or (measured and measured.height) ~= nil then
    return false
  end

  return not (ratio and resolve_value(style.width, cross_owner_size) ~= nil)
end

local function has_auto_cross_size(style, direction, cross_owner_size, measured)
  local ratio = aspect_ratio(style)

  if is_row_direction(direction) then
    return resolve_value(style.height, cross_owner_size) == nil
      and not (measured and measured.height)
      and not ratio
  end

  return resolve_value(style.width, cross_owner_size) == nil
    and not (measured and measured.width)
    and not ratio
end

local function build_child_specs(children, direction, gap, inner_width, inner_height, layout_direction)
  local specs = {}
  local total_grow = 0
  local used_main = 0
  local visible_count = 0
  local available_main = is_row_direction(direction) and inner_width or inner_height

  for index, child in ipairs(children) do
    if is_display_none(child) then
      specs[index] = {
        hidden = true,
        grow = 0,
        base_main = 0,
        main = 0,
      }
    elseif is_absolute_position(child) then
      specs[index] = {
        absolute = true,
        grow = 0,
        main = 0,
        base_main = 0,
      }
    else
      local style = child.style or {}
      local margin = resolve_edges(style, "margin", inner_width, layout_direction)
      local grow = flex_grow(style)
      local shrink = flex_shrink(style)
      local measured = measure_node(child, inner_width, inner_height)
      local available_cross = is_row_direction(direction) and inner_height or inner_width
      local base_main = main_size(style, direction, available_main, available_cross, measured)

      specs[index] = {
        child = child,
        style = style,
        margin = margin,
        grow = grow,
        shrink = shrink,
        base_main = base_main,
        auto_main = has_auto_main_size(style, direction, available_main, available_cross, measured),
        auto_cross = has_auto_cross_size(style, direction, available_cross, measured),
        measured = measured,
      }

      if visible_count > 0 then
        used_main = used_main + gap
      end

      if is_row_direction(direction) then
        used_main = used_main + margin.left + base_main + margin.right
      else
        used_main = used_main + margin.top + base_main + margin.bottom
      end

      visible_count = visible_count + 1
      total_grow = total_grow + grow
    end
  end

  local remaining = available_main - used_main
  local grow_factor = math.max(total_grow, 1)

  for _, spec in ipairs(specs) do
    spec.main = spec.base_main
    if remaining > 0 and total_grow > 0 and spec.grow > 0 then
      spec.main = spec.main + remaining * spec.grow / grow_factor
    end
  end

  if remaining < 0 then
    local total_scaled_shrink = 0
    local dimension = is_row_direction(direction) and "width" or "height"

    for _, spec in ipairs(specs) do
      if not spec.hidden and not spec.absolute and spec.shrink > 0 then
        spec.scaled_shrink = spec.shrink * spec.base_main
        total_scaled_shrink = total_scaled_shrink + spec.scaled_shrink
      end
    end

    if total_scaled_shrink > 0 then
      local deficit = -remaining

      for _, spec in ipairs(specs) do
        if not spec.hidden and not spec.absolute and spec.scaled_shrink and spec.scaled_shrink > 0 then
          local shrink_amount = deficit * spec.scaled_shrink / total_scaled_shrink
          spec.main = constrain_size(spec.base_main - shrink_amount, spec.style, dimension, available_main)
        end
      end
    end
  end

  return specs
end

local function used_main_size(specs, direction, gap)
  local used = 0
  local visible_count = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute then
      local margin = spec.margin

      if visible_count > 0 then
        used = used + gap
      end

      if is_row_direction(direction) then
        used = used + margin.left + spec.main + margin.right
      else
        used = used + margin.top + spec.main + margin.bottom
      end

      visible_count = visible_count + 1
    end
  end

  return used
end

local function child_main_extent(specs, direction, gap, padding, border)
  local main = used_main_size(specs, direction, gap)

  if is_row_direction(direction) then
    return border.left + padding.left + main + padding.right + border.right
  end

  return border.top + padding.top + main + padding.bottom + border.bottom
end

local function node_baseline(node)
  for _, child in ipairs(node.children or {}) do
    if not is_display_none(child) then
      return child.layout.top + node_baseline(child)
    end
  end

  return node.layout.height
end

local function baseline_align_children(parent_style, specs, direction)
  if not is_row_direction(direction) then
    return
  end

  local max_baseline

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute then
      local align = spec.style.alignSelf or parent_style.alignItems or "stretch"
      if align == "baseline" then
        local baseline = node_baseline(spec.child)
        max_baseline = math.max(max_baseline or baseline, baseline)
        spec.baseline = baseline
      end
    end
  end

  if not max_baseline then
    return
  end

  for _, spec in ipairs(specs) do
    if spec.baseline then
      offset_layout_box(spec.child, 0, max_baseline - spec.baseline)
    end
  end
end

local function visible_spec_count(specs)
  local count = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute then
      count = count + 1
    end
  end

  return count
end

local function justify_offsets(style, specs, direction, gap, inner_width, inner_height)
  local available_main = is_row_direction(direction) and inner_width or inner_height
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

local function cross_axis_layout(parent_style, child_style, direction, margin, inner_width, inner_height, measured, main, layout_direction)
  local align = child_style.alignSelf or parent_style.alignItems or "stretch"
  local available
  local explicit
  local before
  local after
  local measured_size
  local dimension

  if is_row_direction(direction) then
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
  local ratio = aspect_ratio(child_style)

  if explicit ~= nil then
    size = clamp_size(explicit)
  elseif ratio and type(main) == "number" then
    if is_row_direction(direction) then
      size = clamp_size(main / ratio)
    else
      size = clamp_size(main * ratio)
    end
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

  if not is_row_direction(direction) and is_rtl(layout_direction) then
    offset = available - offset - size
  end

  return size, offset
end

local layout_node

local function main_axis_offset(style, available, size)
  local justify = style.justifyContent or "flex-start"
  local remaining = clamp_size(available - size)

  if justify == "center" then
    return remaining / 2
  elseif justify == "flex-end" then
    return remaining
  end

  return 0
end

local function cross_axis_offset(parent_style, child_style, available, size)
  local align = child_style.alignSelf or parent_style.alignItems or "stretch"
  local remaining = clamp_size(available - size)

  if align == "center" then
    return remaining / 2
  elseif align == "flex-end" then
    return remaining
  end

  return 0
end

local function absolute_axis_size(style, dimension, owner_size, start_offset, end_offset, measured_size, start_margin, end_margin)
  local explicit = dimension == "width" and resolve_value(style.width, owner_size) or resolve_value(style.height, owner_size)
  start_margin = start_margin or 0
  end_margin = end_margin or 0

  if explicit ~= nil then
    return constrain_size(explicit, style, dimension, owner_size)
  end

  if start_offset ~= nil and end_offset ~= nil then
    return constrain_size(owner_size - start_offset - end_offset - start_margin - end_margin, style, dimension, owner_size)
  end

  if measured_size ~= nil then
    return constrain_size(measured_size, style, dimension, owner_size)
  end

  return nil
end

local function absolute_default_offset(parent_style, child_style, direction, axis, available, size, layout_direction)
  local offset
  local is_cross_axis
  local is_main_axis

  if axis == "horizontal" then
    if is_row_direction(direction) then
      offset = main_axis_offset(parent_style, available, size)
      is_cross_axis = false
      is_main_axis = true
    else
      offset = cross_axis_offset(parent_style, child_style, available, size)
      is_cross_axis = true
      is_main_axis = false
    end
  elseif is_row_direction(direction) then
    offset = cross_axis_offset(parent_style, child_style, available, size)
    is_cross_axis = true
    is_main_axis = false
  else
    offset = main_axis_offset(parent_style, available, size)
    is_cross_axis = false
    is_main_axis = true
  end

  local should_reverse = is_main_axis and is_main_axis_reversed(direction, layout_direction)
    or is_cross_axis and axis == "horizontal" and is_rtl(layout_direction)

  if is_cross_axis and parent_style.flexWrap == "wrap-reverse" then
    should_reverse = not should_reverse
  end

  if should_reverse then
    return available - offset - size
  end

  return offset
end

local function absolute_axis_position(
  parent_style,
  child_style,
  direction,
  axis,
  explicit_origin,
  default_origin,
  explicit_available,
  default_available,
  size,
  start_offset,
  end_offset,
  start_margin,
  end_margin,
  layout_direction
)
  start_margin = start_margin or 0
  end_margin = end_margin or 0

  if start_offset ~= nil then
    return explicit_origin + start_offset + start_margin
  end

  if end_offset ~= nil then
    return explicit_origin + explicit_available - end_offset - end_margin - (size or 0)
  end

  local available_without_margin = clamp_size(default_available - start_margin - end_margin)
  return default_origin
    + start_margin
    + absolute_default_offset(parent_style, child_style, direction, axis, available_without_margin, size or 0, layout_direction)
end

local function layout_absolute_node(child, parent_style, padding, border, parent_width, parent_height, inner_width, inner_height, layout_direction)
  local style = child.style or {}
  local measured = measure_node(child, inner_width, inner_height)
  local margin = resolve_edges(style, "margin", inner_width, layout_direction)
  local left_offset, right_offset = resolve_horizontal_position_offsets(style, inner_width, layout_direction)
  local top_offset = resolve_value(style.top, inner_height)
  local bottom_offset = resolve_value(style.bottom, inner_height)
  local explicit_width_available = clamp_size(parent_width - border.left - border.right)
  local explicit_height_available = clamp_size(parent_height - border.top - border.bottom)
  local width = absolute_axis_size(
    style,
    "width",
    explicit_width_available,
    left_offset,
    right_offset,
    measured and measured.width,
    margin.left,
    margin.right
  )
  local height = absolute_axis_size(
    style,
    "height",
    explicit_height_available,
    top_offset,
    bottom_offset,
    measured and measured.height,
    margin.top,
    margin.bottom
  )
  local direction = parent_style.flexDirection or "column"
  local explicit_origin_left = border.left
  local explicit_origin_top = border.top
  local default_origin_left = border.left + padding.left
  local default_origin_top = border.top + padding.top
  local child_left = absolute_axis_position(
    parent_style,
    style,
    direction,
    "horizontal",
    explicit_origin_left,
    default_origin_left,
    explicit_width_available,
    inner_width,
    width,
    left_offset,
    right_offset,
    margin.left,
    margin.right,
    layout_direction
  )
  local child_top = absolute_axis_position(
    parent_style,
    style,
    direction,
    "vertical",
    explicit_origin_top,
    default_origin_top,
    explicit_height_available,
    inner_height,
    height,
    top_offset,
    bottom_offset,
    margin.top,
    margin.bottom,
    layout_direction
  )

  layout_node(child, child_left, child_top, width, height, inner_width, inner_height, measured, {
    useAvailableWidth = width ~= nil,
    useAvailableHeight = height ~= nil,
  }, layout_direction)
end

local function main_outer_size(spec, direction)
  local margin = spec.margin

  if is_row_direction(direction) then
    return margin.left + spec.base_main + margin.right
  end

  return margin.top + spec.base_main + margin.bottom
end

local function spec_main_size(spec, direction)
  local margin = spec.margin

  if is_row_direction(direction) then
    return margin.left + spec.main + margin.right
  end

  return margin.top + spec.main + margin.bottom
end

local function distribute_line_main(line, direction, gap, available_main)
  local used_main = 0
  local total_grow = 0

  for index, spec in ipairs(line.items) do
    spec.main = spec.base_main

    if index > 1 then
      used_main = used_main + gap
    end

    used_main = used_main + spec_main_size(spec, direction)
    total_grow = total_grow + spec.grow
  end

  local remaining = available_main - used_main

  if remaining > 0 and total_grow > 0 then
    local grow_factor = math.max(total_grow, 1)

    for _, spec in ipairs(line.items) do
      if spec.grow > 0 then
        spec.main = spec.main + remaining * spec.grow / grow_factor
      end
    end

    return
  end

  if remaining >= 0 then
    return
  end

  local total_scaled_shrink = 0
  local dimension = is_row_direction(direction) and "width" or "height"

  for _, spec in ipairs(line.items) do
    if spec.shrink > 0 then
      spec.scaled_shrink = spec.shrink * spec.base_main
      total_scaled_shrink = total_scaled_shrink + spec.scaled_shrink
    end
  end

  if total_scaled_shrink <= 0 then
    return
  end

  local deficit = -remaining

  for _, spec in ipairs(line.items) do
    if spec.scaled_shrink and spec.scaled_shrink > 0 then
      local shrink_amount = deficit * spec.scaled_shrink / total_scaled_shrink
      spec.main = constrain_size(spec.base_main - shrink_amount, spec.style, dimension, available_main)
    end
  end
end

local function cross_axis_size_in_line(child_style, direction, measured, main, owner_size)
  local ratio = aspect_ratio(child_style)
  local dimension

  if is_row_direction(direction) then
    dimension = "height"
    local explicit = resolve_value(child_style.height)
    if explicit ~= nil then
      return constrain_size(explicit, child_style, dimension, owner_size)
    end

    if ratio and type(main) == "number" then
      return constrain_size(main / ratio, child_style, dimension, owner_size)
    end

    return constrain_size(measured and measured.height, child_style, dimension, owner_size)
  end

  dimension = "width"
  local explicit = resolve_value(child_style.width)
  if explicit ~= nil then
    return constrain_size(explicit, child_style, dimension, owner_size)
  end

  if ratio and type(main) == "number" then
    return constrain_size(main * ratio, child_style, dimension, owner_size)
  end

  return constrain_size(measured and measured.width, child_style, dimension, owner_size)
end

local function needs_auto_cross_measure(child_style, direction, measured)
  if aspect_ratio(child_style) then
    return false
  end

  if is_row_direction(direction) then
    return resolve_value(child_style.height) == nil and not (measured and measured.height)
  end

  return resolve_value(child_style.width) == nil and not (measured and measured.width)
end

local function auto_cross_size_from_child(spec, direction, owner_width, owner_height)
  if not needs_auto_cross_measure(spec.style, direction, spec.measured) then
    return nil
  end

  if #(spec.child.children or {}) == 0 then
    return nil
  end

  if is_row_direction(direction) then
    layout_node(spec.child, 0, 0, spec.main, nil, owner_width, owner_height, spec.measured, {
      useAvailableWidth = true,
    })
    return spec.child.layout.height
  end

  layout_node(spec.child, 0, 0, nil, spec.main, owner_width, owner_height, spec.measured, {
    useAvailableHeight = true,
  })
  return spec.child.layout.width
end

local function line_cross_size(line, direction, owner_width, owner_height)
  local cross = 0

  for _, spec in ipairs(line.items) do
    local margin = spec.margin
    local owner_size = is_row_direction(direction) and owner_height or owner_width
    local size = auto_cross_size_from_child(spec, direction, owner_width, owner_height)
      or cross_axis_size_in_line(spec.style, direction, spec.measured, spec.main, owner_size)

    if is_row_direction(direction) then
      cross = math.max(cross, margin.top + size + margin.bottom)
    else
      cross = math.max(cross, margin.left + size + margin.right)
    end
  end

  return cross
end

local function child_cross_extent(specs, direction, padding, border)
  local cross = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute then
      local margin = spec.margin
      local child = spec.child

      if is_row_direction(direction) then
        cross = math.max(cross, margin.top + child.layout.height + margin.bottom)
      else
        cross = math.max(cross, margin.left + child.layout.width + margin.right)
      end
    end
  end

  if is_row_direction(direction) then
    return border.top + padding.top + cross + padding.bottom + border.bottom
  end

  return border.left + padding.left + cross + padding.right + border.right
end

local function relayout_stretched_auto_cross_children(node, specs, direction, padding, border, layout_direction)
  local style = node.style or {}
  local inner_width = clamp_size(node.layout.width - border.left - padding.left - padding.right - border.right)
  local inner_height = clamp_size(node.layout.height - border.top - padding.top - padding.bottom - border.bottom)

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute and spec.auto_cross then
      local child_style = spec.style
      local align = child_style.alignSelf or style.alignItems or "stretch"

      if align == "stretch" then
        local child = spec.child
        local margin = spec.margin

        if is_row_direction(direction) then
          local height = constrain_size(
            clamp_size(inner_height - margin.top - margin.bottom),
            child_style,
            "height",
            inner_height
          )
          layout_node(
            child,
            child.layout.left,
            child.layout.top,
            child.layout.width,
            height,
            inner_width,
            inner_height,
            spec.measured,
            { useAvailableWidth = true },
            layout_direction
          )
        else
          local width = constrain_size(
            clamp_size(inner_width - margin.left - margin.right),
            child_style,
            "width",
            inner_width
          )
          layout_node(
            child,
            child.layout.left,
            child.layout.top,
            width,
            child.layout.height,
            inner_width,
            inner_height,
            spec.measured,
            { useAvailableHeight = true },
            layout_direction
          )
        end
      end
    end
  end
end

local function used_line_cross_size(lines, gap)
  local used = 0

  for index, line in ipairs(lines) do
    if index > 1 then
      used = used + gap
    end

    used = used + line.cross
  end

  return used
end

local function align_content_offsets(style, lines, gap, available_cross, auto_cross_size)
  local raw_remaining = auto_cross_size and 0 or available_cross - used_line_cross_size(lines, gap)
  local remaining = math.max(0, raw_remaining)
  local align = style.alignContent or "flex-start"
  local leading = 0
  local between = gap
  local line_count = #lines

  if align == "center" then
    leading = raw_remaining / 2
  elseif align == "flex-end" then
    leading = raw_remaining
  elseif align == "space-between" and line_count > 1 then
    between = gap + remaining / (line_count - 1)
  elseif align == "space-around" and line_count > 0 then
    local space = remaining / line_count
    leading = space / 2
    between = gap + space
  elseif align == "space-evenly" and line_count > 0 then
    local space = remaining / (line_count + 1)
    leading = space
    between = gap + space
  elseif align == "stretch" and line_count > 0 and remaining > 0 then
    local extra = remaining / line_count

    for _, line in ipairs(lines) do
      line.cross = line.cross + extra
    end
  end

  return leading, between
end

local function cross_axis_layout_in_line(parent_style, child_style, direction, margin, line_cross, measured, main, layout_direction)
  return cross_axis_layout(parent_style, child_style, direction, margin, line_cross, line_cross, measured, main, layout_direction)
end

local function layout_wrapped_children(
  node,
  padding,
  border,
  inner_width,
  inner_height,
  owner_width,
  owner_height,
  auto_main_size,
  auto_cross_size,
  layout_direction
)
  local style = node.style or {}
  local direction = style.flexDirection or "column"
  local wrap_reverse = style.flexWrap == "wrap-reverse"
  local gap = main_axis_gap(style, direction)
  local line_gap = cross_axis_gap(style, direction)
  local available_main = is_row_direction(direction) and inner_width or inner_height
  local available_cross = is_row_direction(direction) and inner_height or inner_width
  local lines = {}
  local current_line = { items = {}, used_main = 0 }
  local specs = {}

  local function push_line()
    if #current_line.items > 0 then
      lines[#lines + 1] = current_line
      current_line = { items = {}, used_main = 0 }
    end
  end

  local children = collect_layout_items(node.children)

  for index, child in ipairs(children) do
    if is_display_none(child) then
      specs[index] = { hidden = true }
    elseif is_absolute_position(child) then
      specs[index] = { absolute = true, child = child }
    else
      local child_style = child.style or {}
      local margin = resolve_edges(child_style, "margin", inner_width, layout_direction)
      local measured = measure_node(child, inner_width, inner_height)
      local base_main = main_size(child_style, direction, available_main, available_cross, measured)
      local spec = {
        child = child,
        style = child_style,
        margin = margin,
        grow = flex_grow(child_style),
        shrink = flex_shrink(child_style),
        base_main = base_main,
        main = base_main,
        auto_main = has_auto_main_size(child_style, direction, available_main, available_cross, measured),
        auto_cross = has_auto_cross_size(child_style, direction, available_cross, measured),
        measured = measured,
      }
      local outer_main = main_outer_size(spec, direction)
      local next_used = #current_line.items > 0 and current_line.used_main + gap + outer_main or outer_main

      if #current_line.items > 0 and available_main > 0 and next_used > available_main then
        push_line()
        next_used = outer_main
      end

      current_line.items[#current_line.items + 1] = spec
      current_line.used_main = next_used
      specs[index] = spec
    end
  end

  push_line()

  local cross_cursor = 0

  for _, line in ipairs(lines) do
    distribute_line_main(line, direction, gap, available_main)
    line.cross = line_cross_size(line, direction, inner_width, inner_height)
  end

  local cross_leading, cross_between =
    align_content_offsets(style, lines, line_gap, available_cross, auto_cross_size)
  local used_cross = used_line_cross_size(lines, cross_between)
  local cross_extent = auto_cross_size and used_cross or available_cross
  cross_cursor = wrap_reverse and cross_extent - cross_leading or cross_leading

  for _, line in ipairs(lines) do
    local leading, between = justify_offsets(style, line.items, direction, gap, inner_width, inner_height)
    local main_cursor = 0
    local line_cross_start = cross_cursor

    if wrap_reverse then
      line_cross_start = cross_cursor - line.cross
    end

    for _, spec in ipairs(line.items) do
      local child = spec.child
      local child_style = child.style or {}
      local margin = spec.margin
      local child_left = border.left + padding.left
      local child_top = border.top + padding.top

      if is_row_direction(direction) then
        local child_height, cross_offset =
          cross_axis_layout_in_line(style, child_style, direction, margin, line.cross, spec.measured, spec.main, layout_direction)
        if spec.auto_cross then
          local line_height = clamp_size(line.cross - margin.top - margin.bottom)
          child_height = math.max(auto_cross_size_from_child(spec, direction, inner_width, inner_height) or 0, line_height)
          cross_offset = margin.top
        end
        if wrap_reverse then
          cross_offset = line.cross - cross_offset - child_height
        end
        child_left = child_left + leading + main_cursor + margin.left
        child_top = child_top + line_cross_start + cross_offset
        layout_node(
          child,
          child_left,
          child_top,
          spec.main,
          child_height,
          inner_width,
          inner_height,
          spec.measured,
          { useAvailableWidth = true },
          layout_direction
        )
        main_cursor = main_cursor + margin.left + child.layout.width + margin.right + between
      else
        local child_width, cross_offset =
          cross_axis_layout_in_line(style, child_style, direction, margin, line.cross, spec.measured, spec.main, layout_direction)
        if spec.auto_cross then
          local line_width = clamp_size(line.cross - margin.left - margin.right)
          child_width = math.max(auto_cross_size_from_child(spec, direction, inner_width, inner_height) or 0, line_width)
          cross_offset = margin.left
        end
        if wrap_reverse then
          cross_offset = line.cross - cross_offset - child_width
        end
        child_left = child_left + line_cross_start + cross_offset
        child_top = child_top + leading + main_cursor + margin.top
        layout_node(
          child,
          child_left,
          child_top,
          child_width,
          spec.main,
          inner_width,
          inner_height,
          spec.measured,
          { useAvailableHeight = true },
          layout_direction
        )
        main_cursor = main_cursor + margin.top + child.layout.height + margin.bottom + between
      end

      local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height, layout_direction)
      offset_layout_box(child, relative_left, relative_top)
    end

    if wrap_reverse then
      cross_cursor = line_cross_start - cross_between
    else
      cross_cursor = cross_cursor + line.cross + cross_between
    end
  end

  if #lines > 0 and not wrap_reverse then
    cross_cursor = cross_cursor - cross_between
  end

  for index, child in ipairs(children) do
    local spec = specs[index]

    if spec and spec.hidden then
      zero_layout_tree(child)
    elseif spec and spec.absolute then
      layout_absolute_node(child, style, padding, border, node.layout.width, node.layout.height, inner_width, inner_height, layout_direction)
    end
  end

  if auto_cross_size then
    if is_row_direction(direction) then
      local height = border.top + padding.top + used_cross + padding.bottom + border.bottom
      node.layout.height = constrain_size(height, style, "height", owner_height)
    else
      local width = border.left + padding.left + used_cross + padding.right + border.right
      node.layout.width = constrain_size(width, style, "width", owner_width)
    end
  end

  if auto_main_size then
    local used_main = 0

    for _, line in ipairs(lines) do
      used_main = math.max(used_main, used_main_size(line.items, direction, gap))
    end

    if is_row_direction(direction) then
      local width = border.left + padding.left + used_main + padding.right + border.right
      node.layout.width = constrain_size(width, style, "width", owner_width)
    else
      local height = border.top + padding.top + used_main + padding.bottom + border.bottom
      node.layout.height = constrain_size(height, style, "height", owner_height)
    end
  end

end

function layout_node(node, left, top, available_width, available_height, owner_width, owner_height, measured, options, layout_direction)
  if is_display_none(node) then
    zero_layout_tree(node)
    return node
  end

  options = options or {}
  layout_direction = normalize_layout_direction(layout_direction)

  local style = node.style or {}
  local measured_size = measured or measure_node(node, available_width, available_height)
  local explicit_width = resolve_value(style.width, owner_width)
  local explicit_height = resolve_value(style.height, owner_height)
  local width = options.useAvailableWidth and available_width
    or explicit_width
    or available_width
    or (measured_size and measured_size.width)
  local height = options.useAvailableHeight and available_height
    or explicit_height
    or available_height
    or (measured_size and measured_size.height)
  local ratio = aspect_ratio(style)

  if ratio then
    if width ~= nil and height == nil then
      height = width / ratio
    elseif height ~= nil and width == nil then
      width = height * ratio
    end
  end

  local width_unspecified = width == nil
  local height_unspecified = height == nil
  node.layout.left = left
  node.layout.top = top
  node.layout.width = constrain_size(width, style, "width", owner_width)
  node.layout.height = constrain_size(height, style, "height", owner_height)
  node.dirty = false

  local border = resolve_edges(style, "border", node.layout.width, layout_direction)
  local padding = resolve_edges(style, "padding", node.layout.width, layout_direction)
  if width_unspecified then
    node.layout.width = constrain_size(border.left + padding.left + padding.right + border.right, style, "width", owner_width)
  end
  if height_unspecified then
    node.layout.height = constrain_size(border.top + padding.top + padding.bottom + border.bottom, style, "height", owner_height)
  end
  local direction = style.flexDirection or "column"
  local gap = main_axis_gap(style, direction)
  local cursor = 0
  local inner_width = clamp_size(node.layout.width - border.left - padding.left - padding.right - border.right)
  local inner_height = clamp_size(node.layout.height - border.top - padding.top - padding.bottom - border.bottom)
  local children = node.children or {}
  local auto_main_available = (is_row_direction(direction) and inner_width == 0)
    or (not is_row_direction(direction) and inner_height == 0)
  local auto_cross_available = (is_row_direction(direction) and inner_height == 0)
    or (not is_row_direction(direction) and inner_width == 0)

  if style.flexWrap == "wrap" or style.flexWrap == "wrap-reverse" then
    local auto_main_size = auto_main_available
      and (
        (is_row_direction(direction) and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
        or (not is_row_direction(direction) and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
      )
    local auto_cross_size = auto_cross_available
      and (
        (is_row_direction(direction) and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
        or (not is_row_direction(direction) and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
      )
    layout_wrapped_children(
      node,
      padding,
      border,
      inner_width,
      inner_height,
      owner_width,
      owner_height,
      auto_main_size,
      auto_cross_size,
      layout_direction
    )
    return node
  end

  local layout_items = collect_layout_items(children)
  local specs = build_child_specs(layout_items, direction, gap, inner_width, inner_height, layout_direction)
  local leading, between = justify_offsets(style, specs, direction, gap, inner_width, inner_height)
  local has_auto_children = visible_spec_count(specs) > 0
  local auto_main_size = has_auto_children
    and auto_main_available
    and (
      (is_row_direction(direction) and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
      or (not is_row_direction(direction) and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
    )
  local auto_cross_size = has_auto_children
    and auto_cross_available
    and (
      (is_row_direction(direction) and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
      or (not is_row_direction(direction) and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
    )

  for index, child in ipairs(layout_items) do
    local child_style = child.style or {}
    local spec = specs[index]

    if spec.hidden then
      zero_layout_tree(child)
    elseif spec.absolute then
      layout_absolute_node(child, style, padding, border, node.layout.width, node.layout.height, inner_width, inner_height, layout_direction)
    else
      local margin = spec.margin
      local child_left = border.left + padding.left
      local child_top = border.top + padding.top

      if is_row_direction(direction) then
        local child_height, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured, spec.main, layout_direction)
        local child_auto_main = auto_main_size and spec.auto_main
        local child_width = spec.main
        if auto_cross_size and spec.auto_cross then
          child_height = nil
          cross_offset = margin.top
        end
        if child_auto_main then
          child_width = nil
        end
        if is_main_axis_reversed(direction, layout_direction) then
          child_left = child_left + inner_width - leading - cursor - margin.right - (child_width or spec.main)
        else
          child_left = child_left + leading + cursor + margin.left
        end
        child_top = child_top + cross_offset
        layout_node(
          child,
          child_left,
          child_top,
          child_width,
          child_height,
          inner_width,
          inner_height,
          spec.measured,
          { useAvailableWidth = not child_auto_main },
          layout_direction
        )
        if child_auto_main then
          spec.main = child.layout.width
        end
        local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height, layout_direction)
        offset_layout_box(child, relative_left, relative_top)
        cursor = cursor + margin.left + child.layout.width + margin.right + between
      else
        local child_width, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured, spec.main, layout_direction)
        local child_auto_main = auto_main_size and spec.auto_main
        local child_height = spec.main
        if auto_cross_size and spec.auto_cross then
          child_width = nil
          cross_offset = margin.left
        end
        if child_auto_main then
          child_height = nil
        end
        child_left = child_left + cross_offset
        if is_main_axis_reversed(direction, layout_direction) then
          child_top = child_top + inner_height - leading - cursor - margin.bottom - (child_height or spec.main)
        else
          child_top = child_top + leading + cursor + margin.top
        end
        layout_node(
          child,
          child_left,
          child_top,
          child_width,
          child_height,
          inner_width,
          inner_height,
          spec.measured,
          { useAvailableHeight = not child_auto_main },
          layout_direction
        )
        if child_auto_main then
          spec.main = child.layout.height
        end
        local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height, layout_direction)
        offset_layout_box(child, relative_left, relative_top)
        cursor = cursor + margin.top + child.layout.height + margin.bottom + between
      end
    end
  end

  baseline_align_children(style, specs, direction)

  if auto_main_size then
    if is_row_direction(direction) then
      node.layout.width = constrain_size(child_main_extent(specs, direction, gap, padding, border), style, "width", owner_width)
    else
      node.layout.height = constrain_size(child_main_extent(specs, direction, gap, padding, border), style, "height", owner_height)
    end
  end

  if auto_cross_size then
    if is_row_direction(direction) then
      node.layout.height = constrain_size(child_cross_extent(specs, direction, padding, border), style, "height", owner_height)
    else
      node.layout.width = constrain_size(child_cross_extent(specs, direction, padding, border), style, "width", owner_width)
    end

    relayout_stretched_auto_cross_children(node, specs, direction, padding, border, layout_direction)
  end

  return node
end

local function root_absolute_axis_offset(style, start_key, end_key, owner_size, size)
  local start = resolve_value(style[start_key], owner_size)
  if start ~= nil then
    return start
  end

  local ending = resolve_value(style[end_key], owner_size)
  if ending ~= nil then
    if owner_size ~= nil and size ~= nil then
      return owner_size - ending - size
    end

    return -ending
  end

  return 0
end

local function root_offsets(root, owner_width, owner_height, layout_direction)
  local style = root.style or {}
  local margin = resolve_edges(style, "margin", owner_width or root.layout.width, layout_direction)
  local left
  local top

  if is_absolute_position(root) then
    local left_offset, right_offset = resolve_horizontal_position_offsets(style, owner_width, layout_direction)
    if left_offset ~= nil then
      left = left_offset
    elseif right_offset ~= nil then
      if owner_width ~= nil and root.layout.width ~= nil then
        left = owner_width - right_offset - root.layout.width
      else
        left = -right_offset
      end
    else
      left = 0
    end
    top = root_absolute_axis_offset(style, "top", "bottom", owner_height, root.layout.height)
  else
    left, top = relative_offsets(style, owner_width, owner_height, layout_direction)
  end

  return left + margin.left, top + margin.top
end

function yoga.calculateLayout(root, width, height, layout_direction)
  layout_direction = normalize_layout_direction(layout_direction)
  layout_node(root, 0, 0, width, height, width, height, nil, nil, layout_direction)
  local root_left, root_top = root_offsets(root, width, height, layout_direction)
  offset_layout_box(root, root_left, root_top)
  round_layout_tree(root)
  return root
end

return yoga
