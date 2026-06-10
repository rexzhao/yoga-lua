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

function Animator:_start(instance, delta)
  self.animations[instance] = {
    elapsed = 0,
    duration = self.duration,
    from = delta,
  }
end

function Animator:_syncInstance(instance, seen)
  seen[instance] = true

  local previous = instance.previousLayout
  local current = instance.layout
  if previous and current then
    local delta = {
      x = previous.left - current.left,
      y = previous.top - current.top,
      scaleX = self.animateScale and scale_from(previous.width, current.width) or 1,
      scaleY = self.animateScale and scale_from(previous.height, current.height) or 1,
    }

    if should_animate(delta, self.epsilon, self.animateScale) then
      self:_start(instance, delta)
    end
  end

  for _, child in ipairs(instance.children or {}) do
    self:_syncInstance(child, seen)
  end
end

function Animator:sync(root)
  local seen = {}
  if root then
    self:_syncInstance(root, seen)
  end

  for instance in pairs(self.animations) do
    if not seen[instance] or instance.unmounted then
      self.animations[instance] = nil
    end
  end
end

function Animator:update(dt)
  dt = math.max(0, tonumber(dt) or 0)

  for instance, animation in pairs(self.animations) do
    animation.elapsed = animation.elapsed + dt
    if animation.elapsed >= animation.duration then
      self.animations[instance] = nil
    end
  end
end

function Animator:visual(instance)
  local animation = self.animations[instance]
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

function Animator:rect(instance, left, top, width, height)
  local visual = self:visual(instance)
  if not visual then
    return left, top, width, height
  end

  return left + visual.x, top + visual.y, width * visual.scaleX, height * visual.scaleY
end

function flip.create(options)
  options = options or {}

  return setmetatable({
    duration = math.max(0.0001, tonumber(options.duration) or 0.18),
    ease = resolve_ease(options.ease),
    epsilon = tonumber(options.epsilon) or 0.001,
    animateScale = options.animateScale == true,
    animations = {},
  }, Animator)
end

return flip
