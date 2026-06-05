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

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "rtl child")
    helper.assert_layout(grandchild, { left = 150, top = 0, width = 50, height = 500 }, "rtl grandchild")
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

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 300, height = 200 }, "rtl root")
    helper.assert_layout(child, { left = -200, top = 0, width = 500, height = 200 }, "rtl child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 500, height = 50 }, "rtl grandchild")
  end, source("container_child_overflows_definite_parent_row"))

  runner:test("container child within bounds keeps content height", function()
    local grandchild = yoga.node({ height = 100, width = 50 })
    local child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300 }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 100 }, "child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 50, height = 100 }, "grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 100 }, "rtl child")
    helper.assert_layout(grandchild, { left = 150, top = 0, width = 50, height = 100 }, "rtl grandchild")
  end, source("container_child_within_bounds_column"))

  runner:test("multiple container children overflow column parent", function()
    local first_grandchild = yoga.node({ height = 400 })
    local first_child = yoga.node({}, {
      first_grandchild,
    })
    local second_grandchild = yoga.node({ height = 500 })
    local second_child = yoga.node({}, {
      second_grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300 }, {
      first_child,
      second_child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(first_child, { left = 0, top = 0, width = 200, height = 400 }, "first child")
    helper.assert_layout(first_grandchild, { left = 0, top = 0, width = 200, height = 400 }, "first grandchild")
    helper.assert_layout(second_child, { left = 0, top = 400, width = 200, height = 500 }, "second child")
    helper.assert_layout(second_grandchild, { left = 0, top = 0, width = 200, height = 500 }, "second grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(first_child, { left = 0, top = 0, width = 200, height = 400 }, "rtl first child")
    helper.assert_layout(first_grandchild, { left = 0, top = 0, width = 200, height = 400 }, "rtl first grandchild")
    helper.assert_layout(second_child, { left = 0, top = 400, width = 200, height = 500 }, "rtl second child")
    helper.assert_layout(second_grandchild, { left = 0, top = 0, width = 200, height = 500 }, "rtl second grandchild")
  end, source("multiple_container_children_overflow_column"))

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

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "rtl child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 500 }, "rtl grandchild")
  end, source("scroll_container_column"))

  runner:test("explicit and container children overflow column parent", function()
    local fixed_child = yoga.node({ height = 100 })
    local grandchild = yoga.node({ height = 500 })
    local container_child = yoga.node({}, {
      grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300 }, {
      fixed_child,
      container_child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(fixed_child, { left = 0, top = 0, width = 200, height = 100 }, "fixed child")
    helper.assert_layout(container_child, { left = 0, top = 100, width = 200, height = 500 }, "container child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 500 }, "grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(fixed_child, { left = 0, top = 0, width = 200, height = 100 }, "rtl fixed child")
    helper.assert_layout(container_child, { left = 0, top = 100, width = 200, height = 500 }, "rtl container child")
    helper.assert_layout(grandchild, { left = 0, top = 0, width = 200, height = 500 }, "rtl grandchild")
  end, source("explicit_and_container_children_column"))

  runner:test("flex basis contributes to scroll content height", function()
    local first_grandchild = yoga.node({ flexBasis = 200 })
    local second_grandchild = yoga.node({ flexBasis = 300 })
    local child = yoga.node({}, {
      first_grandchild,
      second_grandchild,
    })
    local root = yoga.node({ position = "absolute", width = 200, height = 300, overflow = "scroll" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "child")
    helper.assert_layout(first_grandchild, { left = 0, top = 0, width = 200, height = 200 }, "first grandchild")
    helper.assert_layout(second_grandchild, { left = 0, top = 200, width = 200, height = 300 }, "second grandchild")

    yoga.calculateLayout(root, nil, nil, "rtl")

    helper.assert_layout(root, { left = 0, top = 0, width = 200, height = 300 }, "rtl root")
    helper.assert_layout(child, { left = 0, top = 0, width = 200, height = 500 }, "rtl child")
    helper.assert_layout(first_grandchild, { left = 0, top = 0, width = 200, height = 200 }, "rtl first grandchild")
    helper.assert_layout(second_grandchild, { left = 0, top = 200, width = 200, height = 300 }, "rtl second grandchild")
  end, source("flex_basis_in_scroll_content_container"))
end
