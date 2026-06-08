# Love2D RPG UI Demo

This directory is a small Love2D RPG-style UI demo for visually checking `yoga-lua` layouts in a more game-like flow.

Run it from the repository root:

```powershell
.\LOVE\love.exe .\examples\love2d
```

Run a non-interactive smoke check:

```powershell
.\LOVE\lovec.exe .\examples\love2d --smoke
```

Open a specific RPG screen or capture it for review:

```powershell
.\LOVE\lovec.exe .\examples\love2d --screen inventory
.\LOVE\lovec.exe .\examples\love2d --screen quests --screenshot $env:TEMP\yoga-rpg-quests.png
```

Controls:

- The app starts directly in the RPG field HUD.
- Click top navigation buttons to open Character, Skills, Bag, Quests, or Camp.
- `C`, `K`, `I`, `Q`, `M`, `H`: open Character, Skills, Bag, Quests, Camp, or Field.
- `Esc`: close the current RPG panel back to the field HUD.
- Move the mouse over a rectangle to inspect its computed layout.

The app imports the project modules from `../../src`; the `LOVE/` directory remains only the local Love2D runtime and is ignored by git.

The active RPG layout entry is `layouts/rpg_game.lua`. RPG interface descriptions live in `layouts/rpg/`, with each screen kept in its own file.
