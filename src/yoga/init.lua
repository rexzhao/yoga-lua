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

local function is_absolute_position(node)
  return (node.style or {}).position == "absolute"
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

local function offset_layout_tree(node, dx, dy)
  node.layout.left = node.layout.left + dx
  node.layout.top = node.layout.top + dy

  for _, child in ipairs(node.children or {}) do
    offset_layout_tree(child, dx, dy)
  end
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

local function round_layout_tree(node)
  local raw_left = node.layout.left
  local raw_top = node.layout.top
  local raw_width = node.layout.width
  local raw_height = node.layout.height
  local rounded_left = round_to_pixel_grid(raw_left)
  local rounded_top = round_to_pixel_grid(raw_top)
  local rounded_right = round_to_pixel_grid(raw_left + raw_width)
  local rounded_bottom = round_to_pixel_grid(raw_top + raw_height)

  node.layout.left = rounded_left
  node.layout.top = rounded_top
  node.layout.width = math.max(0, rounded_right - rounded_left)
  node.layout.height = math.max(0, rounded_bottom - rounded_top)

  for _, child in ipairs(node.children or {}) do
    round_layout_tree(child)
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

local function relative_offsets(style, owner_width, owner_height)
  return relative_axis_offset(style, "left", "right", owner_width),
    relative_axis_offset(style, "top", "bottom", owner_height)
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
  if direction == "row" then
    return number_or_zero(style.columnGap or style.gap)
  end

  return number_or_zero(style.rowGap or style.gap)
end

