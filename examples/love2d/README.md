# Love2D Visualizer

This directory is a small Love2D app for visually checking `yoga-lua` layouts.

Run it from the repository root:

```powershell
.\LOVE\love.exe .\examples\love2d
```

Run a non-interactive smoke check:

```powershell
.\LOVE\lovec.exe .\examples\love2d --smoke
```

Controls:

- `Left` / `Right`: switch demo cases.
- `1`, `2`, `3`: jump to a demo case.
- Move the mouse over a rectangle to inspect its computed layout.

The app imports the project modules from `../../src`; the `LOVE/` directory remains only the local Love2D runtime and is ignored by git.
