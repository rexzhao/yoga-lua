local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAbsolutePositionTest.html",
    generated = "tests/generated/YGAbsolutePositionTest.cpp",
    test = test,
  }
end

return {
  {
    name = "absolute_layout_width_height_start_top",
    source = source("absolute_layout_width_height_start_top"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", left = 10, top = 10, width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 10, width = 10, height = 10 },
    },
  },
  {
    name = "absolute_layout_width_height_left_auto_right",
    source = source("absolute_layout_width_height_left_auto_right"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", right = 10, width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 80, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "absolute_layout_width_height_left_right_auto",
    source = source("absolute_layout_width_height_left_right_auto"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", left = 10, width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "absolute_layout_width_height_left_auto_right_auto",
    source = source("absolute_layout_width_height_left_auto_right_auto"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 10, height = 10 },
    },
  },
  {
    name = "absolute_layout_width_height_end_bottom",
    source = source("absolute_layout_width_height_end_bottom"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", right = 10, bottom = 10, width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 80, top = 80, width = 10, height = 10 },
    },
  },
  {
    name = "absolute_layout_start_top_end_bottom",
    source = source("absolute_layout_start_top_end_bottom"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", left = 10, top = 10, right = 10, bottom = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 10, width = 80, height = 80 },
    },
  },
  {
    name = "absolute_layout_width_height_start_top_end_bottom",
    source = source("absolute_layout_width_height_start_top_end_bottom"),
    root = {
      style = { width = 100, height = 100 },
      children = {
        { style = { position = "absolute", left = 10, top = 10, right = 10, bottom = 10, width = 10, height = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 10, top = 10, width = 10, height = 10 },
    },
  },
  {
    name = "do_not_clamp_height_of_absolute_node_to_height_of_its_overflow_hidden_parent",
    source = source("do_not_clamp_height_of_absolute_node_to_height_of_its_overflow_hidden_parent"),
    root = {
      style = { width = 50, height = 50, overflow = "hidden", flexDirection = "row" },
      children = {
        {
          style = { position = "absolute", left = 0, top = 0 },
          children = {
            { style = { width = 100, height = 100 } },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 50, height = 50 },
      { left = 0, top = 0, width = 100, height = 100 },
      { left = 0, top = 0, width = 100, height = 100 },
    },
  },
  {
    name = "absolute_layout_within_border",
    source = source("absolute_layout_within_border"),
    skip = true,
    unsupportedReason = "border is not implemented",
  },
  {
    name = "absolute_layout_align_items_and_justify_content_center",
    source = source("absolute_layout_align_items_and_justify_content_center"),
    root = {
      style = { width = 110, height = 100, alignItems = "center", justifyContent = "center" },
      children = {
        { style = { position = "absolute", width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 25, top = 30, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_and_justify_content_flex_end",
    source = source("absolute_layout_align_items_and_justify_content_flex_end"),
    root = {
      style = { width = 110, height = 100, alignItems = "flex-end", justifyContent = "flex-end" },
      children = {
        { style = { position = "absolute", width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 50, top = 60, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_justify_content_center",
    source = source("absolute_layout_justify_content_center"),
    root = {
      style = { width = 110, height = 100, justifyContent = "center" },
      children = {
        { style = { position = "absolute", width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 0, top = 30, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_center",
    source = source("absolute_layout_align_items_center"),
    root = {
      style = { width = 110, height = 100, alignItems = "center" },
      children = {
        { style = { position = "absolute", width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 25, top = 0, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_center_on_child_only",
    source = source("absolute_layout_align_items_center_on_child_only"),
    root = {
      style = { width = 110, height = 100 },
      children = {
        { style = { position = "absolute", alignSelf = "center", width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 25, top = 0, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_and_justify_content_center_and_top_position",
    source = source("absolute_layout_align_items_and_justify_content_center_and_top_position"),
    root = {
      style = { width = 110, height = 100, alignItems = "center", justifyContent = "center" },
      children = {
        { style = { position = "absolute", top = 10, width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 25, top = 10, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_and_justify_content_center_and_bottom_position",
    source = source("absolute_layout_align_items_and_justify_content_center_and_bottom_position"),
    root = {
      style = { width = 110, height = 100, alignItems = "center", justifyContent = "center" },
      children = {
        { style = { position = "absolute", bottom = 10, width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 25, top = 50, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_and_justify_content_center_and_left_position",
    source = source("absolute_layout_align_items_and_justify_content_center_and_left_position"),
    root = {
      style = { width = 110, height = 100, alignItems = "center", justifyContent = "center" },
      children = {
        { style = { position = "absolute", left = 5, width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 5, top = 30, width = 60, height = 40 },
    },
  },
  {
    name = "absolute_layout_align_items_and_justify_content_center_and_right_position",
    source = source("absolute_layout_align_items_and_justify_content_center_and_right_position"),
    root = {
      style = { width = 110, height = 100, alignItems = "center", justifyContent = "center" },
      children = {
        { style = { position = "absolute", right = 5, width = 60, height = 40 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 110, height = 100 },
      { left = 45, top = 30, width = 60, height = 40 },
    },
  },
  {
    name = "position_root_with_rtl_should_position_withoutdirection",
    source = source("position_root_with_rtl_should_position_withoutdirection"),
    skip = true,
    unsupportedReason = "RTL direction is not implemented",
  },
  {
    name = "absolute_layout_percentage_bottom_based_on_parent_height",
    source = source("absolute_layout_percentage_bottom_based_on_parent_height"),
    root = {
      style = { width = 100, height = 200 },
      children = {
        { style = { position = "absolute", top = "50%", width = 10, height = 10 } },
        { style = { position = "absolute", bottom = "50%", width = 10, height = 10 } },
        { style = { position = "absolute", top = "10%", bottom = "10%", width = 10 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 100, height = 200 },
      { left = 0, top = 100, width = 10, height = 10 },
      { left = 0, top = 90, width = 10, height = 10 },
      { left = 0, top = 20, width = 10, height = 160 },
    },
  },
  {
    name = "absolute_layout_in_wrap_reverse_column_container",
    source = source("absolute_layout_in_wrap_reverse_column_container"),
    skip = true,
    unsupportedReason = "wrap-reverse is not implemented",
  },
  {
    name = "absolute_layout_in_wrap_reverse_row_container",
    source = source("absolute_layout_in_wrap_reverse_row_container"),
    skip = true,
    unsupportedReason = "wrap-reverse is not implemented",
  },
  {
    name = "absolute_layout_in_wrap_reverse_column_container_flex_end",
    source = source("absolute_layout_in_wrap_reverse_column_container_flex_end"),
    skip = true,
    unsupportedReason = "wrap-reverse is not implemented",
  },
  {
    name = "absolute_layout_in_wrap_reverse_row_container_flex_end",
    source = source("absolute_layout_in_wrap_reverse_row_container_flex_end"),
    skip = true,
    unsupportedReason = "wrap-reverse is not implemented",
  },
  {
    name = "percent_absolute_position_infinite_height",
    source = source("percent_absolute_position_infinite_height"),
    skip = true,
    unsupportedReason = "undefined available height percentage handling is not implemented",
  },
  {
    name = "absolute_layout_percentage_height_based_on_padded_parent",
    source = source("absolute_layout_percentage_height_based_on_padded_parent"),
    skip = true,
    unsupportedReason = "border is not implemented",
  },
  {
    name = "absolute_layout_percentage_height_based_on_padded_parent_and_align_items_center",
    source = source("absolute_layout_percentage_height_based_on_padded_parent_and_align_items_center"),
    skip = true,
    unsupportedReason = "border is not implemented",
  },
  {
    name = "absolute_layout_padding_left",
    source = source("absolute_layout_padding_left"),
    root = {
      style = { width = 200, height = 200, paddingLeft = 100 },
      children = {
        { style = { position = "absolute", width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 100, top = 0, width = 50, height = 50 },
    },
  },
  {
    name = "absolute_layout_padding_right",
    source = source("absolute_layout_padding_right"),
    root = {
      style = { width = 200, height = 200, paddingRight = 100 },
      children = {
        { style = { position = "absolute", width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 0, width = 50, height = 50 },
    },
  },
  {
    name = "absolute_layout_padding_top",
    source = source("absolute_layout_padding_top"),
    root = {
      style = { width = 200, height = 200, paddingTop = 100 },
      children = {
        { style = { position = "absolute", width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 100, width = 50, height = 50 },
    },
  },
  {
    name = "absolute_layout_padding_bottom",
    source = source("absolute_layout_padding_bottom"),
    root = {
      style = { width = 200, height = 200, paddingBottom = 100 },
      children = {
        { style = { position = "absolute", width = 50, height = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 0, top = 0, width = 50, height = 50 },
    },
  },
  {
    name = "absolute_layout_padding",
    source = source("absolute_layout_padding"),
    root = {
      style = {},
      children = {
        {
          style = { width = 200, height = 200, margin = 10, position = "relative" },
          children = {
            {
              style = { position = "static", width = 200, height = 200, padding = 50 },
              children = {
                { style = { position = "absolute", width = 50, height = 50 } },
              },
            },
          },
        },
      },
    },
    expect = {
      { left = 0, top = 0, width = 220, height = 220 },
      { left = 10, top = 10, width = 200, height = 200 },
      { left = 0, top = 0, width = 200, height = 200 },
      { left = 50, top = 50, width = 50, height = 50 },
    },
  },
  {
    name = "absolute_layout_border",
    source = source("absolute_layout_border"),
    skip = true,
    unsupportedReason = "border is not implemented",
  },
  {
    name = "absolute_layout_column_reverse_margin_border",
    source = source("absolute_layout_column_reverse_margin_border"),
    skip = true,
    unsupportedReason = "column-reverse and border are not implemented",
  },
}