local function cross_axis_gap(style, direction)
  if direction == "row" then
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

  if direction == "row" then
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
      local margin = resolve_edges(style, "margin", inner_width)
      local grow = flex_grow(style)
      local shrink = flex_shrink(style)
      local measured = measure_node(child, inner_width, inner_height)
      local available_cross = direction == "row" and inner_height or inner_width
      local base_main = main_size(style, direction, available_main, available_cross, measured)

      specs[index] = {
        child = child,
        style = style,
        margin = margin,
        grow = grow,
        shrink = shrink,
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
    local dimension = direction == "row" and "width" or "height"

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

local function child_main_extent(specs, direction, gap, padding)
  local main = used_main_size(specs, direction, gap)

  if direction == "row" then
    return padding.left + main + padding.right
  end

  return padding.top + main + padding.bottom
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

local function cross_axis_layout(parent_style, child_style, direction, margin, inner_width, inner_height, measured, main)
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
  local ratio = aspect_ratio(child_style)

  if explicit ~= nil then
    size = clamp_size(explicit)
  elseif ratio and type(main) == "number" then
    if direction == "row" then
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

local function absolute_axis_size(style, dimension, owner_size, start_offset, end_offset, measured_size)
  local explicit = dimension == "width" and resolve_value(style.width, owner_size) or resolve_value(style.height, owner_size)

  if explicit ~= nil then
    return constrain_size(explicit, style, dimension, owner_size)
  end

  if start_offset ~= nil and end_offset ~= nil then
    return constrain_size(owner_size - start_offset - end_offset, style, dimension, owner_size)
  end

  return constrain_size(measured_size, style, dimension, owner_size)
end

local function absolute_default_offset(parent_style, child_style, direction, axis, available, size)
  if axis == "horizontal" then
    if direction == "row" then
      return main_axis_offset(parent_style, available, size)
    end

    return cross_axis_offset(parent_style, child_style, available, size)
  end

  if direction == "row" then
    return cross_axis_offset(parent_style, child_style, available, size)
  end

  return main_axis_offset(parent_style, available, size)
end

local function absolute_axis_position(parent_style, child_style, direction, axis, origin, available, size, start_offset, end_offset)
  if start_offset ~= nil then
    return origin + start_offset
  end

  if end_offset ~= nil then
    return origin + available - end_offset - size
  end

  return origin + absolute_default_offset(parent_style, child_style, direction, axis, available, size)
end

local function layout_absolute_node(child, parent_style, parent_left, parent_top, padding, inner_width, inner_height)
  local style = child.style or {}
  local measured = measure_node(child, inner_width, inner_height)
  local left_offset = resolve_value(style.left, inner_width)
  local right_offset = resolve_value(style.right, inner_width)
  local top_offset = resolve_value(style.top, inner_height)
  local bottom_offset = resolve_value(style.bottom, inner_height)
  local width = absolute_axis_size(style, "width", inner_width, left_offset, right_offset, measured and measured.width)
  local height = absolute_axis_size(style, "height", inner_height, top_offset, bottom_offset, measured and measured.height)
  local direction = parent_style.flexDirection or "column"
  local origin_left = parent_left + padding.left
  local origin_top = parent_top + padding.top
  local child_left =
    absolute_axis_position(parent_style, style, direction, "horizontal", origin_left, inner_width, width, left_offset, right_offset)
  local child_top =
    absolute_axis_position(parent_style, style, direction, "vertical", origin_top, inner_height, height, top_offset, bottom_offset)

  layout_node(child, child_left, child_top, width, height, inner_width, inner_height, measured)
end

local function main_outer_size(spec, direction)
  local margin = spec.margin

  if direction == "row" then
    return margin.left + spec.base_main + margin.right
  end

  return margin.top + spec.base_main + margin.bottom
end

local function spec_main_size(spec, direction)
  local margin = spec.margin

  if direction == "row" then
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
  local dimension = direction == "row" and "width" or "height"

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

local function cross_axis_size_in_line(child_style, direction, measured, main)
  local ratio = aspect_ratio(child_style)

  if direction == "row" then
    local explicit = resolve_value(child_style.height)
    if explicit ~= nil then
      return clamp_size(explicit)
    end

    if ratio and type(main) == "number" then
      return clamp_size(main / ratio)
    end

    return clamp_size(measured and measured.height)
  end

  local explicit = resolve_value(child_style.width)
  if explicit ~= nil then
    return clamp_size(explicit)
  end

  if ratio and type(main) == "number" then
    return clamp_size(main * ratio)
  end

  return clamp_size(measured and measured.width)
end

local function line_cross_size(line, direction)
  local cross = 0

  for _, spec in ipairs(line.items) do
    local margin = spec.margin
    local size = cross_axis_size_in_line(spec.style, direction, spec.measured, spec.main)

    if direction == "row" then
      cross = math.max(cross, margin.top + size + margin.bottom)
    else
      cross = math.max(cross, margin.left + size + margin.right)
    end
  end

  return cross
end

local function child_cross_extent(specs, direction, padding)
  local cross = 0

  for _, spec in ipairs(specs) do
    if not spec.hidden and not spec.absolute then
      local margin = spec.margin
      local child = spec.child

      if direction == "row" then
        cross = math.max(cross, margin.top + child.layout.height + margin.bottom)
      else
        cross = math.max(cross, margin.left + child.layout.width + margin.right)
      end
    end
  end

  if direction == "row" then
    return padding.top + cross + padding.bottom
  end

  return padding.left + cross + padding.right
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
  local remaining = auto_cross_size and 0 or math.max(0, available_cross - used_line_cross_size(lines, gap))
  local align = style.alignContent or "flex-start"
  local leading = 0
  local between = gap
  local line_count = #lines

  if align == "center" then
    leading = remaining / 2
  elseif align == "flex-end" then
    leading = remaining
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

local function cross_axis_layout_in_line(parent_style, child_style, direction, margin, line_cross, measured, main)
  return cross_axis_layout(parent_style, child_style, direction, margin, line_cross, line_cross, measured, main)
end

local function layout_wrapped_children(node, left, top, padding, inner_width, inner_height, auto_cross_size)
  local style = node.style or {}
  local direction = style.flexDirection or "column"
  local gap = main_axis_gap(style, direction)
  local line_gap = cross_axis_gap(style, direction)
  local available_main = direction == "row" and inner_width or inner_height
  local available_cross = direction == "row" and inner_height or inner_width
  local lines = {}
  local current_line = { items = {}, used_main = 0 }
  local specs = {}

  local function push_line()
    if #current_line.items > 0 then
      lines[#lines + 1] = current_line
      current_line = { items = {}, used_main = 0 }
    end
  end

  for index, child in ipairs(node.children or {}) do
    if is_display_none(child) then
      specs[index] = { hidden = true }
    elseif is_absolute_position(child) then
      specs[index] = { absolute = true, child = child }
    else
      local child_style = child.style or {}
      local margin = resolve_edges(child_style, "margin", inner_width)
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
    line.cross = line_cross_size(line, direction)
  end

  local cross_leading, cross_between =
    align_content_offsets(style, lines, line_gap, available_cross, auto_cross_size)
  cross_cursor = cross_leading

  for _, line in ipairs(lines) do
    local leading, between = justify_offsets(style, line.items, direction, gap, inner_width, inner_height)
    local main_cursor = 0

    for _, spec in ipairs(line.items) do
      local child = spec.child
      local child_style = child.style or {}
      local margin = spec.margin
      local child_left = left + padding.left
      local child_top = top + padding.top

      if direction == "row" then
        local child_height, cross_offset =
          cross_axis_layout_in_line(style, child_style, direction, margin, line.cross, spec.measured, spec.main)
        child_left = child_left + leading + main_cursor + margin.left
        child_top = child_top + cross_cursor + cross_offset
        layout_node(
          child,
          child_left,
          child_top,
          spec.main,
          child_height,
          inner_width,
          inner_height,
          spec.measured,
          { useAvailableWidth = true }
        )
        main_cursor = main_cursor + margin.left + child.layout.width + margin.right + between
      else
        local child_width, cross_offset =
          cross_axis_layout_in_line(style, child_style, direction, margin, line.cross, spec.measured, spec.main)
        child_left = child_left + cross_cursor + cross_offset
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
          { useAvailableHeight = true }
        )
        main_cursor = main_cursor + margin.top + child.layout.height + margin.bottom + between
      end

      local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height)
      offset_layout_tree(child, relative_left, relative_top)
    end

    cross_cursor = cross_cursor + line.cross + cross_between
  end

  if #lines > 0 then
    cross_cursor = cross_cursor - cross_between
  end

  for index, child in ipairs(node.children or {}) do
    local spec = specs[index]

    if spec and spec.hidden then
      zero_layout_tree(child)
    elseif spec and spec.absolute then
      layout_absolute_node(child, style, left, top, padding, inner_width, inner_height)
    end
  end

  if auto_cross_size then
    if direction == "row" then
      node.layout.height = padding.top + cross_cursor + padding.bottom
    else
      node.layout.width = padding.left + cross_cursor + padding.right
    end
  end
