-- RPG 主界面布局：展示角色状态、场景地图、队伍、任务追踪和快捷操作栏。
local common = require("layouts.rpg.common")

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local hero = state.hero
    local tracked = state:getTrackedQuest()

    local quick_actions = common.box(ctx, styles, "row", {
      debugName = "quick actions",
      fill = { 0, 0, 0, 0 },
      style = { height = 36 },
    }, {
      common.button(ctx, styles, "Use Potion", "quick-potion", {
        fill = palette.green,
        style = { width = 132, height = 34 },
      }),
      common.button(ctx, styles, "Rest", "rest", {
        fill = palette.accent,
        style = { width = 100, height = 34 },
      }),
      common.button(ctx, styles, "Open Bag", "nav", {
        screen = "inventory",
        fill = palette.panel_alt,
        style = { width = 110, height = 34 },
      }),
    })

    local party_cards = {}
    for _, member in ipairs(state.party) do
      party_cards[#party_cards + 1] = common.panel(ctx, styles, {
        debugName = member.name,
        fill = palette.panel_alt,
        style = { height = 64, padding = 8, gap = 4 },
      }, {
        common.text(ctx, member.name .. "  Lv." .. member.level, { style = { height = 18 }, fill = { 0, 0, 0, 0 } }),
        common.stat_bar(ctx, styles, "HP", member.hp, member.hpMax, palette.green),
      })
    end

    return common.box(ctx, styles, "screen", { debugName = "rpg hud", fill = palette.background }, {
      common.nav(ctx, styles, state, "hud"),
      common.box(ctx, styles, "body", { debugName = "hud body", fill = { 0, 0, 0, 0 } }, {
        common.box(ctx, styles, "column", {
          debugName = "left command column",
          fill = { 0, 0, 0, 0 },
          style = { width = 310, flex = 0 },
        }, {
          common.panel(ctx, styles, {
            debugName = "hero status",
            fill = palette.panel,
            style = { height = 178 },
          }, {
            common.text(ctx, hero.name .. "  Lv." .. hero.level .. " Ranger", {
              style = { height = 24 },
              fill = { 0, 0, 0, 0 },
            }),
            common.stat_bar(ctx, styles, "HP", hero.hp, hero.hpMax, palette.green),
            common.stat_bar(ctx, styles, "MP", hero.mp, hero.mpMax, palette.accent),
            common.stat_bar(ctx, styles, "XP", hero.xp, 100, palette.gold),
          }),
          common.panel(ctx, styles, {
            debugName = "party list",
            fill = palette.panel,
            style = { flex = 1 },
          }, party_cards),
        }),
        common.panel(ctx, styles, {
          debugName = "field map",
          fill = palette.panel,
          style = { flex = 1, padding = 12, gap = 10 },
        }, {
          common.text(ctx, "Moonwell Road", { style = { height = 28 }, fill = { 0, 0, 0, 0 } }),
          common.box(ctx, styles, "panel", {
            debugName = "map canvas",
            fill = { 0.12, 0.24, 0.20, 1 },
            style = { flex = 1, padding = 12, gap = 10 },
          }, {
            common.box(ctx, styles, "row", { debugName = "map row 1", fill = { 0, 0, 0, 0 }, style = { flex = 1 } }, {
              common.panel(ctx, styles, { debugName = "old bridge", fill = { 0.34, 0.28, 0.20, 1 }, style = { flex = 1 } }),
              common.panel(ctx, styles, { debugName = "forest path", fill = { 0.10, 0.34, 0.21, 1 }, style = { flex = 2 } }),
            }),
            common.box(ctx, styles, "row", { debugName = "map row 2", fill = { 0, 0, 0, 0 }, style = { flex = 1 } }, {
              common.panel(ctx, styles, { debugName = "camp fire", fill = palette.gold, style = { flex = 1 } }),
              common.panel(ctx, styles, { debugName = "ruins gate", fill = { 0.20, 0.22, 0.31, 1 }, style = { flex = 1 } }),
              common.panel(ctx, styles, { debugName = "river", fill = palette.accent, style = { flex = 1 } }),
            }),
          }),
          quick_actions,
          common.message(ctx, styles, state),
        }),
        common.box(ctx, styles, "column", {
          debugName = "right tracker column",
          fill = { 0, 0, 0, 0 },
          style = { width = 300, flex = 0 },
        }, {
          common.panel(ctx, styles, {
            debugName = "tracked quest",
            fill = palette.panel,
            style = { height = 178 },
          }, {
            common.text(ctx, "Tracked Quest", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, tracked and tracked.name or "No quest tracked", {
              style = { height = 24 },
              fill = palette.panel_alt,
            }),
            common.text(ctx, tracked and tracked.summary or "Open Quests to accept a task.", {
              style = { height = 72 },
              fill = { 0, 0, 0, 0 },
              textColor = palette.muted,
            }),
            common.button(ctx, styles, "Quests", "nav", {
              screen = "quests",
              fill = palette.accent,
              style = { height = 32 },
            }),
          }),
          common.panel(ctx, styles, {
            debugName = "combat log",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, "Recent Events", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, "Road ambush cleared.", { style = { height = 24 }, fill = palette.panel_alt }),
            common.text(ctx, "Found a sealed courier satchel.", { style = { height = 24 }, fill = palette.panel_alt }),
            common.text(ctx, "A vendor waits at camp.", { style = { height = 24 }, fill = palette.panel_alt }),
          }),
        }),
      }),
    })
  end,
}
