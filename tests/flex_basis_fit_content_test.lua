local yoga = require("yoga")

local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGFlexBasisFitContentTest.html",
    generated = "tests/generated/YGFlexBasisFitContentTest.cpp",
    test = test,
  }
end

return function(runner, helper)
  runner:test("container child can overflow definite column parent", function()
    local grandchild = yoga.node({ height = 500, width = 50 })
    local child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 50, height = 500 }, "grandchild")
  end, source("container_child_overflows_definite_parent_column"))

  runner:test("container child can overflow definite row parent", function()
    local grandchild = yoga.node({ width = 500, height = 50 })
    local child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 300, height = 200, flexDirection = "row" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 300, height = 200 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 500, height = 200 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 500, height = 50 }, "grandchild")
  end, source("container_child_overflows_definite_parent_row"))

  runner:test("scroll container child derives content height", function()
    local grandchild = yoga.node({ height = 500 })
    local child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300, overflow = "scroll" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 500 }, "grandchild")
  end, source("scroll_container_column"))
end
