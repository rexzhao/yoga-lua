return {
  {
    name = "fixed_column_padding_gap",
    root = {
      style = { width = 100, height = 80, flexDirection = "column", padding = 10, gap = 5 },
      children = {
        { style = { height = 20 } },
        { style = { height = 30 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 80 },
      { left = 10, top = 10, width = 80, height = 20 },
      { left = 10, top = 35, width = 80, height = 30 },
    },
  },
  {
    name = "edge_padding_margin",
    root = {
      style = {
        width = 120,
        height = 90,
        flexDirection = "column",
        paddingLeft = 10,
        paddingRight = 20,
        paddingTop = 5,
        paddingBottom = 7,
        gap = 3,
      },
      children = {
        { style = { height = 10, marginLeft = 2, marginRight = 4, marginTop = 6, marginBottom = 8 } },
        { style = { height = 12, marginHorizontal = 5 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 120, height = 90 },
      { left = 12, top = 11, width = 84, height = 10 },
      { left = 15, top = 32, width = 80, height = 12 },
    },
  },
  {
    name = "row_flex_grow",
    root = {
      style = { width = 300, height = 80, flexDirection = "row", padding = 10, gap = 5 },
      children = {
        { style = { width = 50 } },
        { style = { flexGrow = 1 } },
        { style = { flex = 2 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 300, height = 80 },
      { left = 10, top = 10, width = 50, height = 60 },
      { left = 65, top = 10, width = 73, height = 60 },
      { left = 143, top = 10, width = 147, height = 60 },
    },
  },
}
