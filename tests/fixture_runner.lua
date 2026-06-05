local yoga = require("yoga")

local fixture_runner = {}

local function build_node(spec)
  local children = {}

  for index, child in ipairs(spec.children or {}) do
    children[index] = build_node(child)
  end

  return yoga.node(spec.style, children)
end

local function flatten(node, out)
  out[#out + 1] = node

  for _, child in ipairs(node.children or {}) do
    flatten(child, out)
  end

  return out
end

function fixture_runner.register(runner, helper, cases)
  for _, case in ipairs(cases) do
    runner:test("fixture " .. case.name, function()
      local root = build_node(case.root)
      yoga.calculateLayout(root, case.width, case.height)

      local nodes = flatten(root, {})
      helper.assert_equal(#nodes, #case.expect, case.name .. " node count")

      for index, expected in ipairs(case.expect) do
        helper.assert_layout(nodes[index], expected, case.name .. "[" .. index .. "]")
      end
    end)
  end
end

return fixture_runner

