return {
  {
    name = "align_self_overrides_align_items_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "flex-start" },
      children = {
        { style = { width = 20, height = 10, alignSelf = "flex-end" } },
        { style = { width = 20, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 30, width = 20, height = 10 },
      { left = 20, top = 0, width = 20, height = 10 },
    },
  },
  {
    name = "align_self_stretch_row",
    root = {
      style = { width = 100, height = 40, flexDirection = "row", alignItems = "center" },
      children = {
        { style = { width = 20, alignSelf = "stretch" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 40 },
      { left = 0, top = 0, width = 20, height = 40 },
    },
  },
}

