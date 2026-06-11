local yoga = require("yoga")
local ui = require("ui")

return function(runner, helper)
  runner:test("runtime mounts virtual elements with external styles", function()
    local styles = ui.stylesheet({
      screen = { width = 200, height = 80, flexDirection = "column" },
      compact = { height = 40 },
      label = { height = 20 },
    })
    local runtime = ui.createRuntime({ styles = styles })

    local root = runtime:render(runtime:div({ class = { "screen", false, "compact" } }, {
      runtime:text("Hello", { class = "label" }),
    }))

    helper.assert_equal(root.type, "div", "root instance type")
    helper.assert_equal(root.yogaNode.type, "div", "root node type")
    helper.assert_equal(root.yogaNode.style.width, 200, "external class width")
    helper.assert_equal(root.yogaNode.style.height, 40, "later class height")
    helper.assert_equal(root.children[1].yogaNode.text, "Hello", "text node value")
    helper.assert_layout(root.yogaNode, { left = 0, top = 0, width = 200, height = 40 }, "runtime root")
    helper.assert_layout(root.children[1].yogaNode, { left = 0, top = 0, width = 200, height = 20 }, "runtime text")
  end)

  runner:test("runtime reuses keyed child instances across insertion deletion and reorder", function()
    local mounts = 0
    local unmounted = {}
    local renderer = {}

    function renderer:mount(instance)
      mounts = mounts + 1
      return { mountId = mounts, key = instance.key }
    end

    function renderer:unmount(instance)
      unmounted[instance.key or instance.path] = true
    end

    local runtime = ui.createRuntime({ renderer = renderer })
    local function item(id)
      return runtime:div({ key = id, style = { width = 10, height = 10 }, itemId = id })
    end

    local root = runtime:render(runtime:div({ style = { width = 30, height = 10, flexDirection = "row" } }, {
      item("a"),
      item("b"),
      item("c"),
    }))

    local a = root.children[1]
    local b = root.children[2]
    local c = root.children[3]

    root = runtime:render(runtime:div({ style = { width = 30, height = 10, flexDirection = "row" } }, {
      item("c"),
      item("a"),
      item("d"),
    }))

    helper.assert_equal(root.children[1], c, "c instance reused after reorder")
    helper.assert_equal(root.children[2], a, "a instance reused after reorder")
    helper.assert_equal(root.children[3].key, "d", "new d instance mounted")
    helper.assert_equal(b.unmounted, true, "removed b instance marked unmounted")
    helper.assert_equal(unmounted.b, true, "renderer unmounted removed b")
    helper.assert_equal(mounts, 5, "mount count includes root, initial items, and new d")
  end)

  runner:test("runtime reuses unkeyed static children by type and index", function()
    local runtime = ui.createRuntime()

    local root = runtime:render(runtime:div({ style = { width = 100, height = 40 } }, {
      runtime:div({ style = { height = 20 } }),
      runtime:text("One", { style = { height = 20 } }),
    }))
    local first = root.children[1]
    local second = root.children[2]

    root = runtime:render(runtime:div({ style = { width = 100, height = 40 } }, {
      runtime:div({ style = { height = 20 }, fill = { 1, 0, 0, 1 } }),
      runtime:text("Two", { style = { height = 20 } }),
    }))

    helper.assert_equal(root.children[1], first, "unkeyed div reused")
    helper.assert_equal(root.children[2], second, "unkeyed text reused")
    helper.assert_equal(root.children[2].yogaNode.text, "Two", "text metadata updated")
  end)

  runner:test("runtime remounts unkeyed children when type changes", function()
    local unmounted = {}
    local renderer = {}

    function renderer:unmount(instance)
      unmounted[instance.path] = true
    end

    local runtime = ui.createRuntime({ renderer = renderer })
    local root = runtime:render(runtime:div({ style = { width = 100, height = 40 } }, {
      runtime:div({ style = { height = 20 } }),
    }))
    local old_child = root.children[1]

    root = runtime:render(runtime:div({ style = { width = 100, height = 40 } }, {
      runtime:text("Replacement", { style = { height = 20 } }),
    }))

    helper.assert_equal(root.children[1] == old_child, false, "changed type gets a new instance")
    helper.assert_equal(old_child.unmounted, true, "old changed-type child unmounted")
    helper.assert_equal(unmounted["root/1"], true, "renderer saw changed-type unmount")
  end)

  runner:test("runtime prop-only updates do not force layout", function()
    local styles = ui.stylesheet({
      box = { width = 100, height = 20 },
    })
    local runtime = ui.createRuntime({ styles = styles })

    runtime:render(runtime:div({ key = "box", class = "box", fill = { 1, 0, 0, 1 } }))
    yoga._resetDebugStats()
    runtime:render(runtime:div({ key = "box", class = "box", fill = { 0, 1, 0, 1 } }))

    local stats = yoga._debugStats()
    helper.assert_equal(stats.layoutNodes, 0, "prop-only update layout nodes")
    helper.assert_equal(runtime.root.yogaNode.dirty, false, "prop-only update keeps root clean")
    yoga._clearDebugStats()
  end)

  runner:test("runtime style updates dirty and relayout reused instances", function()
    local styles = ui.stylesheet({
      box = { width = 100, height = 20 },
    })
    local runtime = ui.createRuntime({ styles = styles })

    local root = runtime:render(runtime:div({ key = "box", class = "box" }))
    yoga._resetDebugStats()
    root = runtime:render(runtime:div({ key = "box", class = "box", style = { width = 120 } }))

    local stats = yoga._debugStats()
    helper.assert_equal(stats.layoutNodes > 0, true, "style update relayouts nodes")
    helper.assert_equal(root.yogaNode.style.width, 120, "style update applied")
    helper.assert_layout(root.yogaNode, { left = 0, top = 0, width = 120, height = 20 }, "style updated root")
    yoga._clearDebugStats()
  end)

  runner:test("runtime records previous and current layout snapshots for reused instances", function()
    local runtime = ui.createRuntime()

    local root = runtime:render(runtime:div({ key = "root", style = { width = 100, height = 20 } }))
    helper.assert_equal(root.layout.width, 100, "initial layout snapshot")

    root = runtime:render(runtime:div({ key = "root", style = { width = 120, height = 20 } }))

    helper.assert_equal(root.previousLayout.width, 100, "previous layout snapshot")
    helper.assert_equal(root.layout.width, 120, "current layout snapshot")
  end)

  runner:test("runtime can refresh layout snapshots after renderer coordinate adjustment", function()
    local runtime = ui.createRuntime()
    local root = runtime:render(runtime:div({ key = "root", style = { width = 100, height = 20 } }))

    root.yogaNode.layout.top = 42
    runtime:snapshotLayout("layout")

    helper.assert_equal(root.layout.top, 42, "refreshed adjusted top")
  end)

  runner:test("runtime scrollView offsets child snapshots and exposes clip metrics", function()
    local runtime = ui.createRuntime()
    local root = runtime:render(runtime:scrollView({
      scrollOffset = 30,
      style = { width = 100, height = 50 },
    }, {
      runtime:div({ key = "first", style = { height = 40 } }),
      runtime:div({ key = "second", style = { height = 40 } }),
      runtime:div({ key = "third", style = { height = 40 } }),
    }), 100, 50)

    helper.assert_equal(root.scroll.viewportHeight, 50, "viewport height")
    helper.assert_equal(root.scroll.contentHeight, 120, "content height")
    helper.assert_equal(root.scroll.maxScroll, 70, "max scroll")
    helper.assert_equal(root.scroll.scrollOffset, 30, "scroll offset")
    helper.assert_equal(root.clip.left, 0, "clip left")
    helper.assert_equal(root.clip.top, 0, "clip top")
    helper.assert_equal(root.clip.width, 100, "clip width")
    helper.assert_equal(root.clip.height, 50, "clip height")
    helper.assert_equal(root.scroll.clip, root.clip, "scroll metrics clip")
    helper.assert_equal(root.children[1].layout.top, -30, "first child scrolled up")
    helper.assert_equal(root.children[2].layout.top, 10, "second child scrolled up")
    helper.assert_equal(root.children[3].layout.top, 50, "third child scrolled up")
  end)

  runner:test("runtime scrollView clamps child snapshots to max scroll", function()
    local runtime = ui.createRuntime()
    local root = runtime:render(runtime:scrollView({
      scrollOffset = 1000,
      style = { width = 100, height = 50 },
    }, {
      runtime:div({ key = "first", style = { height = 40 } }),
      runtime:div({ key = "second", style = { height = 40 } }),
      runtime:div({ key = "third", style = { height = 40 } }),
    }), 100, 50)

    helper.assert_equal(root.scroll.maxScroll, 70, "max scroll")
    helper.assert_equal(root.scroll.scrollOffset, 70, "oversized offset clamped")
    helper.assert_equal(root.children[1].layout.top, -70, "first child clamped position")
    helper.assert_equal(root.children[3].layout.top, 10, "third child clamped position")
  end)

  runner:test("runtime hitTest ignores scrollView children outside the clip", function()
    local runtime = ui.createRuntime()
    local root = runtime:render(runtime:scrollView({
      scrollOffset = 30,
      style = { width = 100, height = 50 },
    }, {
      runtime:div({ key = "first", style = { height = 40 } }),
      runtime:div({ key = "second", style = { height = 40 } }),
      runtime:button("Hidden", { key = "third", style = { height = 40 } }),
    }), 100, 50)

    local hit = runtime:hitTest(10, 5)
    helper.assert_equal(hit.key, "first", "visible scrolled child hit")

    hit = runtime:hitTest(10, 45)
    helper.assert_equal(hit.key, "second", "visible lower child hit")

    hit = runtime:hitTest(10, 55)
    helper.assert_equal(hit, nil, "below viewport clipped")

    hit = runtime:hitTest(10, -5)
    helper.assert_equal(hit, nil, "above viewport clipped")

    helper.assert_equal(root.children[3].layout.top, 50, "third child sits outside viewport")
  end)

  runner:test("runtime scrollView recomputes metrics after dynamic children change", function()
    local runtime = ui.createRuntime()

    local function build(child_count)
      local children = {}
      for index = 1, child_count do
        children[#children + 1] = runtime:div({ key = tostring(index), style = { height = 40 } })
      end

      return runtime:scrollView({
        key = "scroll",
        scrollOffset = 1000,
        style = { width = 100, height = 50 },
      }, children)
    end

    local root = runtime:render(build(3), 100, 50)
    helper.assert_equal(root.scroll.contentHeight, 120, "initial content height")
    helper.assert_equal(root.scroll.maxScroll, 70, "initial max scroll")
    helper.assert_equal(root.scroll.scrollOffset, 70, "initial clamped offset")

    root = runtime:render(build(1), 100, 50)
    helper.assert_equal(root.scroll.contentHeight, 40, "updated content height")
    helper.assert_equal(root.scroll.maxScroll, 0, "updated max scroll")
    helper.assert_equal(root.scroll.scrollOffset, 0, "updated clamped offset")
    helper.assert_equal(#root.children, 1, "children updated")
  end)

  runner:test("runtime styles demo builds without per-node styles props", function()
    local demo = assert(loadfile("examples/runtime_styles.lua"))()
    local root = demo.build(true)

    helper.assert_equal(root.yogaNode.style.height, 140, "active screen class")
    helper.assert_equal(root.children[2].children[1].yogaNode.style.width, 124, "active button class")
    helper.assert_layout(root.yogaNode, { left = 0, top = 0, width = 320, height = 140 }, "runtime styles demo")
  end)
end
