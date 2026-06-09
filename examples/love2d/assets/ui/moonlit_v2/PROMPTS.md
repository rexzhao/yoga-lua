# Moonlit UI Pack v2 Prompts

This pack is a stretch-safety experiment. It intentionally uses plain body layers for the stretchable assets. The result is less decorative than `moonlit_v1`, but it is compatible with nine-slice and horizontal three-slice rendering.

## Master Style

```text
Moonlit fantasy RPG UI body layers. Dark obsidian lacquer, deep charcoal low-noise fills, teal glass edge tint, restrained antique brass/gold state accents, soft top-left lighting, straight-on orthographic UI assets.
```

## Strict Body-Layer Rule

```text
This is a stretch-safe body layer, not a finished decorative frame. Stretch regions must contain only continuous fill, continuous bevel lines, and subtle stretch-safe texture. Do not place any jewel, knot, emblem, notch, clasp, screw, badge, divider, midpoint ornament, isolated highlight, or unique feature in the center, top-center, bottom-center, left-center, or right-center stretch regions.
```

## Assets

| Asset | Draw mode | Final size | Result |
| --- | --- | ---: | --- |
| `panel` | `nine` | `512x217` | Plain obsidian panel body, teal/brass continuous bevel. |
| `parchment` | `nine` | `512x265` | Plain parchment card body with continuous trim. |
| `button` | `nine` | `512x164` | Plain dark button body, fixed rounded caps, seamless center. |
| `button_gold` | `nine` | `512x138` | Gold/amber state body, seamless center. |
| `slot` | `nine` | `256x246` | Plain slot body with quiet center. |
| `bar_bg` | `threeX` | `512x96` | Continuous empty trough, fixed rounded caps. |
| `bar_fill` | `threeX` | `384x41` | Continuous teal fill, fixed rounded caps. |

`portrait` and `pouch` are reused from `moonlit_v1` because they are content assets (`cover` / `contain`) and do not participate in stretch safety. Map tiles remain the original demo content assets.

## Next Step

After the renderer supports fixed overlay placement, add separate non-stretch assets such as `panel_corner`, `panel_top_ornament`, `button_cap`, or `slot_corner` to bring back visual richness without contaminating stretch regions.
