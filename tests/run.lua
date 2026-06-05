package.path = "src/?.lua;src/?/init.lua;tests/?.lua;" .. package.path

local helper = require("helper")
local runner = helper.new_runner()

require("core_test")(runner, helper)
require("ui_test")(runner, helper)
require("love2d_test")(runner, helper)

runner:run()

