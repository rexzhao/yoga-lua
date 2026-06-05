return {
  {
    name = "percentage_width_height_row",
    source = {
      repo = "local",
      test = "percentage_width_height_row",
    },
    root = {
      style = { width = 200, height = 120, flexDirection = "row" },
      children = {
        { style = { width = "50%", height = "25%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 120 },
      { left = 0, top = 0, width = 100, height = 30 },
    },
  },
  {
    name = "percentage_height_column",
    source = {
      repo = "local",
      test = "percentage_height_column",
    },
    root = {
      style = { width = 120, height = 200, flexDirection = "column" },
      children = {
        { style = { height = "40%" } },
        { style = { height = "10%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 120, height = 200 },
      { left = 0, top = 0, width = 120, height = 80 },
      { left = 0, top = 80, width = 120, height = 20 },
    },
  },
  {
    name = "percentage_cross_axis_column",
    source = {
      repo = "local",
      test = "percentage_cross_axis_column",
    },
    root = {
      style = { width = 200, height = 100, flexDirection = "column", alignItems = "flex-start" },
      children = {
        { style = { width = "25%", height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 0, top = 0, width = 50, height = 20 },
    },
  },
}
