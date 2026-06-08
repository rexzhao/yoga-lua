# Benchmarks

Run with:

```sh
lua benchmarks/run.lua
.\LOVE\lovec.exe .\benchmarks\love2d
```

Optional arguments:

```sh
lua benchmarks/run.lua <iterations> <samples>
```

Timing results report the per-iteration average across each sample, then summarize samples as median/min/max. System Lua uses `os.clock()`. Love2D uses `love.timer.getTime()` for higher-resolution LuaJIT timing.

Heap growth results stop the collector after warmup and report steady-state heap growth, not total allocated bytes. The full subtree relayout case is a synthetic worst-case benchmark that marks every node dirty before layout.

Latest local runs:

System Lua 5.4.8:

```text
layout benchmark (20 iterations, 5 samples, per-iteration avg median/min/max)
  100 nodes: avg median 0.000000s, min 0.000000s, max 0.000800s, root 640x294
 1000 nodes: avg median 0.000800s, min 0.000750s, max 0.000800s, root 640x2814
 5000 nodes: avg median 0.005450s, min 0.004650s, max 0.005500s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000258s, min 0.000258s, max 0.000266s, rendered median 15.0, visible median 15.0
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000000s, min 0.000000s, max 0.000000s, root 640x14014
  root dirty relayout: avg median 0.004700s, min 0.004700s, max 0.004700s, root 640x14014
  single leaf dirty: avg median 0.004700s, min 0.003950s, max 0.004700s, root 640x14014
  single style change: avg median 0.005450s, min 0.004700s, max 0.005500s, root 640x14014
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.000KB, min 0.000KB, max 0.000KB, root 640x14014
  single leaf dirty: heap avg median 0.144KB, min 0.144KB, max 0.144KB, root 640x14014
  branch dirty relayout: heap avg median 0.152KB, min 0.152KB, max 0.152KB, root 640x14014
  full subtree relayout: heap avg median 0.155KB, min 0.155KB, max 0.155KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000800s, min 0.000800s, max 0.001550s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000800s, min 0.000750s, max 0.001600s, root 640x2814
    measure calls median 20, min 20, max 20
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations, 5 samples, per-iteration avg median/min/max)
  100 nodes: avg median 0.000015s, min 0.000008s, max 0.000187s, root 640x294
 1000 nodes: avg median 0.000074s, min 0.000069s, max 0.000080s, root 640x2814
 5000 nodes: avg median 0.000456s, min 0.000422s, max 0.000559s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000045s, min 0.000044s, max 0.000049s, rendered median 15.0, visible median 15.0
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000000s, min 0.000000s, max 0.000001s, root 640x14014
  root dirty relayout: avg median 0.000427s, min 0.000414s, max 0.000452s, root 640x14014
  single leaf dirty: avg median 0.000594s, min 0.000421s, max 0.001140s, root 640x14014
  single style change: avg median 0.000440s, min 0.000425s, max 0.001214s, root 640x14014
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.000KB, min 0.000KB, max 0.048KB, root 640x14014
  single leaf dirty: heap avg median 0.027KB, min 0.000KB, max 0.404KB, root 640x14014
  branch dirty relayout: heap avg median 0.027KB, min 0.000KB, max 0.397KB, root 640x14014
  full subtree relayout: heap avg median 0.039KB, min 0.000KB, max 0.409KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000083s, min 0.000082s, max 0.000131s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000092s, min 0.000092s, max 0.000188s, root 640x2814
    measure calls median 20, min 20, max 20
```
