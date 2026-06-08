package.path = "src/?.lua;src/?/init.lua;benchmarks/?.lua;" .. package.path

local love_version = string.format("LOVE %d.%d.%d", love.getVersion())
print(love_version .. " / " .. jit.version)

dofile("benchmarks/run.lua")

love.event.quit(0)
