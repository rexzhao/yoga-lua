return {
  {
    name = "percentage_padding_based_on_width",
    root = {
      style = { width = 200, height = 100, padding = "10%" },
      children = {
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 20, top = 20, width = 10, height = 10 },
    },
  },
  {
    name = "percentage_margin_based_on_width",
    root = {
      style = { width = 200, height = 100 },
      children = {
        { style = { flex = 1, margin = "10%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 20, top = 20, width = 160, height = 60 },
    },
  },
}

