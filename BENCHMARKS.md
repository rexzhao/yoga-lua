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

Heap growth results stop the collector after warmup and report steady-state heap growth, not total allocated bytes. The full subtree relayout case is a synthetic worst-case benchmark that marks every node dirty before layout. Runtime reconciler results include virtual element construction, style resolution, diff/reconcile, Yoga layout when dirty, and layout snapshot/application work.

Latest local runs:

System Lua 5.4.8:

```text
layout benchmark (20 iterations, 5 samples, per-iteration avg median/min/max)
  100 nodes: avg median 0.000000s, min 0.000000s, max 0.000750s, root 640x294
 1000 nodes: avg median 0.000750s, min 0.000000s, max 0.000800s, root 640x2814
 5000 nodes: avg median 0.003150s, min 0.002350s, max 0.003150s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000265s, min 0.000258s, max 0.000273s, rendered median 15.0, visible median 15.0
runtime reconciler benchmark (1000 leaves, 20 iterations, 5 samples, per-iteration avg median/min/max)
  initial mount: avg median 0.025800s, min 0.024200s, max 0.028150s, root 640x2814
  clean rerender: avg median 0.008600s, min 0.008600s, max 0.010100s, root 640x2814
  prop-only rerender: avg median 0.008600s, min 0.007850s, max 0.009350s, root 640x2814
  single style change: avg median 0.010950s, min 0.009350s, max 0.010950s, root 640x2814
  keyed reorder: avg median 0.018750s, min 0.018750s, max 0.020300s, root 640x2814
  clean rerender stats: layout nodes 0.0, cache hits 0.0, rounded nodes 0.0, skipped rounded subtrees 0.0 per iter median
  prop-only rerender stats: layout nodes 0.0, cache hits 0.0, rounded nodes 0.0, skipped rounded subtrees 0.0 per iter median
  single style change stats: layout nodes 3.0, cache hits 108.0, rounded nodes 111.0, skipped rounded subtrees 99.0 per iter median
  keyed reorder stats: layout nodes 1046.0, cache hits 0.0, rounded nodes 1046.0, skipped rounded subtrees 0.0 per iter median
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000000s, min 0.000000s, max 0.000000s, root 640x14014
  root dirty relayout: avg median 0.003100s, min 0.002350s, max 0.003900s, root 640x14014
  single leaf dirty: avg median 0.003100s, min 0.002350s, max 0.003950s, root 640x14014
  single style change: avg median 0.003100s, min 0.003100s, max 0.003150s, root 640x14014
  full subtree relayout: avg median 0.049200s, min 0.046850s, max 0.050000s, root 640x14014
  root dirty relayout stats: layout nodes 1.0, cache hits 500.0, rounded nodes 501.0, skipped rounded subtrees 500.0 per iter median
  single leaf dirty stats: layout nodes 3.0, cache hits 508.0, rounded nodes 511.0, skipped rounded subtrees 499.0 per iter median
  full subtree relayout stats: layout nodes 5501.0, cache hits 0.0, rounded nodes 5501.0, skipped rounded subtrees 0.0 per iter median
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.000KB, min 0.000KB, max 0.000KB, root 640x14014
  single leaf dirty: heap avg median 0.155KB, min 0.155KB, max 0.155KB, root 640x14014
  branch dirty relayout: heap avg median 0.163KB, min 0.163KB, max 0.163KB, root 640x14014
  full subtree relayout: heap avg median 0.166KB, min 0.166KB, max 0.166KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000800s, min 0.000000s, max 0.000800s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000750s, min 0.000750s, max 0.000800s, root 640x2814
    measure calls median 20, min 20, max 20
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations, 5 samples, per-iteration avg median/min/max)
  100 nodes: avg median 0.000012s, min 0.000005s, max 0.000223s, root 640x294
 1000 nodes: avg median 0.000035s, min 0.000032s, max 0.000070s, root 640x2814
 5000 nodes: avg median 0.000226s, min 0.000216s, max 0.000274s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000088s, min 0.000080s, max 0.000088s, rendered median 15.0, visible median 15.0
runtime reconciler benchmark (1000 leaves, 20 iterations, 5 samples, per-iteration avg median/min/max)
  initial mount: avg median 0.007632s, min 0.007042s, max 0.008160s, root 640x2814
  clean rerender: avg median 0.001934s, min 0.001575s, max 0.003377s, root 640x2814
  prop-only rerender: avg median 0.001714s, min 0.001501s, max 0.002370s, root 640x2814
  single style change: avg median 0.001759s, min 0.001663s, max 0.004418s, root 640x2814
  keyed reorder: avg median 0.004491s, min 0.004270s, max 0.005499s, root 640x2814
  clean rerender stats: layout nodes 0.0, cache hits 0.0, rounded nodes 0.0, skipped rounded subtrees 0.0 per iter median
  prop-only rerender stats: layout nodes 0.0, cache hits 0.0, rounded nodes 0.0, skipped rounded subtrees 0.0 per iter median
  single style change stats: layout nodes 3.0, cache hits 108.0, rounded nodes 111.0, skipped rounded subtrees 99.0 per iter median
  keyed reorder stats: layout nodes 1046.0, cache hits 0.0, rounded nodes 1046.0, skipped rounded subtrees 0.0 per iter median
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000000s, min 0.000000s, max 0.000003s, root 640x14014
  root dirty relayout: avg median 0.000233s, min 0.000215s, max 0.000356s, root 640x14014
  single leaf dirty: avg median 0.000266s, min 0.000241s, max 0.000286s, root 640x14014
  single style change: avg median 0.000235s, min 0.000218s, max 0.000260s, root 640x14014
  full subtree relayout: avg median 0.012553s, min 0.012246s, max 0.014001s, root 640x14014
  root dirty relayout stats: layout nodes 1.0, cache hits 500.0, rounded nodes 501.0, skipped rounded subtrees 500.0 per iter median
  single leaf dirty stats: layout nodes 3.0, cache hits 508.0, rounded nodes 511.0, skipped rounded subtrees 499.0 per iter median
  full subtree relayout stats: layout nodes 5501.0, cache hits 0.0, rounded nodes 5501.0, skipped rounded subtrees 0.0 per iter median
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.000KB, min 0.000KB, max 0.000KB, root 640x14014
  single leaf dirty: heap avg median 0.027KB, min 0.000KB, max 0.034KB, root 640x14014
  branch dirty relayout: heap avg median 0.027KB, min 0.000KB, max 0.028KB, root 640x14014
  full subtree relayout: heap avg median 0.041KB, min 0.000KB, max 0.047KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000031s, min 0.000030s, max 0.000034s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000054s, min 0.000053s, max 0.000087s, root 640x2814
    measure calls median 20, min 20, max 20
```
