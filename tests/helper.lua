local helper = {}

local Runner = {}
Runner.__index = Runner

function helper.new_runner()
  return setmetatable({
    tests = {},
  }, Runner)
end

function Runner:test(name, fn)
  self.tests[#self.tests + 1] = {
    name = name,
    fn = fn,
  }
end

function Runner:run()
  for _, test in ipairs(self.tests) do
    test.fn()
  end

  print(string.format("ok - %d tests", #self.tests))
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

