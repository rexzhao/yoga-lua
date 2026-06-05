local yoga = require("yoga")

local ui = {}

local function is_array(value)
  if type(value) ~= "table" then
    return false
  end

  return value[1] ~= nil or next(value) == nil
end

local function merge_style(props)
  props = props or {}
  local style = {}
  local styles = props.styles
  local class = props.class

  if styles and class then
    local class_style = styles[class]
    if class_style then
      for key, value in pairs(class_style) do
        style[key] = value
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

function ui.stylesheet(definitions)
  return definitions or {}
end

function ui.div(props, children)
  props, children = normalize_args(props, children)
  local node = yoga.node(merge_style(props), children)
  node.type = "div"
  node.props = props
  return node
end

function ui.text(value, props)
  props = props or {}
  local node = yoga.node(merge_style(props), {})
  node.type = "text"
  node.text = value
  node.props = props
  return node
end

function ui.image(props)
  props = props or {}
  local node = yoga.node(merge_style(props), {})
  node.type = "image"
  node.props = props
  return node
end

function ui.button(label, props)
  props = props or {}
  local node = yoga.node(merge_style(props), {
    ui.text(label),
  })
  node.type = "button"
  node.label = label
  node.props = props
  return node
end

return ui

