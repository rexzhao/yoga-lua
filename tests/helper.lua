local helper = {}

local Runner = {}
Runner.__index = Runner

function helper.new_runner()
  return setmetatable({
    tests = {},
    skipped = {},
  }, Runner)
end

function Runner:test(name, fn, metadata)
  self.tests[#self.tests + 1] = {
    name = name,
    fn = fn,
    metadata = metadata,
  }
end

function Runner:skip(name, reason, metadata)
  self.skipped[#self.skipped + 1] = {
    name = name,
    reason = reason,
    metadata = metadata,
  }
end

function Runner:run()
  for _, test in ipairs(self.tests) do
    test.fn()
  end

  if #self.skipped > 0 then
    print(string.format("ok - %d tests, %d skipped", #self.tests, #self.skipped))
  else
    print(string.format("ok - %d tests", #self.tests))
  end
end

function helper.assert_equal(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)), 2)
  end
end

function helper.assert_near(actual, expected, label, tolerance)
  tolerance = tolerance or 0.01

  if math.abs(actual - expected) > tolerance then
    error(string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)), 2)
  end
end

function helper.assert_layout(node, expected, label)
  label = label or "layout"

  helper.assert_near(node.layout.left, expected.left, label .. ".left")
  helper.assert_near(node.layout.top, expected.top, label .. ".top")
  helper.assert_near(node.layout.width, expected.width, label .. ".width")
  helper.assert_near(node.layout.height, expected.height, label .. ".height")
end

return helper
