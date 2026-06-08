# Benchmarks

Run with:

```sh
lua benchmarks/run.lua
.\LOVE\lovec.exe .\benchmarks\love2d
```

Latest local runs:

System Lua 5.4.8:

```text
layout benchmark (20 iterations)
  100 nodes: total 0.0310s, avg 0.001550s, root 640x294
 1000 nodes: total 0.2040s, avg 0.010200s, root 640x2814
 5000 nodes: total 1.1710s, avg 0.058550s, root 640x14014
virtual list jumps (2000 jumps): total 0.4690s, avg 0.000235s, rendered avg 15.0, visible avg 15.0
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations)
  100 nodes: total 0.0110s, avg 0.000550s, root 640x294
 1000 nodes: total 0.0370s, avg 0.001850s, root 640x2814
 5000 nodes: total 0.2310s, avg 0.011550s, root 640x14014
virtual list jumps (2000 jumps): total 0.1070s, avg 0.000053s, rendered avg 15.0, visible avg 15.0
```
