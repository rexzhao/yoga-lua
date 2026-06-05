local yoga = require("yoga")

local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "YGHadOverflowTest.cpp",
    generated = false,
    test = test,
  }
end

local function had_overflow_root(children)
  return yoga.node({
    width = 200,
    height = 100,
    flexDirection = "column",
    flexWrap = "nowrap",
  }, children)
end

return function(runner, helper)
  runner:test("hadOverflow is true when children overflow without wrapping", function()
    local root = had_overflow_root({
      yoga.node({ width = 80, height = 40, marginTop = 10, marginBottom = 15 }),
      yoga.node({ width = 80, height = 40, marginBottom = 5 }),
    })

    yoga.calculateLayout(root, 200, 100)

    helper.assert_equal(root.layout.hadOverflow, true, "root hadOverflow")
    helper.assert_equal(yoga.hadOverflow(root), true, "hadOverflow api")
  end, source("children_overflow_no_wrap_and_no_flex_children"))

  runner:test("hadOverflow includes overflowing spacing", function()
    local root = had_overflow_root({
      yoga.node({ width = 80, height = 40, marginTop = 10, marginBottom = 10 }),
      yoga.node({ width = 80, height = 40, marginBottom = 5 }),
    })

    yoga.calculateLayout(root, 200, 100)

    helper.assert_equal(root.layout.hadOverflow, true, "spacing overflow")
  end, source("spacing_overflow_no_wrap_and_no_flex_children"))

  runner:test("hadOverflow stays false when flex shrink avoids overflow", function()
    local root = had_overflow_root({
      yoga.node({ width = 80, height = 40, marginTop = 10, marginBottom = 10 }),
      yoga.node({ width = 80, height = 40, marginBottom = 5, flexShrink = 1 }),
    })

    yoga.calculateLayout(root, 200, 100)

    helper.assert_equal(root.layout.hadOverflow, false, "no overflow")
  end, source("no_overflow_no_wrap_and_flex_children"))

  runner:test("hadOverflow resets after relayout removes overflow", function()
    local child = yoga.node({ width = 80, height = 40, marginBottom = 5 })
    local root = had_overflow_root({
      yoga.node({ width = 80, height = 40, marginTop = 10, marginBottom = 10 }),
      child,
    })

    yoga.calculateLayout(root, 200, 100)
    helper.assert_equal(root.layout.hadOverflow, true, "initial overflow")

    yoga.updateStyle(child, { flexShrink = 1 })
    yoga.calculateLayout(root, 200, 100)

    helper.assert_equal(root.layout.hadOverflow, false, "overflow reset")
  end, source("hadOverflow_gets_reset_if_not_logger_valid"))

  runner:test("hadOverflow propagates from nested nodes", function()
    local root = had_overflow_root({
      yoga.node({ width = 80, height = 40, marginTop = 10, marginBottom = 10 }),
      yoga.node({ width = 80, height = 40 }, {
        yoga.node({ width = 80, height = 40, marginBottom = 5 }),
      }),
    })

    yoga.calculateLayout(root, 200, 100)

    helper.assert_equal(root.children[2].layout.hadOverflow, true, "nested child overflow")
    helper.assert_equal(root.layout.hadOverflow, true, "nested overflow propagated")
  end, source("spacing_overflow_in_nested_nodes"))
end
