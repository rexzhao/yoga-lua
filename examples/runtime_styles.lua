local ui = require("ui")

local styles = ui.stylesheet({
  screen = {
    width = 320,
    height = 120,
    flexDirection = "column",
    padding = 12,
    gap = 8,
  },
  screen_active = {
    height = 140,
  },
  title = {
    height = 24,
  },
  row = {
    height = 32,
    flexDirection = "row",
    gap = 8,
  },
  button = {
    width = 96,
    height = 32,
  },
  button_active = {
    width = 124,
  },
})

return {
  build = function(active)
    local runtime = ui.createRuntime({ styles = styles })

    return runtime:render(runtime:div({ class = { "screen", active and "screen_active" } }, {
      runtime:text("Runtime styles", { class = "title" }),
      runtime:div({ class = "row" }, {
        runtime:button("Bag", {
          key = "nav.bag",
          class = { "button", active and "button_active" },
        }),
        runtime:button("Skills", {
          key = "nav.skills",
          class = "button",
        }),
      }),
    }))
  end,
}
