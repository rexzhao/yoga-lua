package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")
local ui = require("ui")

local sizes = { 100, 1000, 5000 }
local incremental_size = 5000
local measured_incremental_size = 1000
local iterations = tonumber(arg and arg[1]) or 20

local function make_leaf(index)
  return yoga.node({
    width = 18 + (index % 7),
    height = 12 + (index % 5),
    marginRight = index % 3,
    marginBottom = index % 4,
  })
end

local function make_tree(count)
  local rows = {}
  local leaves = {}
  local remaining = count
  local index = 1

  while remaining > 0 do
    local row_count = math.min(10, remaining)
    local row_children = {}

    for child_index = 1, row_count do
      local leaf = make_leaf(index)
      leaves[#leaves + 1] = leaf
      row_children[child_index] = leaf
      index = index + 1
    end

    rows[#rows + 1] = yoga.node({
      flexDirection = "row",
      height = 24,
      gap = 2,
      marginBottom = 2,
    }, row_children)
    remaining = remaining - row_count
  end

  return yoga.node({
    width = 640,
    flexDirection = "column",
    padding = 8,
    gap = 2,
  }, rows), leaves, rows
end

local function make_measured_leaf(index, counter)
  return yoga.node({
    marginRight = index % 3,
    marginBottom = index % 4,
    measure = function()
      counter.calls = counter.calls + 1
      return {
        width = 18 + (index % 7),
        height = 12 + (index % 5),
      }
    end,
  })
end

local function make_measured_tree(count)
  local rows = {}
  local leaves = {}
  local counter = { calls = 0 }
  local remaining = count
  local index = 1

  while remaining > 0 do
    local row_count = math.min(10, remaining)
    local row_children = {}

    for child_index = 1, row_count do
      local leaf = make_measured_leaf(index, counter)
      leaves[#leaves + 1] = leaf
      row_children[child_index] = leaf
      index = index + 1
    end

    rows[#rows + 1] = yoga.node({
      flexDirection = "row",
      alignItems = "flex-start",
      height = 24,
      gap = 2,
      marginBottom = 2,
    }, row_children)
    remaining = remaining - row_count
  end

  return yoga.node({
    width = 640,
    flexDirection = "column",
    padding = 8,
    gap = 2,
  }, rows), leaves, counter
end

local function benchmark(count)
  local root = make_tree(count)

  yoga.calculateLayout(root)

  local start = os.clock()
  for _ = 1, iterations do
    yoga.markDirty(root)
    yoga.calculateLayout(root)
  end
  local elapsed = os.clock() - start

  return {
    count = count,
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    width = root.layout.width,
    height = root.layout.height,
  }
end

local function time_incremental(root, step)
  yoga.calculateLayout(root)

  local start = os.clock()
  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end
  local elapsed = os.clock() - start

  return {
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    width = root.layout.width,
    height = root.layout.height,
  }
end

