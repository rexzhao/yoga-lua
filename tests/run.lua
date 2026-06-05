package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")
local ui = require("ui")

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)), 2)
  end
end

local function test_core_fixed_layout()
  local root = yoga.node({ width = 100, height = 80, flexDirection = "column", padding = 10, gap = 5 }, {
    yoga.node({ height = 20 }),
    yoga.node({ height = 30 }),
  })

  yoga.calculateLayout(root)

  assert_equal(root.layout.width, 100, "root width")
  assert_equal(root.layout.height, 80, "root height")
  assert_equal(root.children[1].layout.left, 10, "first child left")
  assert_equal(root.children[1].layout.top, 10, "first child top")
  assert_equal(root.children[1].layout.width, 80, "first child width")
  assert_equal(root.children[2].layout.top, 35, "second child top")
end

local function test_component_style_merge()
  local styles = ui.stylesheet({
    screen = { width = 320, height = 240, flexDirection = "row", padding = 8, gap = 4 },
    sidebar = { width = 64 },
  })

  local root = ui.div({ class = "screen", styles = styles }, {
    ui.div({ class = "sidebar", styles = styles }),
    ui.div({ style = { width = 100 } }),
  })

  yoga.calculateLayout(root)

  assert_equal(root.type, "div", "root type")
  assert_equal(root.layout.width, 320, "component root width")
  assert_equal(root.children[1].layout.width, 64, "class width")
  assert_equal(root.children[2].layout.left, 76, "second component left")
end

local function test_love2d_example_syntax()
  assert(loadfile("examples/love2d/conf.lua"))
  assert(loadfile("examples/love2d/main.lua"))
end

local tests = {
  test_core_fixed_layout,
  test_component_style_merge,
  test_love2d_example_syntax,
}

for _, test in ipairs(tests) do
  test()
end

print(string.format("ok - %d tests", #tests))
