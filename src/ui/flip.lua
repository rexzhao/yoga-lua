local flip = {}

local Animator = {}
Animator.__index = Animator

local function clamp(value, minimum, maximum)
  if value < minimum then
    return minimum
  end

  if value > maximum then
    return maximum
  end

  return value
end

local function resolve_ease(ease)
  if type(ease) == "function" then
    return ease
  end

  if ease == "outCubic" then
    return function(t)
      local inverse = 1 - t
      return 1 - inverse * inverse * inverse
    end
  end

  return function(t)
    return t
  end
end

local function is_significant(value, epsilon)
  return math.abs(value) > epsilon
end

local function scale_from(previous_size, current_size)
  if previous_size <= 0 or current_size <= 0 then
    return 1
  end

  return previous_size / current_size
end

local function should_animate(delta, epsilon, animate_scale)
  if is_significant(delta.x, epsilon) or is_significant(delta.y, epsilon) then
    return true
  end

  if animate_scale then
    return is_significant(delta.scaleX - 1, epsilon) or is_significant(delta.scaleY - 1, epsilon)
  end

  return false
end

local function props_key(props, name)
  local value = props and props[name]

  if type(value) == "table" then
    value = value.key
  end

  if value == nil or type(value) == "boolean" then
    return nil
  end

  return tostring(value)
end

local function flip_key(instance)
  local props = instance.props or {}
  return props_key(props, "flip") or (props.flip == true and instance.key and tostring(instance.key)) or nil
end

local function scope_key(instance)
  return props_key(instance.props, "flipScope")
end

local function scoped_rect(instance, scope)
  local layout = instance.layout
  if not layout then
    return nil
  end

  local scope_layout = scope and scope.layout
  local scope_left = (scope_layout and scope_layout.left) or 0
  local scope_top = (scope_layout and scope_layout.top) or 0

  return {
    left = layout.left - scope_left,
    top = layout.top - scope_top,
    width = layout.width,
    height = layout.height,
  }
end

local function token_for(scope, key)
  local scope_key_value = (scope and scope.key) or "root"
  return tostring(scope_key_value) .. "\0" .. tostring(key)
end

function Animator:_start(token, instance, delta)
  self.animations[token] = {
    instance = instance,
    elapsed = 0,
    duration = self.duration,
    pendingUpdate = self.deferFirstUpdate,
    from = delta,
  }
end

function Animator:_accept(instance, key, scope)
  if not key then
    return false
  end

  if self.filter then
    return self.filter(instance, key, scope and scope.key) ~= false
  end

  return true
end

function Animator:_collectInstance(instance, scope, records, ordered)
  local key = flip_key(instance)
  local rect = key and scoped_rect(instance, scope)

  if rect and self:_accept(instance, key, scope) then
    local token = token_for(scope, key)
    local record = {
      token = token,
      key = key,
      scope = (scope and scope.key) or "root",
      instance = instance,
      rect = rect,
    }

    records[token] = record
    ordered[#ordered + 1] = record
  end

  local child_scope = scope
  local next_scope_key = scope_key(instance)
  if next_scope_key and instance.layout then
    child_scope = {
      key = next_scope_key,
      layout = instance.layout,
    }
  end

  for _, child in ipairs(instance.children or {}) do
    self:_collectInstance(child, child_scope, records, ordered)
  end
end

function Animator:sync(root)
  local records = {}
  local ordered = {}
  local seen = {}

  if root then
    self:_collectInstance(root, { key = "root", layout = { left = 0, top = 0 } }, records, ordered)
  end

  self.instanceTokens = {}

  for token, record in pairs(records) do
    seen[token] = true
    self.instanceTokens[record.instance] = token

    local animation = self.animations[token]
    if animation then
      animation.instance = record.instance
    end

    local previous = self.lastRects[token]
    local current = record.rect
    if previous and current then
      local delta = {
        x = previous.left - current.left,
        y = previous.top - current.top,
        scaleX = self.animateScale and scale_from(previous.width, current.width) or 1,
        scaleY = self.animateScale and scale_from(previous.height, current.height) or 1,
      }

      if should_animate(delta, self.epsilon, self.animateScale) then
        self:_start(token, record.instance, delta)
      end
    end
  end

  for token, animation in pairs(self.animations) do
    if not seen[token] or (animation.instance and animation.instance.unmounted) then
      self.animations[token] = nil
    end
  end

  self.lastRects = {}
  for token, record in pairs(records) do
    self.lastRects[token] = record.rect
  end
  self.current = ordered

  return ordered
end

function Animator:update(dt)
  dt = math.max(0, tonumber(dt) or 0)

  for token, animation in pairs(self.animations) do
    if animation.pendingUpdate then
      animation.pendingUpdate = false
    else
      animation.elapsed = animation.elapsed + dt
      if animation.elapsed >= animation.duration then
        self.animations[token] = nil
      end
    end
  end
end

function Animator:visual(instance)
  local token = type(instance) == "string" and instance or self.instanceTokens[instance]
  local animation = token and self.animations[token]
  if not animation then
    return nil
  end

  local duration = math.max(animation.duration, self.epsilon)
  local t = clamp(animation.elapsed / duration, 0, 1)
  local progress = self.ease(t)
  local remaining = 1 - progress
  local from = animation.from

  return {
    x = from.x * remaining,
    y = from.y * remaining,
    scaleX = 1 + (from.scaleX - 1) * remaining,
    scaleY = 1 + (from.scaleY - 1) * remaining,
  }
end

function Animator:targets()
  return self.current or {}
end

function Animator:rect(instance, left, top, width, height)
  local visual = self:visual(instance)
  if not visual then
    return left, top, width, height
  end

  return left + visual.x, top + visual.y, width * visual.scaleX, height * visual.scaleY
end

function flip.create(options)
  options = options or {}
  local filter = type(options.filter) == "function" and options.filter or nil

  return setmetatable({
    duration = math.max(0.0001, tonumber(options.duration) or 0.18),
    ease = resolve_ease(options.ease),
    epsilon = tonumber(options.epsilon) or 0.001,
    animateScale = options.animateScale == true,
    deferFirstUpdate = options.deferFirstUpdate == true,
    filter = filter,
    animations = {},
    instanceTokens = {},
    lastRects = {},
    current = {},
  }, Animator)
end

return flip
