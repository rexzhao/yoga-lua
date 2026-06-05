return function(runner)
  runner:test("love2d example syntax", function()
    assert(loadfile("examples/love2d/conf.lua"))
    assert(loadfile("examples/love2d/main.lua"))
  end)
end

