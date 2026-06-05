local function source(test)
  return {
    repo = "facebook/yoga",
    fixture = "gentest/fixtures/YGAspectRatioTest.html",
    generated = "tests/generated/YGAspectRatioTest.cpp",
    test = test,
  }
end

return {
  {
    name = "aspect_ratio_does_not_stretch_cross_axis_dim",
    source = source("aspect_ratio_does_not_stretch_cross_axis_dim"),
    skip = true,
    unsupportedReason = "upstream generated test is disabled and conflicts with enabled Yoga aspect-ratio flexed-dimension behavior",
  },
  {
    name = "zero_aspect_ratio_behaves_like_auto",
    source = source("zero_aspect_ratio_behaves_like_auto"),
    root = {
      style = { width = 300, height = 300 },
      children = {
        { style = { aspectRatio = 0, width = 50 } },
      },
    },
    expect = {
      { left = 0, top = 0, width = 300, height = 300 },
      { left = 0, top = 0, width = 50, height = 0 },
    },
  },
}
