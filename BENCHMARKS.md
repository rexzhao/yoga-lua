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
 1000 nodes: total 0.0160s, avg 0.000800s, root 640x2814
 5000 nodes: total 0.0940s, avg 0.004700s, root 640x14014
virtual list jumps (2000 jumps): total 0.5310s, avg 0.000265s, rendered avg 15.0, visible avg 15.0
incremental layout benchmark (5000 nodes, 20 iterations)
  clean cache hits: total 0.0000s, avg 0.000000s, root 640x14014
  root dirty relayout: total 0.0930s, avg 0.004650s, root 640x14014
  single leaf dirty: total 0.0940s, avg 0.004700s, root 640x14014
  single style change: total 0.1090s, avg 0.005450s, root 640x14014
allocation benchmark (5000 nodes, 20 iterations, steady-state KB)
  clean cache hits: total 0.000KB, avg 0.000KB, root 640x14014
  single leaf dirty: total 2.344KB, avg 0.117KB, root 640x14014
  branch dirty relayout: total 2.500KB, avg 0.125KB, root 640x14014
  full subtree relayout: total 2.562KB, avg 0.128KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations)
  root dirty measure cache: total 0.0160s, avg 0.000800s, measure calls 0, root 640x2814
  single measured leaf dirty: total 0.0160s, avg 0.000800s, measure calls 20, root 640x2814
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations)
  100 nodes: total 0.0040s, avg 0.000200s, root 640x294
 1000 nodes: total 0.0020s, avg 0.000100s, root 640x2814
 5000 nodes: total 0.0080s, avg 0.000400s, root 640x14014
virtual list jumps (2000 jumps): total 0.0910s, avg 0.000046s, rendered avg 15.0, visible avg 15.0
incremental layout benchmark (5000 nodes, 20 iterations)
  clean cache hits: total 0.0010s, avg 0.000050s, root 640x14014
  root dirty relayout: total 0.0090s, avg 0.000450s, root 640x14014
  single leaf dirty: total 0.0100s, avg 0.000500s, root 640x14014
  single style change: total 0.0080s, avg 0.000400s, root 640x14014
allocation benchmark (5000 nodes, 20 iterations, steady-state KB)
  clean cache hits: total 1.559KB, avg 0.078KB, root 640x14014
  single leaf dirty: total 10.918KB, avg 0.546KB, root 640x14014
  branch dirty relayout: total 7.957KB, avg 0.398KB, root 640x14014
  full subtree relayout: total 8.199KB, avg 0.410KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations)
  root dirty measure cache: total 0.0040s, avg 0.000200s, measure calls 0, root 640x2814
  single measured leaf dirty: total 0.0040s, avg 0.000200s, measure calls 20, root 640x2814
```
