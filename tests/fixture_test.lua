local fixture_runner = require("fixture_runner")

return function(runner, helper)
  fixture_runner.register(runner, helper, require("fixtures.basic_layout"))
  fixture_runner.register(runner, helper, require("fixtures.justify_content"))
end
