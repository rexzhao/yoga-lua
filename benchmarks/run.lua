package.path = "src/?.lua;src/?/init.lua;" .. package.path

local yoga = require("yoga")

local sizes = { 100, 1000, 5000 }
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
  local remaining = count
  local index = 1

  while remaining > 0 do
    local row_count = math.min(10, remaining)
    local row_children = {}

    for child_index = 1, row_count do
      row_children[child_index] = make_leaf(index)
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
  }, rows)
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
