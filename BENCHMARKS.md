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
  100 nodes: total 0.0000s, avg 0.000000s, root 640x294
 1000 nodes: total 0.0310s, avg 0.001550s, root 640x2814
 5000 nodes: total 0.1250s, avg 0.006250s, root 640x14014
virtual list jumps (2000 jumps): total 0.4840s, avg 0.000242s, rendered avg 15.0, visible avg 15.0
incremental layout benchmark (5000 nodes, 20 iterations)
  clean cache hits: total 0.0000s, avg 0.000000s, root 640x14014
  root dirty relayout: total 0.1400s, avg 0.007000s, root 640x14014
  single leaf dirty: total 0.1100s, avg 0.005500s, root 640x14014
  single style change: total 0.1090s, avg 0.005450s, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations)
  root dirty measure cache: total 0.0160s, avg 0.000800s, measure calls 0, root 640x2814
  single measured leaf dirty: total 0.0320s, avg 0.001600s, measure calls 20, root 640x2814
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations)
  100 nodes: total 0.0030s, avg 0.000150s, root 640x294
 1000 nodes: total 0.0020s, avg 0.000100s, root 640x2814
 5000 nodes: total 0.0080s, avg 0.000400s, root 640x14014
virtual list jumps (2000 jumps): total 0.0560s, avg 0.000028s, rendered avg 15.0, visible avg 15.0
incremental layout benchmark (5000 nodes, 20 iterations)
  clean cache hits: total 0.0000s, avg 0.000000s, root 640x14014
  root dirty relayout: total 0.0070s, avg 0.000350s, root 640x14014
  single leaf dirty: total 0.0060s, avg 0.000300s, root 640x14014
  single style change: total 0.0090s, avg 0.000450s, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations)
  root dirty measure cache: total 0.0080s, avg 0.000400s, measure calls 0, root 640x2814
  single measured leaf dirty: total 0.0030s, avg 0.000150s, measure calls 20, root 640x2814
```
