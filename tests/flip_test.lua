local ui = require("ui")

return function(runner, helper)
  runner:test("flip animator interpolates layout deltas", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local instance = {
      previousLayout = { left = 0, top = 0, width = 20, height = 10 },
      layout = { left = 10, top = 5, width = 20, height = 10 },
      children = {},
    }

    animator:sync(instance)

    local visual = animator:visual(instance)
    helper.assert_near(visual.x, -10, "initial x")
    helper.assert_near(visual.y, -5, "initial y")

    animator:update(0.5)
    visual = animator:visual(instance)
    helper.assert_near(visual.x, -5, "half x")
    helper.assert_near(visual.y, -2.5, "half y")

    animator:update(0.5)
    helper.assert_equal(animator:visual(instance), nil, "finished animation")
  end)

  runner:test("flip animator can animate scale deltas", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear", animateScale = true })
    local instance = {
      previousLayout = { left = 0, top = 0, width = 20, height = 10 },
      layout = { left = 0, top = 0, width = 10, height = 20 },
      children = {},
    }

    animator:sync(instance)

    local visual = animator:visual(instance)
    helper.assert_near(visual.scaleX, 2, "initial scale x")
    helper.assert_near(visual.scaleY, 0.5, "initial scale y")

    animator:update(0.5)
    visual = animator:visual(instance)
    helper.assert_near(visual.scaleX, 1.5, "half scale x")
    helper.assert_near(visual.scaleY, 0.75, "half scale y")
  end)

  runner:test("flip animator ignores unchanged layouts", function()
    local animator = ui.createFlipAnimator({ duration = 1 })
    local instance = {
      previousLayout = { left = 4, top = 8, width = 20, height = 10 },
      layout = { left = 4, top = 8, width = 20, height = 10 },
      children = {},
    }

    animator:sync(instance)

    helper.assert_equal(animator:visual(instance), nil, "unchanged instance has no visual transform")
  end)

  runner:test("flip animator can defer the first update after sync", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear", deferFirstUpdate = true })
    local instance = {
      previousLayout = { left = 0, top = 0, width = 20, height = 10 },
      layout = { left = 10, top = 0, width = 20, height = 10 },
      children = {},
    }

    animator:sync(instance)
    animator:update(2)

    local visual = animator:visual(instance)
    helper.assert_near(visual.x, -10, "deferred first x")

    animator:update(0.5)
    visual = animator:visual(instance)
    helper.assert_near(visual.x, -5, "deferred half x")
  end)

  runner:test("flip animator drops animations for instances outside the synced tree", function()
    local animator = ui.createFlipAnimator({ duration = 1, ease = "linear" })
    local moved = {
      previousLayout = { left = 0, top = 0, width = 10, height = 10 },
      layout = { left = 10, top = 0, width = 10, height = 10 },
      children = {},
    }
    local root = {
      previousLayout = { left = 0, top = 0, width = 20, height = 10 },
      layout = { left = 0, top = 0, width = 20, height = 10 },
      children = { moved },
    }

    animator:sync(root)
    helper.assert_equal(animator:visual(moved) ~= nil, true, "child animation started")

    root.children = {}
    animator:sync(root)
    helper.assert_equal(animator:visual(moved), nil, "removed child animation cleared")
  end)

  runner:test("flip animator only animates instances accepted by filter", function()
    local animator = ui.createFlipAnimator({
      duration = 1,
      ease = "linear",
      filter = function(instance)
        return instance.props and instance.props.flip == true
      end,
    })
    local ignored = {
      props = {},
      previousLayout = { left = 0, top = 0, width = 10, height = 10 },
      layout = { left = 20, top = 0, width = 10, height = 10 },
      children = {},
    }
    local matched = {
      props = { flip = true },
      previousLayout = { left = 0, top = 0, width = 10, height = 10 },
      layout = { left = 20, top = 0, width = 10, height = 10 },
      children = {},
    }
    local root = {
      props = {},
      children = { ignored, matched },
    }

    animator:sync(root)

    helper.assert_equal(animator:visual(ignored), nil, "filtered-out instance")
    helper.assert_equal(animator:visual(matched) ~= nil, true, "matched instance")
  end)

  runner:test("flip animator matches keyed items after parent resize", function()
    local runtime = ui.createRuntime()
    local animator = ui.createFlipAnimator({
      duration = 1,
      ease = "linear",
      filter = function(instance)
        return instance.props and instance.props.flip == true
      end,
    })
    local function grid(width)
      return runtime:div({
        key = "grid",
        style = { width = width, flexDirection = "row", flexWrap = "wrap", gap = 10 },
      }, {
        runtime:div({ key = "item.a", flip = true, style = { width = 100, height = 20 } }),
        runtime:div({ key = "item.b", flip = true, style = { width = 100, height = 20 } }),
        runtime:div({ key = "item.c", flip = true, style = { width = 100, height = 20 } }),
      })
    end

    local root = runtime:render(grid(250))
    local item_b = root.children[2]

    root = runtime:render(grid(180))
    animator:sync(root)

    helper.assert_equal(root.children[2], item_b, "keyed item instance reused after resize")
    helper.assert_equal(animator:visual(item_b) ~= nil, true, "resized keyed item animates")
  end)
end