end

function layout_node(node, left, top, available_width, available_height, owner_width, owner_height, measured, options)
  if is_display_none(node) then
    zero_layout_tree(node)
    return node
  end

  options = options or {}

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

  node.layout.left = left
  node.layout.top = top
  node.layout.width = constrain_size(width, style, "width", owner_width)
  node.layout.height = constrain_size(height, style, "height", owner_height)
  node.dirty = false

  local padding = resolve_edges(style, "padding", node.layout.width)
  local direction = style.flexDirection or "column"
  local gap = main_axis_gap(style, direction)
  local cursor = 0
  local inner_width = clamp_size(node.layout.width - padding.left - padding.right)
  local inner_height = clamp_size(node.layout.height - padding.top - padding.bottom)
  local children = node.children or {}

  if style.flexWrap == "wrap" then
    local auto_cross_size = (direction == "row" and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
      or (direction == "column" and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
    layout_wrapped_children(node, left, top, padding, inner_width, inner_height, auto_cross_size)
    return node
  end

  local specs = build_child_specs(children, direction, gap, inner_width, inner_height)
  local leading, between = justify_offsets(style, specs, direction, gap, inner_width, inner_height)
  local has_auto_children = visible_spec_count(specs) > 0
  local auto_main_size = has_auto_children
    and (
      (direction == "row" and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
      or (direction == "column" and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
    )
  local auto_cross_size = has_auto_children
    and (
      (direction == "row" and explicit_height == nil and available_height == nil and not options.useAvailableHeight)
      or (direction == "column" and explicit_width == nil and available_width == nil and not options.useAvailableWidth)
    )

  for index, child in ipairs(children) do
    local child_style = child.style or {}
    local spec = specs[index]

    if spec.hidden then
      zero_layout_tree(child)
    elseif spec.absolute then
      layout_absolute_node(child, style, left, top, padding, inner_width, inner_height)
    else
      local margin = spec.margin
      local child_left = left + padding.left
      local child_top = top + padding.top

      if direction == "row" then
        local child_height, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured, spec.main)
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
          spec.measured,
          { useAvailableWidth = true }
        )
        local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height)
        offset_layout_tree(child, relative_left, relative_top)
        cursor = cursor + margin.left + child.layout.width + margin.right + between
      else
        local child_width, cross_offset =
          cross_axis_layout(style, child_style, direction, margin, inner_width, inner_height, spec.measured, spec.main)
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
          spec.measured,
          { useAvailableHeight = true }
        )
        local relative_left, relative_top = relative_offsets(child_style, inner_width, inner_height)
        offset_layout_tree(child, relative_left, relative_top)
        cursor = cursor + margin.top + child.layout.height + margin.bottom + between
      end
    end
  end

  if auto_main_size then
    if direction == "row" then
      node.layout.width = constrain_size(child_main_extent(specs, direction, gap, padding), style, "width", owner_width)
    else
      node.layout.height = constrain_size(child_main_extent(specs, direction, gap, padding), style, "height", owner_height)
    end
  end

  if auto_cross_size then
    if direction == "row" then
      node.layout.height = constrain_size(child_cross_extent(specs, direction, padding), style, "height", owner_height)
    else
      node.layout.width = constrain_size(child_cross_extent(specs, direction, padding), style, "width", owner_width)
    end
  end

  return node
end

function yoga.calculateLayout(root, width, height)
  layout_node(root, 0, 0, width, height, width, height)
  round_layout_tree(root)
  return root
end

return yoga
