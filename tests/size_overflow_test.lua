local yoga = require("yoga")

local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGSizeOverflowTest.html",
    generated = "tests/generated/YGSizeOverflowTest.cpp",
    test = test,
  }
end

return function(runner, helper)
  runner:test("nested overflowing child sizes parent from content", function()
    local grandchild = yoga.node({ height = 200, width = 200 })
    local child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", height = 100, width = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 200 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 200 }, "grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 200 }, "rtl child")
    helper.assert_layout(grandchild, { left = -100, top = 0, width = 200, height = 200 }, "rtl grandchild")
  end, source("nested_overflowing_child"))

  runner:test("nested overflowing child keeps constrained parent size", function()
    local grandchild = yoga.node({ height = 200, width = 200 })
    local child = yoga.node({ height = 100, width = 100 }, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", height = 100, width = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 100 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 200 }, "grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 100 }, "rtl child")
    helper.assert_layout(grandchild, { left = -100, top = 0, width = 200, height = 200 }, "rtl grandchild")
  end, source("nested_overflowing_child_in_constraint_parent"))

  runner:test("parent wraps child size overflowing parent", function()
    local grandchild = yoga.node({ width = 100, height = 200 })
    local child = yoga.node({ width = 100 }, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 100, height = 100 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 200 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 100, height = 200 }, "grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 100, height = 100 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 100, height = 200 }, "rtl child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 100, height = 200 }, "rtl grandchild")
  end, source("parent_wrap_child_size_overflowing_parent"))
end
