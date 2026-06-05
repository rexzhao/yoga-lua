return {
  {
    name = "align_items_stretch_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "stretch" },
      children = {
        { style = { width = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 0, width = 20, height = 40 },
    },
  },
  {
    name = "align_items_flex_start_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "flex-start" },
      children = {
        { style = { width = 20, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 0, width = 20, height = 10 },
    },
  },
  {
    name = "align_items_center_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "center" },
      children = {
        { style = { width = 20, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 15, width = 20, height = 10 },
    },
  },
  {
    name = "align_items_flex_end_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "flex-end" },
      children = {
        { style = { width = 20, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 30, width = 20, height = 10 },
    },
  },
  {
    name = "align_items_center_column",
    root = {
      style = { width = 100, height = 40, flexDirection = "column", alignItems = "center" },
      children = {
        { style = { width = 20, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 40, top = 0, width = 20, height = 10 },
    },
  },
  {
    name = "align_items_with_margin_row",
    root = {
      style = { width = 100, height = 50, flexDirection = "row", alignItems = "center" },
      children = {
        { style = { width = 20, height = 10, marginTop = 5, marginBottom = 15 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 50 },
      { left = 0, top = 15, width = 20, height = 10 },
    },
  },
}

