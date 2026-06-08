-- RPG 角色界面布局：展示装备栏、属性、抗性、声望和成长进度。
local common = require("layouts.rpg.common")

local function stat_row(ctx, styles, name, value)
  return common.box(ctx, styles, "row", {
    debugName = name,
    fill = ctx.palette.panel_alt,
    style = { height = 28, paddingHorizontal = 8, paddingVertical = 5 },
  }, {
    common.text(ctx, name, { style = { width = 150, height = 18 }, fill = { 0, 0, 0, 0 } }),
    common.text(ctx, tostring(value), { style = { flex = 1, height = 18 }, fill = { 0, 0, 0, 0 } }),
  })
end

local function slot(ctx, styles, label, item)
  return common.panel(ctx, styles, {
    debugName = label,
    image = "slot",
    tint = item and { 1, 1, 1, 1 } or { 0.55, 0.58, 0.62, 1 },
    fill = item and ctx.palette.panel_alt or { 0.12, 0.13, 0.15, 1 },
    style = { height = 50, padding = 8 },
  }, {
    common.text(ctx, label, { style = { height = 16 }, fill = { 0, 0, 0, 0 }, textColor = ctx.palette.muted }),
    common.text(ctx, item or "Empty", { style = { height = 20 }, fill = { 0, 0, 0, 0 } }),
  })
end

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local hero = state.hero

    return common.box(ctx, styles, "screen", { debugName = "character screen", fill = palette.background }, {
      common.nav(ctx, styles, state, "character"),
      common.box(ctx, styles, "body", { debugName = "character body", fill = { 0, 0, 0, 0 } }, {
        common.box(ctx, styles, "column", {
          debugName = "paper doll column",
          fill = { 0, 0, 0, 0 },
          style = { width = 320, flex = 0 },
        }, {
          common.panel(ctx, styles, {
            debugName = "portrait",
            fill = palette.panel,
            style = { height = 310, padding = 12, gap = 10 },
          }, {
            common.text(ctx, hero.name, { style = { height = 30 }, fill = { 0, 0, 0, 0 } }),
            common.panel(ctx, styles, {
              debugName = "portrait art",
              image = "portrait",
              imageFit = "cover",
              fill = { 0.21, 0.30, 0.38, 1 },
              style = { flex = 1 },
            }),
            common.stat_bar(ctx, styles, "HP", hero.hp, hero.hpMax, palette.green),
          }),
          common.panel(ctx, styles, {
            debugName = "growth",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, "Progress", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.stat_bar(ctx, styles, "XP", hero.xp, 100, palette.gold),
            common.text(ctx, "Next talent unlock: Level 13", { style = { height = 24 }, fill = palette.panel_alt }),
            common.text(ctx, "Title: Warden of the Moonwell", { style = { height = 24 }, fill = palette.panel_alt }),
          }),
        }),
        common.panel(ctx, styles, {
          debugName = "equipment",
          fill = palette.panel,
          style = { width = 330, flex = 0 },
        }, {
          common.text(ctx, "Equipment", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
          slot(ctx, styles, "Weapon", "Ashwood Bow"),
          slot(ctx, styles, "Armor", "Roadwarden Coat"),
          slot(ctx, styles, "Trinket", "Moon Charm"),
          slot(ctx, styles, "Boots", "Trail Boots"),
          slot(ctx, styles, "Relic", nil),
        }),
        common.box(ctx, styles, "column", { debugName = "stats column", fill = { 0, 0, 0, 0 } }, {
          common.panel(ctx, styles, {
            debugName = "attributes",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, "Attributes", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
            stat_row(ctx, styles, "Might", hero.stats.might),
            stat_row(ctx, styles, "Agility", hero.stats.agility),
            stat_row(ctx, styles, "Spirit", hero.stats.spirit),
            stat_row(ctx, styles, "Armor", hero.stats.armor),
            stat_row(ctx, styles, "Crit", hero.stats.crit .. "%"),
          }),
          common.panel(ctx, styles, {
            debugName = "reputation",
            fill = palette.panel,
            style = { height = 146 },
          }, {
            common.text(ctx, "Reputation", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.stat_bar(ctx, styles, "Guild", 68, 100, palette.accent),
            common.stat_bar(ctx, styles, "Town", 42, 100, palette.green),
          }),
        }),
      }),
      common.message(ctx, styles, state),
    })
  end,
}
