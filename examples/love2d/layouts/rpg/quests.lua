-- RPG 任务界面布局：展示可接/已接任务、目标进度，并支持接受、放弃和追踪。
local common = require("layouts.rpg.common")

local function quest_row(ctx, styles, quest, selected)
  local palette = ctx.palette
  local status_color = quest.status == "accepted" and palette.green or palette.gold

  return common.box(ctx, styles, "row", {
    action = "select-quest",
    questId = quest.id,
    debugName = quest.name,
    image = "button",
    tint = selected and { 0.62, 0.82, 1, 1 } or { 0.88, 0.82, 0.66, 1 },
    fill = selected and palette.accent or palette.panel_alt,
    style = { height = 58, padding = 8 },
  }, {
    common.text(ctx, quest.name, {
      action = "select-quest",
      questId = quest.id,
      style = { flex = 1, height = 20 },
      fill = { 0, 0, 0, 0 },
    }),
    common.text(ctx, quest.status, {
      action = "select-quest",
      questId = quest.id,
      style = { width = 88, height = 20 },
      fill = status_color,
    }),
  })
end

local function objective_rows(ctx, styles, quest)
  local rows = {}

  for _, objective in ipairs(quest.objectives) do
    rows[#rows + 1] = common.box(ctx, styles, "row", {
      debugName = objective.text,
      image = "button",
      tint = { 0.70, 0.74, 0.78, 1 },
      fill = ctx.palette.panel_alt,
      style = { height = 34, padding = 8 },
    }, {
      common.text(ctx, objective.text, { style = { flex = 1, height = 18 }, fill = { 0, 0, 0, 0 } }),
      common.text(ctx, objective.current .. "/" .. objective.total, {
        style = { width = 64, height = 18 },
        fill = { 0, 0, 0, 0 },
        textColor = ctx.palette.muted,
      }),
    })
  end

  return rows
end

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local selected = state:getSelectedQuest()
    local rows = {}

    for _, quest in ipairs(state.quests) do
      rows[#rows + 1] = quest_row(ctx, styles, quest, selected.id == quest.id)
    end

    return common.box(ctx, styles, "screen", { debugName = "quest screen", fill = palette.background }, {
      common.nav(ctx, styles, state, "quests"),
      common.box(ctx, styles, "body", { debugName = "quest body", fill = { 0, 0, 0, 0 } }, {
        common.panel(ctx, styles, {
          debugName = "quest list",
          fill = palette.panel,
          style = { width = 420, flex = 0 },
        }, rows),
        common.box(ctx, styles, "column", { debugName = "quest detail column", fill = { 0, 0, 0, 0 } }, {
          common.panel(ctx, styles, {
            debugName = "quest detail",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, selected.name, { style = { height = 30 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, selected.summary, {
              style = { height = 70 },
              fill = { 0, 0, 0, 0 },
              textColor = palette.text,
            }),
            common.text(ctx, "Objectives", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            ctx.unpack(objective_rows(ctx, styles, selected)),
          }),
          common.panel(ctx, styles, {
            debugName = "quest rewards",
            fill = palette.panel,
            style = { height = 126 },
          }, {
            common.text(ctx, "Rewards", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, selected.reward, { style = { height = 28 }, fill = palette.panel_alt }),
            common.box(ctx, styles, "row", { debugName = "quest actions", fill = { 0, 0, 0, 0 }, style = { height = 36 } }, {
              common.button(ctx, styles, "Accept", "accept-quest", {
                questId = selected.id,
                fill = palette.green,
                style = { flex = 1, height = 34 },
              }),
              common.button(ctx, styles, "Abandon", "abandon-quest", {
                questId = selected.id,
                fill = palette.red,
                style = { flex = 1, height = 34 },
              }),
              common.button(ctx, styles, "Track", "track-quest", {
                questId = selected.id,
                fill = palette.accent,
                style = { flex = 1, height = 34 },
              }),
            }),
          }),
        }),
      }),
      common.message(ctx, styles, state),
    })
  end,
}
