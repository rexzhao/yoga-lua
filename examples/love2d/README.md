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

- The app starts on a Yoga-rendered selection screen.
- Click a UI option to open it.
- `Up` / `Down`: move the selected option.
- `Enter` / `Space`: open the selected option.
- `1`, `2`, `3`: open a UI option directly from the selection screen.
- `Esc`: return from a UI screen to the selection screen.
- Move the mouse over a rectangle to inspect its computed layout.

The app imports the project modules from `../../src`; the `LOVE/` directory remains only the local Love2D runtime and is ignored by git.

UI layout modules live in `layouts/`. Each file returns one layout descriptor used by the visualizer.
