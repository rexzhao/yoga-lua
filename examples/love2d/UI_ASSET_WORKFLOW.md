# Love2D RPG UI Asset Workflow

This demo treats generated UI art as a small asset package, not as arbitrary backgrounds. The stable contract is:

1. Define component metrics and asset roles in `ui_assets.lua`.
2. Generate PNGs for those roles with explicit safe areas and stretch rules.
3. Register every PNG in the manifest before using it in layout code.
4. Verify through Love2D smoke and screenshots.

The visual theme can change freely. Asset ids, draw modes, safe areas, and component metrics should change only when the UI structure changes.

The first trial pack using this workflow lives in `assets/ui/moonlit_v1/`, with its reusable master prompt and component rules in `assets/ui/moonlit_v1/PROMPTS.md`.

## Component Metrics

Use a 4 px grid, with 8/12/16 px as the normal spacing scale.

- Screen: 16 px padding, 12 px major gaps.
- Panel: 12 px padding, 8 px internal gaps.
- Navigation: 44 px high, 34 px buttons, 126 px fixed nav buttons plus one flexible status button.
- Button: 34 px normal height, 30 px small height, horizontal stretch only through nine-slice caps.
- Slot: 104 x 80 item cards, 8 px padding.
- Status bar: 12 px bar height, 38 px label-plus-bar group.
- Message bar: 60 px high, 12 px padding.

These numbers live in `ui_assets.lua` so renderer, layouts, and asset generation prompts share the same vocabulary.

## Draw Modes

- `nine`: plain frame/body assets only. Corners keep their target size; edge strips and center stretch.
- `threeX`: horizontal bars. Left and right caps keep their target width; the center stretches.
- `cover`: portraits and map tiles. The image keeps aspect ratio and fills the node with clipping.
- `contain`: item preview art. The image keeps aspect ratio and stays fully visible.
- `stretch`: only for assets that are designed to deform. Avoid it for decorative UI frames.

The manifest separates source slice pixels from target border pixels. A 512 px wide generated button can therefore draw as a 34 px high control without compressing the corner art into the text area.

Important: nine-slice does not make a decorative frame safe by itself. It only works when the stretch regions are intentionally boring.

## Stretch Safety

Every stretchable asset must keep localized ornaments out of stretch regions.

- Corners and caps may contain jewels, knots, screws, bevel clusters, or other unique details.
- Stretch regions may contain only plain fill, simple bevel lines, or textures that can stretch without looking wrong.
- Buttons, panels, parchment frames, slots, and bars should not include centered jewels or midpoint ornaments inside stretchable top/bottom/side strips.
- If a design needs a jewel, screw, clasp, notch, badge, or midpoint ornament, split it into a separate fixed-size overlay asset such as `panel_top_ornament`, `button_left_cap`, or `slot_corner`.
- If an asset violates this rule, it fails QA even when the PNG size and alpha are valid.

Good stretchable assets are usually less exciting than final UI: they are the plain body layer. Final richness comes from optional fixed-size overlays and content.

## Recommended Asset Layers

For AI-generated UI, prefer layered component specs instead of one richly decorated frame:

| Layer | Stretch mode | What belongs here |
| --- | --- | --- |
| `*_body` | `nine` or `threeX` | Plain fill, simple bevel, stretch-safe edge texture. |
| `*_corner` / `*_cap` | fixed draw | Jewels, metal knots, screws, unique cap shapes. |
| `*_ornament` | fixed draw | Center badges, top/bottom clasps, dividers, selection markers. |
| `*_content` | `cover` / `contain` | Portraits, maps, item art, icons. |

The first production pass should generate body layers first. Overlay ornaments can be added after the renderer supports fixed overlay placement.

## Manifest Fields

Each entry in `ui_assets.lua` should include:

- `file`: PNG name under `assets/ui/` without extension.
- `size`: expected source PNG size. Smoke should fail if this drifts.
- `mode`: `nine`, `threeX`, `cover`, `contain`, or explicit `stretch`.
- `slice`: source pixels reserved for caps/corners.
- `border`: target pixels used for caps/corners in Love2D.
- `minWidth` / `minHeight`: smallest practical rendered size.
- `filter`: usually `linear` for generated painterly assets.

## AI Prompt Template

```text
Create a game UI asset for a Love2D RPG demo.

Asset:
- id: {asset_id}
- role: {panel | button | slot | bar_bg | bar_fill | portrait | map_tile | item_art}
- canvas: {width}x{height}px
- output: transparent PNG, sRGB, 8-bit alpha
- style: {theme card}
- safe content area: keep the center calm and low-detail for text/icons
- border area: decorative detail allowed near edges and corners only
- lighting: consistent top-left UI lighting

Negative constraints:
- no text, letters, numbers, logos, or watermark
- no opaque full-canvas background for frame assets
- no fake shadow outside the asset silhouette
- no perspective tilt
- no cropped corners
- no busy texture in the text-safe center
```

For `nine` assets, add:

```text
This asset will be nine-sliced. Corners must be visually independent. Edges should stretch cleanly. The center should be plain and safe for text. Source slice inset: left {l}px, right {r}px, top {t}px, bottom {b}px.
```

## QA Checklist

Run smoke first:

```powershell
.\LOVE\lovec.exe .\examples\love2d --smoke
```

Capture all major screens:

```powershell
foreach ($screen in "hud","character","skills","inventory","quests","camp") {
  .\LOVE\lovec.exe .\examples\love2d --screen $screen --screenshot "$env:TEMP\yoga-rpg-$screen.png"
}
```

Check:

- Every `assets/ui/*.png` used by the demo has a manifest entry.
- PNG dimensions match the manifest.
- Nine-slice corners and bar caps are not visibly compressed.
- Stretch regions do not contain unique ornaments that become smeared or elongated.
- At least one debug screenshot should render each stretchable asset at a narrow, normal, and wide size.
- Text sits inside calm center areas and remains readable.
- `cover` art has no letterboxing; `contain` art is not distorted.
- Screens remain usable at the default `1100x720` window and one narrower aspect ratio.
