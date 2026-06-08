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
  100 nodes: avg median 0.000000s, min 0.000000s, max 0.000000s, root 640x294
 1000 nodes: avg median 0.000800s, min 0.000000s, max 0.000800s, root 640x2814
 5000 nodes: avg median 0.003150s, min 0.003100s, max 0.003150s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000273s, min 0.000265s, max 0.000282s, rendered median 15.0, visible median 15.0
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000000s, min 0.000000s, max 0.000000s, root 640x14014
  root dirty relayout: avg median 0.003100s, min 0.002350s, max 0.003150s, root 640x14014
  single leaf dirty: avg median 0.003150s, min 0.003100s, max 0.003150s, root 640x14014
  single style change: avg median 0.003100s, min 0.002300s, max 0.003150s, root 640x14014
  full subtree relayout: avg median 0.046100s, min 0.044550s, max 0.052350s, root 640x14014
  root dirty relayout stats: layout nodes 1.0, cache hits 500.0, rounded nodes 501.0, skipped rounded subtrees 500.0 per iter median
  single leaf dirty stats: layout nodes 3.0, cache hits 508.0, rounded nodes 511.0, skipped rounded subtrees 499.0 per iter median
  full subtree relayout stats: layout nodes 5501.0, cache hits 0.0, rounded nodes 5501.0, skipped rounded subtrees 0.0 per iter median
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.000KB, min 0.000KB, max 0.000KB, root 640x14014
  single leaf dirty: heap avg median 0.145KB, min 0.145KB, max 0.145KB, root 640x14014
  branch dirty relayout: heap avg median 0.153KB, min 0.153KB, max 0.153KB, root 640x14014
  full subtree relayout: heap avg median 0.156KB, min 0.156KB, max 0.156KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000750s, min 0.000000s, max 0.000800s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000800s, min 0.000750s, max 0.000800s, root 640x2814
    measure calls median 20, min 20, max 20
```

Love2D 11.4.0 / LuaJIT 2.1.0-beta3:

```text
layout benchmark (20 iterations, 5 samples, per-iteration avg median/min/max)
  100 nodes: avg median 0.000007s, min 0.000003s, max 0.000225s, root 640x294
 1000 nodes: avg median 0.000032s, min 0.000030s, max 0.000034s, root 640x2814
 5000 nodes: avg median 0.000231s, min 0.000184s, max 0.000279s, root 640x14014
virtual list jumps (2000 jumps, 5 samples): avg median 0.000049s, min 0.000047s, max 0.000054s, rendered median 15.0, visible median 15.0
incremental layout benchmark (5000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  clean cache hits: avg median 0.000004s, min 0.000000s, max 0.000006s, root 640x14014
  root dirty relayout: avg median 0.000195s, min 0.000176s, max 0.000226s, root 640x14014
  single leaf dirty: avg median 0.000214s, min 0.000206s, max 0.000335s, root 640x14014
  single style change: avg median 0.000194s, min 0.000185s, max 0.000219s, root 640x14014
  full subtree relayout: avg median 0.002701s, min 0.002550s, max 0.003974s, root 640x14014
  root dirty relayout stats: layout nodes 1.0, cache hits 500.0, rounded nodes 501.0, skipped rounded subtrees 500.0 per iter median
  single leaf dirty stats: layout nodes 3.0, cache hits 508.0, rounded nodes 511.0, skipped rounded subtrees 499.0 per iter median
  full subtree relayout stats: layout nodes 5501.0, cache hits 0.0, rounded nodes 5501.0, skipped rounded subtrees 0.0 per iter median
heap growth benchmark (5000 nodes, 20 iterations, 5 samples, steady-state KB growth median/min/max)
  clean cache hits: heap avg median 0.071KB, min 0.000KB, max 0.078KB, root 640x14014
  single leaf dirty: heap avg median 0.027KB, min 0.000KB, max 0.764KB, root 640x14014
  branch dirty relayout: heap avg median 0.027KB, min 0.000KB, max 0.410KB, root 640x14014
  full subtree relayout: heap avg median 0.041KB, min 0.000KB, max 0.430KB, root 640x14014
measured-node incremental benchmark (1000 nodes, 20 iterations, 5 samples, per-iteration avg median/min/max)
  root dirty measure cache: avg median 0.000027s, min 0.000026s, max 0.000039s, root 640x2814
    measure calls median 0, min 0, max 0
  single measured leaf dirty: avg median 0.000034s, min 0.000032s, max 0.000129s, root 640x2814
    measure calls median 20, min 20, max 20
```
