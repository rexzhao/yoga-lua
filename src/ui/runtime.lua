local yoga = require("yoga")
local scroll = require("ui.scroll")

local runtime = {}

local Runtime = {}
Runtime.__index = Runtime

local function is_array(value)
  if type(value) ~= "table" then
    return false
  end

  return value[1] ~= nil or next(value) == nil
end

local function shallow_copy(source)
  local copy = {}
  if source then
    for key, value in pairs(source) do
      copy[key] = value
    end
  end
  return copy
end

local function shallow_equal(left, right)
  if left == right then
    return true
  end

  if type(left) ~= "table" or type(right) ~= "table" then
    return false
  end

  for key, value in pairs(left) do
    if right[key] ~= value then
      return false
    end
  end

  for key in pairs(right) do
    if left[key] == nil then
      return false
    end
  end

  return true
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

local function is_element(value)
  return type(value) == "table" and value._uiElement == true
end

local function is_yoga_node(value)
  return type(value) == "table" and type(value.style) == "table" and type(value.layout) == "table"
end

local function props_key(props)
  props = props or {}
  if props.key ~= nil then
    return props.key
  end

  if type(props.flip) == "table" then
    return props.flip.key
  end

  if type(props.flip) ~= "boolean" then
    return props.flip
  end

  return nil
end

local function element_type(element)
  if is_element(element) then
    return element.type
  end

  if is_yoga_node(element) then
    return element.type or "node"
  end

  return nil
end

local function element_key(element)
  if is_element(element) then
    return element.key
  end

  if is_yoga_node(element) then
    return props_key(element.props)
  end

  return nil
end

local function path_key(parent_path, index, key)
  if key ~= nil then
    return parent_path .. "/" .. tostring(key)
  end

  return parent_path .. "/" .. tostring(index)
end

local function build_key(type_name, key)
  return tostring(type_name) .. "\0" .. tostring(key)
end

function Runtime:_resolveStyle(props)
  props = props or {}

  local style = {}
  local styles = props.styles or self.styles
  if styles and props.class then
    for _, class_name in ipairs(class_names(props.class)) do
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

  if type(props.measure) == "function" then
    style.measure = props.measure
  end

  return style
end

function Runtime:_element(type_name, props, children, fields)
  props, children = normalize_args(props, children)

  local element = {
    _uiElement = true,
    type = type_name,
    key = props_key(props),
    props = props,
    children = children,
  }

  if fields then
    for key, value in pairs(fields) do
      element[key] = value
    end
  end

  return element
end

function Runtime:div(props, children)
  return self:_element("div", props, children)
end

function Runtime:text(value, props)
  props = props or {}
  return self:_element("text", props, {}, { text = value })
end

function Runtime:image(props)
  props = props or {}
  return self:_element("image", props, {})
end

function Runtime:button(label, props)
  props = props or {}
  return self:_element("button", props, {
    self:text(label),
  }, { label = label })
end

function Runtime:scrollView(props, children)
  props, children = normalize_args(props, children)

  local scroll_props = shallow_copy(props)
  local scroll_style = shallow_copy(props.style)
  scroll.applyContainerStyle(scroll_style, props.axis)
  scroll_props.style = scroll_style

  return self:_element("scrollView", scroll_props, children, {
    scroll = scroll.initialMetrics(props),
  })
end

function Runtime:virtualList(props)
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
  local children = {
    self:div({
      role = "virtual-spacer",
      spacer = "top",
      style = { height = top_height },
    }),
  }

  if type(render_item) == "function" then
    for index = visible_start, visible_end do
      local item = render_item(index)
      if item then
        children[#children + 1] = item
      end
    end
  end

  children[#children + 1] = self:div({
    role = "virtual-spacer",
    spacer = "bottom",
    style = { height = bottom_height },
  })

  local list_props = shallow_copy(props)
  local list_style = shallow_copy(props.style)
  list_style.height = list_style.height or viewport_height
  list_style.overflow = list_style.overflow or "scroll"
  list_style.flexDirection = list_style.flexDirection or "column"
  list_props.style = list_style

  return self:_element("virtualList", list_props, children, {
    virtual = {
      itemCount = item_count,
      itemHeight = item_height,
      viewportHeight = viewport_height,
      scrollOffset = scroll_offset,
      maxScroll = max_scroll,
      visibleStart = visible_start,
      visibleEnd = visible_end,
      topSpacerHeight = top_height,
      bottomSpacerHeight = bottom_height,
    },
    scroll = scroll.virtualMetrics({
      scrollOffset = scroll_offset,
      maxScroll = max_scroll,
      contentHeight = content_height,
      viewportHeight = viewport_height,
    }),
  })
end

