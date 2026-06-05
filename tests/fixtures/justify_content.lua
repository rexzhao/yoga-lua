return {
  {
    name = "justify_center_row",
    root = {
      style = { width = 100, height = 20, flexDirection = "row", justifyContent = "center" },
      children = {
        { style = { width = 10, height = 10 } },
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 20 },
      { left = 40, top = 0, width = 10, height = 10 },
      { left = 50, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "justify_flex_end_row",
    root = {
      style = { width = 100, height = 20, flexDirection = "row", justifyContent = "flex-end" },
      children = {
        { style = { width = 10, height = 10 } },
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 20 },
      { left = 80, top = 0, width = 10, height = 10 },
      { left = 90, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "justify_space_between_row",
    root = {
      style = { width = 100, height = 20, flexDirection = "row", justifyContent = "space-between" },
      children = {
        { style = { width = 10, height = 10 } },
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 20 },
      { left = 0, top = 0, width = 10, height = 10 },
      { left = 90, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "justify_space_around_row",
    root = {
      style = { width = 100, height = 20, flexDirection = "row", justifyContent = "space-around" },
      children = {
        { style = { width = 10, height = 10 } },
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 20 },
      { left = 20, top = 0, width = 10, height = 10 },
      { left = 70, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "justify_space_evenly_row",
    root = {
      style = { width = 100, height = 20, flexDirection = "row", justifyContent = "space-evenly" },
      children = {
        { style = { width = 10, height = 10 } },
        { style = { width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 20 },
      { left = 27, top = 0, width = 10, height = 10 },
      { left = 63, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "justify_center_column",
    root = {
      style = { width = 20, height = 100, flexDirection = "column", justifyContent = "center" },
      children = {
        { style = { height = 10 } },
        { style = { height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 20, height = 100 },
      { left = 0, top = 40, width = 20, height = 10 },
      { left = 0, top = 50, width = 20, height = 10 },
    },
  },
}
