local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGPercentageTest.html",
    generated = "tests/generated/YGPercentageTest.cpp",
    test = test,
  }
end

return {
  {
    name = "percentage_width_height",
    source = source("percentage_width_height"),
    root = {
      style = { width = 200, height = 200, flexDirection = "row" },
      children = {
        { style = { width = "30%", height = "30%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 0, width = 60, height = 60 },
    },
  },
  {
    name = "percentage_margin_should_calculate_based_only_on_width",
    source = source("percentage_margin_should_calculate_based_only_on_width"),
    root = {
      style = { width = 200, height = 100 },
      children = {
        {
          style = { flexGrow = 1, margin = "10%" },
          children = {
            { style = { width = 10, height = 10 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 20, top = 20, width = 160, height = 60 },
      { left = 20, top = 20, width = 10, height = 10 },
    },
  },
  {
    name = "percentage_padding_should_calculate_based_only_on_width",
    source = source("percentage_padding_should_calculate_based_only_on_width"),
    root = {
      style = { width = 200, height = 100 },
      children = {
        {
          style = { flexGrow = 1, padding = "10%" },
          children = {
            { style = { width = 10, height = 10 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 20, top = 20, width = 10, height = 10 },
    },
  },
  {
    name = "percentage_position_left_top",
    source = source("percentage_position_left_top"),
    root = {
      style = { width = 400, height = 400, flexDirection = "row" },
      children = {
        { style = { width = "45%", height = "55%", left = "10%", top = "20%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 400, height = 400 },
      { left = 40, top = 80, width = 180, height = 220 },
    },
  },
  {
    name = "percentage_position_bottom_right",
    source = source("percentage_position_bottom_right"),
    root = {
      style = { width = 500, height = 500, flexDirection = "row" },
      children = {
        { style = { width = "55%", height = "15%", right = "20%", bottom = "10%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 500, height = 500 },
      { left = -100, top = -50, width = 275, height = 75 },
    },
  },
  {
    name = "percentage_flex_basis",
    source = source("percentage_flex_basis"),
    root = {
      style = { width = 200, height = 200, flexDirection = "row" },
      children = {
        { style = { flexGrow = 1, flexBasis = "50%" } },
        { style = { flexGrow = 1, flexBasis = "25%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 0, width = 125, height = 200 },
      { left = 125, top = 0, width = 75, height = 200 },
    },
  },
  {
    name = "percentage_flex_basis_cross",
    source = source("percentage_flex_basis_cross"),
    root = {
      style = { width = 200, height = 200 },
      children = {
        { style = { flexGrow = 1, flexBasis = "50%" } },
        { style = { flexGrow = 1, flexBasis = "25%" } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 0, width = 200, height = 125 },
      { left = 0, top = 125, width = 200, height = 75 },
    },
  },
  {
    name = "percentage_absolute_position",
    source = source("percentage_absolute_position"),
    root = {
      style = { width = 200, height = 100 },
      children = {
        { style = { position = "absolute", top = "10%", left = "30%", width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 100 },
      { left = 60, top = 10, width = 10, height = 10 },
    },
  },
  {
    name = "percent_of_minmax_main",
    source = source("percent_of_minmax_main"),
    root = {
      style = { flexDirection = "row", minWidth = 60, maxWidth = 60, height = 50 },
      children = {
        { style = { width = "50%", height = 20 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 60, height = 50 },
      { left = 0, top = 0, width = 30, height = 20 },
    },
  },
}
