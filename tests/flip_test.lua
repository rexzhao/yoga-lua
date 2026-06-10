local ui = require("ui")

local function node(props, layout, children)
  return {
    props = props or {},
    layout = layout,
    children = children or {},
  }
end

return function(runner, helper)
  runner:test("flip animator interpolates keyed layout deltas", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local first = node({ flip = "box" }, { left = 0, top = 0, width = 20, height = 10 })
    local second = node({ flip = "box" }, { left = 10, top = 5, width = 20, height = 10 })

    animator:sync(first)
    animator:sync(second)

    local visual = animator:visual(second)
    helper.assert_near(visual.x, -10, "initial x")
    helper.assert_near(visual.y, -5, "initial y")

    animator:update(0.5)
    visual = animator:visual(second)
    helper.assert_near(visual.x, -5, "half x")
    helper.assert_near(visual.y, -2.5, "half y")

    animator:update(0.5)
    helper.assert_equal(animator:visual(second), nil, "finished animation")
  end)

  runner:test("flip animator can animate scale deltas", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear", animateScale = true })
    local first = node({ flip = "box" }, { left = 0, top = 0, width = 20, height = 10 })
    local second = node({ flip = "box" }, { left = 0, top = 0, width = 10, height = 20 })

    animator:sync(first)
    animator:sync(second)

    local visual = animator:visual(second)
    helper.assert_near(visual.scaleX, 2, "initial scale x")
    helper.assert_near(visual.scaleY, 0.5, "initial scale y")

    animator:update(0.5)
    visual = animator:visual(second)
    helper.assert_near(visual.scaleX, 1.5, "half scale x")
    helper.assert_near(visual.scaleY, 0.75, "half scale y")
  end)

  runner:test("flip animator ignores unchanged layouts", function()
    local animator = ui.createFlipAnimator({ duration = 1 })
    local first = node({ flip = "box" }, { left = 4, top = 8, width = 20, height = 10 })
    local second = node({ flip = "box" }, { left = 4, top = 8, width = 20, height = 10 })

    animator:sync(first)
    animator:sync(second)

    helper.assert_equal(animator:visual(second), nil, "unchanged instance has no visual transform")
  end)

  runner:test("flip animator can defer the first update after sync", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear", deferFirstUpdate = true })
    local first = node({ flip = "box" }, { left = 0, top = 0, width = 20, height = 10 })
    local second = node({ flip = "box" }, { left = 10, top = 0, width = 20, height = 10 })

    animator:sync(first)
    animator:sync(second)
    animator:update(2)

    local visual = animator:visual(second)
    helper.assert_near(visual.x, -10, "deferred first x")

    animator:update(0.5)
    visual = animator:visual(second)
    helper.assert_near(visual.x, -5, "deferred half x")
  end)

  runner:test("flip animator drops animations for nodes outside the synced tree", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local first = node({}, { left = 0, top = 0, width = 20, height = 10 }, {
      node({ flip = "moved" }, { left = 0, top = 0, width = 10, height = 10 }),
    })
    local moved = node({ flip = "moved" }, { left = 10, top = 0, width = 10, height = 10 })
    local second = node({}, { left = 0, top = 0, width = 20, height = 10 }, { moved })

    animator:sync(first)
    animator:sync(second)
    helper.assert_equal(animator:visual(moved) ~= nil, true, "child animation started")

    local third = node({}, { left = 0, top = 0, width = 20, height = 10 })
    animator:sync(third)
    helper.assert_equal(animator:visual(moved), nil, "removed child animation cleared")
  end)

  runner:test("flip animator only animates instances accepted by filter", function()
    local animator = ui.createFlipAnimator({
      duration = 1,
      ease = "linear",
      filter = function(instance)
        return instance.props and instance.props.animate == true
      end,
    })
    local first = node({}, { left = 0, top = 0, width = 40, height = 10 }, {
      node({ flip = "ignored" }, { left = 0, top = 0, width = 10, height = 10 }),
      node({ flip = "matched", animate = true }, { left = 0, top = 0, width = 10, height = 10 }),
    })
    local ignored = node({ flip = "ignored" }, { left = 20, top = 0, width = 10, height = 10 })
    local matched = node({ flip = "matched", animate = true }, { left = 20, top = 0, width = 10, height = 10 })
    local second = node({}, { left = 0, top = 0, width = 40, height = 10 }, { ignored, matched })

    animator:sync(first)
    animator:sync(second)

    helper.assert_equal(animator:visual(ignored), nil, "filtered-out instance")
    helper.assert_equal(animator:visual(matched) ~= nil, true, "matched instance")
  end)

  runner:test("flip animator returns collected targets", function()
    local animator = ui.createFlipAnimator()
    local root = node({}, { left = 0, top = 0, width = 20, height = 10 }, {
      node({ flip = "item.a" }, { left = 4, top = 2, width = 10, height = 8 }),
    })

    local targets = animator:sync(root)

    helper.assert_equal(#targets, 1, "target count")
    helper.assert_equal(targets[1].key, "item.a", "target key")
    helper.assert_equal(targets[1].rect.left, 4, "target rect left")
  end)

  runner:test("flip animator measures children in flip scope local coordinates", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local first = node({}, { left = 0, top = 0, width = 200, height = 100 }, {
      node({ flipScope = "grid" }, { left = 10, top = 0, width = 100, height = 100 }, {
        node({ flip = "item" }, { left = 20, top = 0, width = 10, height = 10 }),
      }),
    })
    local item = node({ flip = "item" }, { left = 70, top = 0, width = 10, height = 10 })
    local second = node({}, { left = 0, top = 0, width = 200, height = 100 }, {
      node({ flipScope = "grid" }, { left = 50, top = 0, width = 100, height = 100 }, { item }),
    })

    animator:sync(first)
    animator:sync(second)

    local visual = animator:visual(item)
    helper.assert_near(visual.x, -10, "scoped x excludes parent movement")
  end)

  runner:test("flip animator matches keyed items after parent resize", function()
    local runtime = ui.createRuntime()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local function grid(width)
      return runtime:div({
        key = "grid",
        flipScope = "grid",
        style = { width = width, flexDirection = "row", flexWrap = "wrap", gap = 10 },
      }, {
        runtime:div({ flip = "item.a", style = { width = 100, height = 20 } }),
        runtime:div({ flip = "item.b", style = { width = 100, height = 20 } }),
        runtime:div({ flip = "item.c", style = { width = 100, height = 20 } }),
      })
    end

    local root = runtime:render(grid(250))
    local item_b = root.children[2]
    animator:sync(root)

    root = runtime:render(grid(180))
    animator:sync(root)

    helper.assert_equal(root.children[2], item_b, "flip key reuses item instance after resize")
    helper.assert_equal(animator:visual(item_b) ~= nil, true, "resized keyed item animates")
  end)
end
