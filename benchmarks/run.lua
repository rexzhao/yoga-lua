package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")
local ui = require("ui")

local sizes = { 100, 1000, 5000 }
local incremental_size = 5000
local measured_incremental_size = 1000
local iterations = math.max(1, tonumber(arg and arg[1]) or 20)
local sample_count = math.max(1, tonumber(arg and arg[2]) or 5)

local function now()
  if love and love.timer and love.timer.getTime then
    return love.timer.getTime()
  end

  return os.clock()
end

local function metric_stats(samples, getter)
  local values = {}

  for index, sample in ipairs(samples) do
    values[index] = getter(sample)
  end

  table.sort(values)

  local count = #values
  local middle = math.floor((count + 1) / 2)
  local median = values[middle]
  if count % 2 == 0 then
    median = (values[middle] + values[middle + 1]) / 2
  end

  return {
    median = median,
    min = values[1],
    max = values[count],
  }
end

local function run_samples(factory)
  local samples = {}

  for index = 1, sample_count do
    samples[index] = factory()
  end

  return samples
end

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
  yoga._resetDebugStats()

  local start = now()
  for _ = 1, iterations do
    yoga.markDirty(root)
    yoga.calculateLayout(root)
  end
  local elapsed = now() - start
  local stats = yoga._debugStats()
  yoga._clearDebugStats()

  return {
    count = count,
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    width = root.layout.width,
    height = root.layout.height,
    stats = stats,
  }
end

local function time_incremental(root, step)
  yoga.calculateLayout(root)
  yoga._resetDebugStats()

  local start = now()
  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end
  local elapsed = now() - start
  local stats = yoga._debugStats()
  yoga._clearDebugStats()

  return {
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    width = root.layout.width,
    height = root.layout.height,
    stats = stats,
  }
end

local mark_subtree_dirty_for_benchmark

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

  local full_relayout_root = make_tree(count)
  local full_relayout = time_incremental(full_relayout_root, function()
    mark_subtree_dirty_for_benchmark(full_relayout_root)
  end)

  return {
    count = count,
    clean = clean,
    rootDirty = root_dirty,
    leafDirty = leaf_dirty,
    styleChange = style_change,
    fullRelayout = full_relayout,
  }
end

