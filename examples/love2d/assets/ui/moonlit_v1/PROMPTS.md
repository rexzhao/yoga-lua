# Moonlit UI Pack v1 Prompts

This pack is a trial of the UI-spec-first workflow. The master style can be replaced to make another pack while keeping component specs stable.

## Master Style

```text
Moonlit fantasy RPG UI pack. Dark obsidian lacquer, deep charcoal quiet centers, teal glass accents, restrained antique brass trim, soft top-left lighting, crisp painterly detail readable at small UI scale. Straight-on orthographic UI assets, no perspective. Decorative detail belongs near edges, corners, and caps; content centers stay calm and low-noise.

Global negative constraints: no text, letters, numbers, logos, watermark, icons unless requested, characters unless portrait art, shadows outside transparent frame assets, cropped corners, busy content centers, gradient chroma backgrounds, or chroma-key color inside the asset.
```

## Component Rules

| Asset | Draw mode | Final size | Stretch contract |
| --- | --- | ---: | --- |
| `panel` | `nine` | `512x217` | Body layer only: corners fixed, edges/center stretch. No midpoint ornaments on any edge. |
| `parchment` | `nine` | `512x265` | Body layer only: parchment center low-noise; no unique clasps in stretch strips. |
| `button` | `nine` | `512x164` | Body layer only: fixed left/right caps and smooth center. No center jewels or edge midpoint details. |
| `button_gold` | `nine` | `512x138` | Same as button, highlighted/gold body. No unique midpoint ornaments. |
| `slot` | `nine` | `256x246` | Body layer only: quiet center; decorations limited to non-stretch corners. |
| `bar_bg` | `threeX` | `512x96` | Left/right caps fixed; center is a plain stretchable trough, no midpoint ornament. |
| `bar_fill` | `threeX` | `384x41` | Left/right caps fixed; center is a plain stretchable fill, no midpoint ornament. |
| `portrait` | `cover` | `256x300` | Not stretchable; crop with face centered. |
| `pouch` | `contain` | `256x263` | Not stretchable; keep full item silhouette visible. |

## Prompt Pattern

For stretchable frame assets:

```text
Create a single {component body layer} on a perfectly flat solid #ff00ff background for chroma-key removal. Intended final asset: {width}x{height} PNG, {draw mode}, source insets {insets}. Use the master style, but keep this as a stretch-safe body layer. Straight-on orthographic. Only plain bevels, simple lines, and stretch-safe texture may appear in stretch regions. No unique ornament may appear in the center, top-center, bottom-center, left-center, or right-center stretch regions. No text, letters, numbers, logos, watermark, icons, characters, shadows, perspective, cropped ends/corners, busy center, gradient background, or #ff00ff inside the asset.
```

For all stretchable bodies, add this stricter line:

```text
Do not place any jewel, knot, emblem, notch, clasp, screw, badge, divider, or unique ornament in any stretchable strip. Decorative features must stay only in fixed corners/caps, or be generated later as separate overlay assets.
```

For non-stretch content art:

```text
Create {subject} for a Love2D RPG UI. Intended final asset: {width}x{height} PNG. It is not stretchable and will be drawn with {cover/contain}. Use the master style. Keep the subject centered for the target crop/fit behavior. No text, logos, watermark, or UI labels.
```

## Notes

The current pack generated the core UI assets plus `portrait` and `pouch`. Map tiles are still using the original demo images because image generation for those content images failed during this run; they are `cover` assets and do not affect the frame/stretch contract.

Known QA issue: the first generated `panel`, `parchment`, `button`, `button_gold`, `slot`, `bar_bg`, and `bar_fill` assets all contain some unique ornaments inside stretch regions. They are useful visual experiments but not final production body layers. `moonlit_v2` is the next experiment: plain stretch-safe body layers, with decorative jewels/clasps deferred to separate fixed-size overlay assets.
