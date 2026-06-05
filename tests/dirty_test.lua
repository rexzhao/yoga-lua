local yoga = require("yoga")

return function(runner, helper)
  runner:test("markDirty marks node and ancestors dirty", function()
    local child = yoga.node({ width = 20, height = 10 })
    local root = yoga.node({ width = 100, height = 20 }, {
      child,
    })

    yoga.calculateLayout(root)
    yoga.markDirty(child)

    helper.assert_equal(child.dirty, true, "marked child dirty")
    helper.assert_equal(root.dirty, true, "marked ancestor dirty")
  end)

  runner:test("setStyle marks node and ancestors dirty", function()
    local child = yoga.node({ width = 20, height = 10 })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row" }, {
      child,
    })

    yoga.calculateLayout(root)

    helper.assert_equal(root.dirty, false, "root clean after layout")
    helper.assert_equal(child.dirty, false, "child clean after layout")

    yoga.setStyle(child, { width = 60, height = 10 })

    helper.assert_equal(child.dirty, true, "changed child dirty")
    helper.assert_equal(root.dirty, true, "ancestor dirty")

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 60, height = 10 }, "relayout child")
    helper.assert_equal(root.dirty, false, "root clean after relayout")
    helper.assert_equal(child.dirty, false, "child clean after relayout")
  end)

  runner:test("updateStyle preserves other style fields and marks ancestors dirty", function()
    local child = yoga.node({ width = 20, height = 10 })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row" }, {
      child,
    })

    yoga.calculateLayout(root)
    yoga.updateStyle(child, { width = 40 })

    helper.assert_equal(child.style.height, 10, "unchanged style field")
    helper.assert_equal(child.dirty, true, "updated child dirty")
    helper.assert_equal(root.dirty, true, "updated ancestor dirty")

    yoga.calculateLayout(root)

    helper.assert_layout(child, { left = 0, top = 0, width = 40, height = 10 }, "updated child layout")
  end)

  runner:test("insertChild and removeChild maintain parents and dirty flags", function()
    local first = yoga.node({ width = 20, height = 10 })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row" }, {
      first,
    })

    yoga.calculateLayout(root)

    local second = yoga.node({ width = 30, height = 10 })
    yoga.appendChild(root, second)

    helper.assert_equal(second.parent, root, "inserted parent")
    helper.assert_equal(second.dirty, true, "inserted child dirty")
    helper.assert_equal(root.dirty, true, "parent dirty after insert")

    yoga.calculateLayout(root)

    helper.assert_layout(second, { left = 20, top = 0, width = 30, height = 10 }, "inserted child layout")

    local removed = yoga.removeChild(root, first)

    helper.assert_equal(removed, first, "removed child")
    helper.assert_equal(first.parent, nil, "removed parent cleared")
    helper.assert_equal(first.dirty, true, "removed child dirty")
    helper.assert_equal(root.dirty, true, "parent dirty after remove")

    yoga.calculateLayout(root)

    helper.assert_layout(second, { left = 0, top = 0, width = 30, height = 10 }, "remaining child relayout")
  end)

  runner:test("setChildren detaches old children and dirties new subtree", function()
    local old_child = yoga.node({ width = 20, height = 10 })
    local root = yoga.node({ width = 100, height = 20, flexDirection = "row" }, {
      old_child,
    })

    yoga.calculateLayout(root)

    local new_grandchild = yoga.node({ width = 15, height = 10 })
    local new_child = yoga.node({ width = 15, height = 10, flexDirection = "row" }, {
      new_grandchild,
    })

    yoga.setChildren(root, {
      new_child,
    })

    helper.assert_equal(old_child.parent, nil, "old parent cleared")
    helper.assert_equal(old_child.dirty, true, "old child dirty")
    helper.assert_equal(new_child.parent, root, "new parent")
    helper.assert_equal(new_child.dirty, true, "new child dirty")
    helper.assert_equal(new_grandchild.dirty, true, "new grandchild dirty")
    helper.assert_equal(root.dirty, true, "root dirty after children replacement")

    yoga.calculateLayout(root)

    helper.assert_layout(new_child, { left = 0, top = 0, width = 15, height = 10 }, "new child layout")
    helper.assert_layout(new_grandchild, { left = 0, top = 0, width = 15, height = 10 }, "new grandchild layout")
  end)
end