local function benchmark_incremental(count)
  local clean_root = make_tree(count)
  local clean = time_incremental(clean_root, function() end)

  local root_dirty_root = make_tree(count)
  local root_dirty = time_incremental(root_dirty_root, function()
    yoga.markDirty(root_dirty_root)
  end)

  local leaf_dirty_root, leaf_dirty_leaves = make_tree(count)
  local dirty_leaf = leaf_dirty_leaves[math.floor(#leaf_dirty_leaves / 2)]
  local leaf_dirty = time_incremental(leaf_dirty_root, function()
    yoga.markDirty(dirty_leaf)
  end)

  local style_change_root, style_change_leaves = make_tree(count)
  local styled_leaf = style_change_leaves[math.floor(#style_change_leaves / 2)]
  local style_updates = {
    { width = 20 },
    { width = 21 },
  }
  local style_change = time_incremental(style_change_root, function(index)
    yoga.updateStyle(styled_leaf, style_updates[(index % 2) + 1])
  end)

  return {
    count = count,
    clean = clean,
    rootDirty = root_dirty,
    leafDirty = leaf_dirty,
    styleChange = style_change,
  }
end

local function time_measured_incremental(root, counter, step)
  yoga.calculateLayout(root)
  counter.calls = 0

  local start = os.clock()
  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end
  local elapsed = os.clock() - start

  return {
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    measureCalls = counter.calls,
    width = root.layout.width,
    height = root.layout.height,
  }
end

local function benchmark_measured_incremental(count)
  local root_dirty_root, _, root_dirty_counter = make_measured_tree(count)
  local root_dirty = time_measured_incremental(root_dirty_root, root_dirty_counter, function()
    yoga.markDirty(root_dirty_root)
  end)

  local leaf_dirty_root, leaf_dirty_leaves, leaf_dirty_counter = make_measured_tree(count)
  local dirty_leaf = leaf_dirty_leaves[math.floor(#leaf_dirty_leaves / 2)]
  local leaf_dirty = time_measured_incremental(leaf_dirty_root, leaf_dirty_counter, function()
    yoga.markDirty(dirty_leaf)
  end)

  return {
    count = count,
    rootDirty = root_dirty,
    leafDirty = leaf_dirty,
  }
end

local function mark_subtree_dirty_for_benchmark(node)
  node.dirty = true

  for _, child in ipairs(node.children or {}) do
    mark_subtree_dirty_for_benchmark(child)
  end
end

local function measure_allocated_kb(root, step)
  yoga.calculateLayout(root)

  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end

  collectgarbage("restart")
  collectgarbage("collect")
  collectgarbage("collect")
  collectgarbage("stop")

  local before = collectgarbage("count")
  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end
  local allocated = collectgarbage("count") - before

  collectgarbage("restart")
  collectgarbage("collect")

  allocated = math.max(0, allocated)
  return {
    iterations = iterations,
    totalKb = allocated,
    averageKb = allocated / iterations,
    width = root.layout.width,
    height = root.layout.height,
  }
end

local function benchmark_allocations(count)
  local clean_root = make_tree(count)
  local clean = measure_allocated_kb(clean_root, function() end)

  local leaf_dirty_root, leaf_dirty_leaves = make_tree(count)
  local dirty_leaf = leaf_dirty_leaves[math.floor(#leaf_dirty_leaves / 2)]
  local leaf_dirty = measure_allocated_kb(leaf_dirty_root, function()
    yoga.markDirty(dirty_leaf)
  end)

  local branch_dirty_root, _, branch_dirty_rows = make_tree(count)
  local dirty_branch = branch_dirty_rows[math.floor(#branch_dirty_rows / 2)]
  local branch_dirty = measure_allocated_kb(branch_dirty_root, function()
    yoga.markDirty(dirty_branch)
  end)

  local full_relayout_root = make_tree(count)
  local full_relayout = measure_allocated_kb(full_relayout_root, function()
    mark_subtree_dirty_for_benchmark(full_relayout_root)
  end)

  return {
    count = count,
    clean = clean,
    leafDirty = leaf_dirty,
    branchDirty = branch_dirty,
    fullRelayout = full_relayout,
  }
end

local function make_virtual_list(scroll_offset)
  local rendered = 0
  local list = ui.virtualList({
    itemCount = 10000,
    itemHeight = 24,
    viewportHeight = 240,
    scrollOffset = scroll_offset,
    overscan = 2,
    style = { width = 640 },
    renderItem = function(index)
      rendered = rendered + 1
      return yoga.node({
        height = 24,
        width = 640,
        marginBottom = index % 2,
      })
    end,
  })

  return list, rendered
end

local function benchmark_virtual_jumps()
  local offsets = {}
  local max_scroll = 10000 * 24 - 240
  local jump_iterations = iterations * 100

  for index = 1, jump_iterations do
    offsets[index] = math.floor((index - 1) * max_scroll / math.max(1, jump_iterations - 1))
  end

  local rendered_total = 0
  local visible_total = 0
  local start = os.clock()

  for _, offset in ipairs(offsets) do
    local root, rendered = make_virtual_list(offset)
    yoga.calculateLayout(root)
    rendered_total = rendered_total + rendered
    visible_total = visible_total + (root.virtual.visibleEnd - root.virtual.visibleStart + 1)
  end

  local elapsed = os.clock() - start

  return {
    iterations = jump_iterations,
    total = elapsed,
    average = elapsed / jump_iterations,
    renderedAverage = rendered_total / jump_iterations,
    visibleAverage = visible_total / jump_iterations,
  }
end

print(string.format("layout benchmark (%d iterations)", iterations))
for _, size in ipairs(sizes) do
  local result = benchmark(size)
  print(string.format(
    "%5d nodes: total %.4fs, avg %.6fs, root %.0fx%.0f",
    result.count,
    result.total,
    result.average,
    result.width,
    result.height
  ))
end

local virtual = benchmark_virtual_jumps()
print(string.format(
  "virtual list jumps (%d jumps): total %.4fs, avg %.6fs, rendered avg %.1f, visible avg %.1f",
  virtual.iterations,
  virtual.total,
  virtual.average,
  virtual.renderedAverage,
  virtual.visibleAverage
))

local incremental = benchmark_incremental(incremental_size)
print(string.format("incremental layout benchmark (%d nodes, %d iterations)", incremental.count, iterations))
print(string.format(
  "  clean cache hits: total %.4fs, avg %.6fs, root %.0fx%.0f",
  incremental.clean.total,
  incremental.clean.average,
  incremental.clean.width,
  incremental.clean.height
))
print(string.format(
  "  root dirty relayout: total %.4fs, avg %.6fs, root %.0fx%.0f",
  incremental.rootDirty.total,
  incremental.rootDirty.average,
  incremental.rootDirty.width,
  incremental.rootDirty.height
))
print(string.format(
  "  single leaf dirty: total %.4fs, avg %.6fs, root %.0fx%.0f",
  incremental.leafDirty.total,
  incremental.leafDirty.average,
  incremental.leafDirty.width,
  incremental.leafDirty.height
))
print(string.format(
  "  single style change: total %.4fs, avg %.6fs, root %.0fx%.0f",
  incremental.styleChange.total,
  incremental.styleChange.average,
  incremental.styleChange.width,
  incremental.styleChange.height
))

local allocations = benchmark_allocations(incremental_size)
print(string.format("allocation benchmark (%d nodes, %d iterations, steady-state KB)", allocations.count, iterations))
print(string.format(
  "  clean cache hits: total %.3fKB, avg %.3fKB, root %.0fx%.0f",
  allocations.clean.totalKb,
  allocations.clean.averageKb,
  allocations.clean.width,
  allocations.clean.height
))
print(string.format(
  "  single leaf dirty: total %.3fKB, avg %.3fKB, root %.0fx%.0f",
  allocations.leafDirty.totalKb,
  allocations.leafDirty.averageKb,
  allocations.leafDirty.width,
  allocations.leafDirty.height
))
print(string.format(
  "  branch dirty relayout: total %.3fKB, avg %.3fKB, root %.0fx%.0f",
  allocations.branchDirty.totalKb,
  allocations.branchDirty.averageKb,
  allocations.branchDirty.width,
  allocations.branchDirty.height
))
print(string.format(
  "  full subtree relayout: total %.3fKB, avg %.3fKB, root %.0fx%.0f",
  allocations.fullRelayout.totalKb,
  allocations.fullRelayout.averageKb,
  allocations.fullRelayout.width,
  allocations.fullRelayout.height
))

local measured_incremental = benchmark_measured_incremental(measured_incremental_size)
print(string.format("measured-node incremental benchmark (%d nodes, %d iterations)", measured_incremental.count, iterations))
print(string.format(
  "  root dirty measure cache: total %.4fs, avg %.6fs, measure calls %d, root %.0fx%.0f",
  measured_incremental.rootDirty.total,
  measured_incremental.rootDirty.average,
  measured_incremental.rootDirty.measureCalls,
  measured_incremental.rootDirty.width,
  measured_incremental.rootDirty.height
))
print(string.format(
  "  single measured leaf dirty: total %.4fs, avg %.6fs, measure calls %d, root %.0fx%.0f",
  measured_incremental.leafDirty.total,
  measured_incremental.leafDirty.average,
  measured_incremental.leafDirty.measureCalls,
  measured_incremental.leafDirty.width,
  measured_incremental.leafDirty.height
))
