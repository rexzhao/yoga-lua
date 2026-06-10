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

Show layout helper frames and hover geometry while developing:

```powershell
.\LOVE\lovec.exe .\examples\love2d --debug-layout
```

Controls:

- The app starts directly in the RPG field HUD.
- Click top navigation buttons to open Character, Skills, Bag, Quests, or Camp.
- In Bag, click category rows to filter the item grid.
- `C`, `K`, `I`, `Q`, `M`, `H`: open Character, Skills, Bag, Quests, Camp, or Field.
- `Esc`: close the current RPG panel back to the field HUD.
- Run with `--debug-layout` and move the mouse over a node to inspect its computed layout.

The app imports the project modules from `../../src`; the `LOVE/` directory remains only the local Love2D runtime and is ignored by git.

The active RPG layout entry is `layouts/rpg_game.lua`. RPG interface descriptions live in `layouts/rpg/`, with each screen kept in its own file.

Generated base UI resources live in `assets/ui/`. They are imagegen-derived PNGs used by the Love2D renderer for panels, buttons, slots, bars, portraits, item art, and map tiles.

UI asset roles, draw modes, and generation/QA rules are documented in `UI_ASSET_WORKFLOW.md`. The renderer now loads those assets through `ui_assets.lua`, which records expected PNG sizes plus whether each asset should draw as nine-slice, horizontal three-slice, cover, or contain.