function Runtime:ui()
  return {
    div = function(props, children)
      return self:div(props, children)
    end,
    text = function(value, props)
      return self:text(value, props)
    end,
    image = function(props)
      return self:image(props)
    end,
    button = function(label, props)
      return self:button(label, props)
    end,
    scrollView = function(props, children)
      return self:scrollView(props, children)
    end,
    virtualList = function(props)
      return self:virtualList(props)
    end,
    scrollDelta = function(scroll_state, delta, metrics)
      return scroll.delta(scroll_state, delta, metrics)
    end,
    stylesheet = function(definitions)
      return definitions or {}
    end,
  }
end

function Runtime:_callRenderer(method, ...)
  local renderer = self.renderer
  local fn = renderer and renderer[method]
  if fn then
    return fn(renderer, ...)
  end

  return nil
end

function Runtime:_updateNodeMetadata(instance, element)
  local node = instance.yogaNode

  node.type = instance.type
  node.props = instance.props
  node.text = element.text
  node.label = element.label
  node.virtual = element.virtual
  node.scroll = element.scroll
  node._uiInstance = instance
end

function Runtime:_mount(element, parent, index, path)
  if is_yoga_node(element) and not is_element(element) then
    return self:_mountExistingNode(element, parent, index, path)
  end

  if not is_element(element) then
    error("runtime can only mount UI elements or Yoga nodes", 2)
  end

  local props = element.props or {}
  local resolved_style = self:_resolveStyle(props)
  local node = yoga.node(resolved_style, {})
  local instance = {
    type = element.type,
    key = element.key,
    path = path,
    props = props,
    element = element,
    resolvedStyle = resolved_style,
    yogaNode = node,
    children = {},
    text = element.text,
    label = element.label,
    virtual = element.virtual,
    scroll = element.scroll,
    visual = {},
  }

  self:_updateNodeMetadata(instance, element)
  instance.handle = self:_callRenderer("mount", instance, parent and parent.handle, index)

  local child_nodes = {}
  for child_index, child_element in ipairs(element.children or {}) do
    local child_path = path_key(path, child_index, element_key(child_element))
    local child = self:_mount(child_element, instance, child_index, child_path)
    instance.children[#instance.children + 1] = child
    child_nodes[#child_nodes + 1] = child.yogaNode
  end

  if #child_nodes > 0 then
    yoga.setChildren(node, child_nodes)
  end

  return instance
end

function Runtime:_mountExistingNode(node, parent, index, path)
  local props = node.props or {}
  local instance = {
    type = node.type or "node",
    key = props_key(props),
    path = path,
    props = props,
    resolvedStyle = node.style or {},
    yogaNode = node,
    children = {},
    text = node.text,
    label = node.label,
    virtual = node.virtual,
    scroll = node.scroll,
    visual = {},
    compatibleNode = true,
  }

  instance.handle = self:_callRenderer("mount", instance, parent and parent.handle, index)

  for child_index, child_node in ipairs(node.children or {}) do
    local child_path = path_key(path, child_index, child_node.props and child_node.props.key)
    instance.children[#instance.children + 1] = self:_mountExistingNode(child_node, instance, child_index, child_path)
  end

  return instance
end

function Runtime:_unmount(instance)
  for _, child in ipairs(instance.children or {}) do
    self:_unmount(child)
  end

  self:_callRenderer("unmount", instance)
  instance.unmounted = true
end

function Runtime:_canReuse(instance, element)
  if instance.compatibleNode or (is_yoga_node(element) and not is_element(element)) then
    return instance.yogaNode == element
  end

  return is_element(element)
    and instance.type == element.type
    and instance.key == element.key
end

function Runtime:_reconcile(instance, element, parent, index, path)
  if not self:_canReuse(instance, element) then
    self:_unmount(instance)
    return self:_mount(element, parent, index, path)
  end

  if is_yoga_node(element) and not is_element(element) then
    instance.path = path
    return instance
  end

  local props = element.props or {}
  local resolved_style = self:_resolveStyle(props)
  local style_changed = not shallow_equal(instance.resolvedStyle, resolved_style)
  local props_changed = not shallow_equal(instance.props or {}, props)
    or instance.text ~= element.text
    or instance.label ~= element.label
    or instance.virtual ~= element.virtual

  instance.path = path
  instance.props = props
  instance.element = element
  instance.key = element.key
  instance.resolvedStyle = resolved_style
  instance.text = element.text
  instance.label = element.label
  instance.virtual = element.virtual
  instance.scroll = element.scroll

  if style_changed then
    yoga.setStyle(instance.yogaNode, resolved_style)
  end

  self:_updateNodeMetadata(instance, element)
  self:_reconcileChildren(instance, element.children or {}, path)

  if style_changed or props_changed then
    self:_callRenderer("update", instance, {
      propsChanged = props_changed,
      styleChanged = style_changed,
    })
  end

  return instance
end

function Runtime:_reconcileChildren(instance, child_elements, path)
  local old_children = instance.children or {}
  local old_keyed = {}

  for _, child in ipairs(old_children) do
    if child.key ~= nil then
      old_keyed[build_key(child.type, child.key)] = child
    end
  end

  local used = {}
  local new_children = {}
  local child_nodes = {}

  for index, child_element in ipairs(child_elements) do
    local child_type = element_type(child_element)
    local child_key = element_key(child_element)
    local match

    if child_key ~= nil then
      match = old_keyed[build_key(child_type, child_key)]
      if match and used[match] then
        match = nil
      end
    else
      local old_child = old_children[index]
      if old_child and old_child.key == nil and old_child.type == child_type and not used[old_child] then
        match = old_child
      end
    end

    local child_path = path_key(path, index, child_key)
    local child
    if match then
      used[match] = true
      child = self:_reconcile(match, child_element, instance, index, child_path)
    else
      child = self:_mount(child_element, instance, index, child_path)
    end

    new_children[#new_children + 1] = child
    child_nodes[#child_nodes + 1] = child.yogaNode
  end

  for _, child in ipairs(old_children) do
    if not used[child] then
      self:_unmount(child)
    end
  end

  local order_changed = #old_children ~= #new_children
  if not order_changed then
    for index, child in ipairs(new_children) do
      if old_children[index] ~= child then
        order_changed = true
        break
      end
    end
  end

  instance.children = new_children
  if order_changed then
    yoga.setChildren(instance.yogaNode, child_nodes)
  end
end

function Runtime:_snapshotLayout(instance, field, parent_left, parent_top)
  local node = instance.yogaNode
  local layout = node.layout
  local left = (parent_left or 0) + layout.left
  local top = (parent_top or 0) + layout.top

  instance[field] = {
    left = left,
    top = top,
    width = layout.width,
    height = layout.height,
  }

  local has_box = layout.width > 0 and layout.height > 0
  local props = node.props or {}
  local style = node.style or {}
  local clips = has_box
    and (props.clipChildren == true or style.overflow == "hidden" or style.overflow == "scroll")
  local metrics = scroll.updateNodeMetrics(node)

  instance.clip = nil
  if clips then
    instance.clip = {
      left = left,
      top = top,
      width = layout.width,
      height = layout.height,
    }
  end

  if metrics then
    metrics.clip = instance.clip
    instance.scroll = metrics
  else
    instance.scroll = node.scroll
  end

  local scroll_x, scroll_y = scroll.offset(node.scroll)
  if (scroll_x == 0 and scroll_y == 0) and node.virtual then
    scroll_y = node.virtual.scrollOffset or 0
  end

  local child_parent_left = left - scroll_x
  local child_parent_top = top - scroll_y
  for _, child in ipairs(instance.children or {}) do
    self:_snapshotLayout(child, field, child_parent_left, child_parent_top)
  end
end

function Runtime:_applyLayout(instance)
  self:_callRenderer("applyLayout", instance, instance.layout)

  for _, child in ipairs(instance.children or {}) do
    self:_applyLayout(child)
  end
end

function Runtime:render(element, width, height, layout_direction)
  if self.root then
    self:_snapshotLayout(self.root, "previousLayout")
    self.root = self:_reconcile(self.root, element, nil, 1, "root")
  else
    self.root = self:_mount(element, nil, 1, "root")
  end

  yoga.calculateLayout(self.root.yogaNode, width, height, layout_direction)
  self:_snapshotLayout(self.root, "layout")
  self:_applyLayout(self.root)

  return self.root
end

function Runtime:snapshotLayout(field)
  if self.root then
    self:_snapshotLayout(self.root, field or "layout")
  end

  return self.root
end

local function point_in_rect(x, y, rect)
  if not rect or rect.width <= 0 or rect.height <= 0 then
    return false
  end

  return x >= rect.left and y >= rect.top and x <= rect.left + rect.width and y <= rect.top + rect.height
end

local function hit_test(instance, x, y)
  local rect = instance.layout
  local has_box = rect and rect.width > 0 and rect.height > 0
  local hit = has_box and point_in_rect(x, y, rect)
  local clipped = instance.clip ~= nil
  local inside_clip = not clipped or point_in_rect(x, y, instance.clip)

  if inside_clip and (hit or not has_box or not clipped) then
    for index = #(instance.children or {}), 1, -1 do
      local child, child_rect = hit_test(instance.children[index], x, y)
      if child then
        return child, child_rect
      end
    end
  end

  if hit then
    return instance, rect
  end

  return nil
end

function Runtime:hitTest(x, y, root)
  root = root or self.root
  if not root then
    return nil
  end

  return hit_test(root, x, y)
end

function runtime.create(options)
  options = options or {}

  return setmetatable({
    styles = options.styles,
    renderer = options.renderer,
    root = nil,
  }, Runtime)
end

return runtime
