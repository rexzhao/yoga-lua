-- RPG 技能界面布局：展示技能列表、技能详情、消耗、冷却和快捷栏配置。
local common = require("layouts.rpg.common")

local function skill_row(ctx, styles, skill, selected)
  local palette = ctx.palette
  return common.box(ctx, styles, "row", {
    action = "select-skill",
    skillId = skill.id,
    debugName = skill.name,
    fill = selected and palette.accent or palette.panel_alt,
    style = { height = 54, padding = 8 },
  }, {
    common.text(ctx, skill.name, {
      action = "select-skill",
      skillId = skill.id,
      style = { flex = 1, height = 20 },
      fill = { 0, 0, 0, 0 },
    }),
    common.text(ctx, skill.cost .. " MP", {
      action = "select-skill",
      skillId = skill.id,
      style = { width = 64, height = 20 },
      fill = { 0, 0, 0, 0 },
      textColor = palette.muted,
    }),
  })
end

local function hotbar_slot(ctx, styles, index, skill)
  return common.panel(ctx, styles, {
    debugName = "hotbar " .. index,
    fill = skill and ctx.palette.accent or ctx.palette.panel_alt,
    style = { flex = 1, height = 58, padding = 8 },
  }, {
    common.text(ctx, tostring(index), { style = { height = 16 }, fill = { 0, 0, 0, 0 }, textColor = ctx.palette.muted }),
    common.text(ctx, skill and skill.name or "Empty", { style = { height = 22 }, fill = { 0, 0, 0, 0 } }),
  })
end

return {
  build = function(ctx, width, height, state)
    local styles = common.styles(ctx, width, height)
    local palette = ctx.palette
    local selected = state:getSelectedSkill()
    local rows = {}

    for _, skill in ipairs(state.skills) do
      rows[#rows + 1] = skill_row(ctx, styles, skill, selected and selected.id == skill.id)
    end

    local hotbar = {}
    for index = 1, 5 do
      hotbar[#hotbar + 1] = hotbar_slot(ctx, styles, index, state:getHotbarSkill(index))
    end

    return common.box(ctx, styles, "screen", { debugName = "skills screen", fill = palette.background }, {
      common.nav(ctx, styles, state, "skills"),
      common.box(ctx, styles, "body", { debugName = "skills body", fill = { 0, 0, 0, 0 } }, {
        common.panel(ctx, styles, {
          debugName = "skill list",
          fill = palette.panel,
          style = { width = 360, flex = 0 },
        }, rows),
        common.box(ctx, styles, "column", { debugName = "skill detail column", fill = { 0, 0, 0, 0 } }, {
          common.panel(ctx, styles, {
            debugName = "skill detail",
            fill = palette.panel,
            style = { flex = 1 },
          }, {
            common.text(ctx, selected.name, { style = { height = 30 }, fill = { 0, 0, 0, 0 } }),
            common.text(ctx, selected.school .. " / " .. selected.kind, {
              style = { height = 24 },
              fill = palette.panel_alt,
              textColor = palette.muted,
            }),
            common.text(ctx, selected.description, {
              style = { height = 72 },
              fill = { 0, 0, 0, 0 },
              textColor = palette.text,
            }),
            common.box(ctx, styles, "row", { debugName = "skill numbers", fill = { 0, 0, 0, 0 }, style = { height = 40 } }, {
              common.panel(ctx, styles, { debugName = "cost", fill = palette.panel_alt, style = { flex = 1, padding = 8 } }, {
                common.text(ctx, "Cost " .. selected.cost .. " MP", { style = { height = 20 }, fill = { 0, 0, 0, 0 } }),
              }),
              common.panel(ctx, styles, { debugName = "cooldown", fill = palette.panel_alt, style = { flex = 1, padding = 8 } }, {
                common.text(ctx, "Cooldown " .. selected.cooldown .. "s", { style = { height = 20 }, fill = { 0, 0, 0, 0 } }),
              }),
            }),
            common.button(ctx, styles, "Set to Slot 1", "equip-skill", {
              skillId = selected.id,
              fill = palette.green,
              style = { width = 180, height = 34 },
            }),
          }),
          common.panel(ctx, styles, {
            debugName = "hotbar",
            fill = palette.panel,
            style = { height = 100 },
          }, {
            common.text(ctx, "Quick Skills", { style = { height = 24 }, fill = { 0, 0, 0, 0 } }),
            common.box(ctx, styles, "row", { debugName = "hotbar row", fill = { 0, 0, 0, 0 }, style = { flex = 1 } }, hotbar),
          }),
        }),
      }),
      common.message(ctx, styles, state),
    })
  end,
}
