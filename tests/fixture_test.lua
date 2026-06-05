local fixture_runner = require("fixture_runner")

return function(runner, helper)
  fixture_runner.register(runner, helper, require("fixtures.basic_layout"))
end