local function time_measured_incremental(root, counter, step)
  yoga.calculateLayout(root)
  counter.calls = 0
  yoga._resetDebugStats()

  local start = now()
  for index = 1, iterations do
    step(index)
    yoga.calculateLayout(root)
  end
  local elapsed = now() - start
  local stats = yoga._debugStats()
  yoga._clearDebugStats()

  return {
    iterations = iterations,
    total = elapsed,
    average = elapsed / iterations,
    measureCalls = counter.calls,
    width = root.layout.width,
    height = root.layout.height,
    stats = stats,
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

function mark_subtree_dirty_for_benchmark(node)
  node.dirty = true

  for _, child in ipairs(node.children or {}) do
    mark_subtree_dirty_for_benchmark(child)
  end
end

local function measure_allocated_kb(root, step)
  yoga._clearDebugStats()
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
  local start = now()

  for _, offset in ipairs(offsets) do
    local root, rendered = make_virtual_list(offset)
    yoga.calculateLayout(root)
    rendered_total = rendered_total + rendered
    visible_total = visible_total + (root.virtual.visibleEnd - root.virtual.visibleStart + 1)
  end

  local elapsed = now() - start

  return {
    iterations = jump_iterations,
    total = elapsed,
    average = elapsed / jump_iterations,
    renderedAverage = rendered_total / jump_iterations,
    visibleAverage = visible_total / jump_iterations,
  }
end

local function print_time_stats(label, samples, getter)
  local stats = metric_stats(samples, function(sample)
    return getter(sample).average
  end)
  local result = getter(samples[1])

  print(string.format(
    "%s: avg median %.6fs, min %.6fs, max %.6fs, root %.0fx%.0f",
    label,
    stats.median,
    stats.min,
    stats.max,
    result.width,
    result.height
  ))
end

local function print_heap_stats(label, samples, getter)
  local stats = metric_stats(samples, function(sample)
    return getter(sample).averageKb
  end)
  local result = getter(samples[1])

  print(string.format(
    "%s: heap avg median %.3fKB, min %.3fKB, max %.3fKB, root %.0fx%.0f",
    label,
    stats.median,
    stats.min,
    stats.max,
    result.width,
    result.height
  ))
end

local function print_measured_time_stats(label, samples, getter)
  local call_stats = metric_stats(samples, function(sample)
    return getter(sample).measureCalls
  end)
  print_time_stats(label, samples, getter)
  print(string.format("    measure calls median %.0f, min %.0f, max %.0f", call_stats.median, call_stats.min, call_stats.max))
end

local function print_debug_stats(label, samples, getter)
  local function per_iteration_stat(sample, key)
    local result = getter(sample)
    return (result.stats and result.stats[key] or 0) / result.iterations
  end

  local layout_nodes = metric_stats(samples, function(sample)
    return per_iteration_stat(sample, "layoutNodes")
  end)
  local cache_hits = metric_stats(samples, function(sample)
    return per_iteration_stat(sample, "layoutCacheHits")
  end)
  local rounded_nodes = metric_stats(samples, function(sample)
    return per_iteration_stat(sample, "roundedNodes")
  end)
  local rounded_skipped = metric_stats(samples, function(sample)
    return per_iteration_stat(sample, "roundedSkippedSubtrees")
  end)

  print(string.format(
    "%s stats: layout nodes %.1f, cache hits %.1f, rounded nodes %.1f, skipped rounded subtrees %.1f per iter median",
    label,
    layout_nodes.median,
    cache_hits.median,
    rounded_nodes.median,
    rounded_skipped.median
  ))
end

print(string.format(
  "layout benchmark (%d iterations, %d samples, per-iteration avg median/min/max)",
  iterations,
  sample_count
))
for _, size in ipairs(sizes) do
  local samples = run_samples(function()
    return benchmark(size)
  end)
  print_time_stats(string.format("%5d nodes", size), samples, function(sample)
    return sample
  end)
end

local virtual_samples = run_samples(benchmark_virtual_jumps)
local virtual_average = metric_stats(virtual_samples, function(sample)
  return sample.average
end)
local rendered_average = metric_stats(virtual_samples, function(sample)
  return sample.renderedAverage
end)
local visible_average = metric_stats(virtual_samples, function(sample)
  return sample.visibleAverage
end)
print(string.format(
  "virtual list jumps (%d jumps, %d samples): avg median %.6fs, min %.6fs, max %.6fs, rendered median %.1f, visible median %.1f",
  virtual_samples[1].iterations,
  sample_count,
  virtual_average.median,
  virtual_average.min,
  virtual_average.max,
  rendered_average.median,
  visible_average.median
))

local incremental_samples = run_samples(function()
  return benchmark_incremental(incremental_size)
end)
print(string.format(
  "incremental layout benchmark (%d nodes, %d iterations, %d samples, per-iteration avg median/min/max)",
  incremental_size,
  iterations,
  sample_count
))
print_time_stats("  clean cache hits", incremental_samples, function(sample)
  return sample.clean
end)
print_time_stats("  root dirty relayout", incremental_samples, function(sample)
  return sample.rootDirty
end)
print_time_stats("  single leaf dirty", incremental_samples, function(sample)
  return sample.leafDirty
end)
print_time_stats("  single style change", incremental_samples, function(sample)
  return sample.styleChange
end)
print_time_stats("  full subtree relayout", incremental_samples, function(sample)
  return sample.fullRelayout
end)
print_debug_stats("  root dirty relayout", incremental_samples, function(sample)
  return sample.rootDirty
end)
print_debug_stats("  single leaf dirty", incremental_samples, function(sample)
  return sample.leafDirty
end)
print_debug_stats("  full subtree relayout", incremental_samples, function(sample)
  return sample.fullRelayout
end)

local allocation_samples = run_samples(function()
  return benchmark_allocations(incremental_size)
end)
print(string.format(
  "heap growth benchmark (%d nodes, %d iterations, %d samples, steady-state KB growth median/min/max)",
  incremental_size,
  iterations,
  sample_count
))
print_heap_stats("  clean cache hits", allocation_samples, function(sample)
  return sample.clean
end)
print_heap_stats("  single leaf dirty", allocation_samples, function(sample)
  return sample.leafDirty
end)
print_heap_stats("  branch dirty relayout", allocation_samples, function(sample)
  return sample.branchDirty
end)
print_heap_stats("  full subtree relayout", allocation_samples, function(sample)
  return sample.fullRelayout
end)

local measured_incremental_samples = run_samples(function()
  return benchmark_measured_incremental(measured_incremental_size)
end)
print(string.format(
  "measured-node incremental benchmark (%d nodes, %d iterations, %d samples, per-iteration avg median/min/max)",
  measured_incremental_size,
  iterations,
  sample_count
))
print_measured_time_stats("  root dirty measure cache", measured_incremental_samples, function(sample)
  return sample.rootDirty
end)
print_measured_time_stats("  single measured leaf dirty", measured_incremental_samples, function(sample)
  return sample.leafDirty
end)
