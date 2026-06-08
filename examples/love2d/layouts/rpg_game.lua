-- RPG 游戏入口布局：管理演示状态并编排各个独立 RPG 界面描述文件。
local screens = {
  hud = require("layouts.rpg.hud"),
  character = require("layouts.rpg.character"),
  skills = require("layouts.rpg.skills"),
  inventory = require("layouts.rpg.inventory"),
  quests = require("layouts.rpg.quests"),
  camp = require("layouts.rpg.camp"),
}

local screen_aliases = {
  field = "hud",
  hud = "hud",
  character = "character",
  char = "character",
  skills = "skills",
  skill = "skills",
  inventory = "inventory",
  bag = "inventory",
  items = "inventory",
  quests = "quests",
  quest = "quests",
  camp = "camp",
  shop = "camp",
}

local State = {}
State.__index = State

function State:findById(list, id)
  for _, item in ipairs(list) do
    if item.id == id then
      return item
    end
  end

  return nil
end

function State:getSelectedItem()
  return self:findById(self.inventory, self.selectedItemId) or self.inventory[1]
end

function State:getSelectedSkill()
  return self:findById(self.skills, self.selectedSkillId) or self.skills[1]
end

function State:getSelectedQuest()
  return self:findById(self.quests, self.selectedQuestId) or self.quests[1]
end

function State:getTrackedQuest()
  return self:findById(self.quests, self.trackedQuestId)
end

function State:getHotbarSkill(index)
  return self:findById(self.skills, self.hotbar[index])
end

function State:setScreen(screen)
  screen = screen_aliases[tostring(screen or ""):lower()]
  if screen and screens[screen] then
    self.screen = screen
    return true
  end

  return false
end

function State:addInventoryItem(template)
  local existing = self:findById(self.inventory, template.id)
  if existing then
    existing.qty = existing.qty + 1
    return existing
  end

  local item = {}
  for key, value in pairs(template) do
    item[key] = value
  end
  item.qty = 1
  self.inventory[#self.inventory + 1] = item
  return item
end

local function create_state()
  return setmetatable({
    screen = "hud",
    selectedItemId = "potion",
    selectedSkillId = "moonshot",
    selectedQuestId = "courier",
    trackedQuestId = "courier",
    message = "Welcome to Moonwell Road. Open panels with the top buttons or hotkeys.",
    hero = {
      name = "Ari Vale",
      level = 12,
      hp = 76,
      hpMax = 120,
      mp = 44,
      mpMax = 70,
      xp = 62,
      gold = 326,
      stats = {
        might = 16,
        agility = 24,
        spirit = 18,
        armor = 31,
        crit = 18,
      },
    },
    party = {
      { name = "Mira", level = 11, hp = 88, hpMax = 96 },
      { name = "Tovan", level = 10, hp = 104, hpMax = 118 },
      { name = "Sel", level = 9, hp = 51, hpMax = 72 },
    },
    materials = {
      ironwood = 7,
      thread = 12,
      dust = 4,
    },
    inventory = {
      {
        id = "potion",
        name = "Red Potion",
        type = "Consumable",
        rarity = "common",
        qty = 5,
        usable = true,
        heal = 35,
        description = "Restores 35 HP. Useful when a fight turns messy.",
      },
      {
        id = "ether",
        name = "Blue Ether",
        type = "Consumable",
        rarity = "common",
        qty = 3,
        usable = true,
        mana = 24,
        description = "Restores 24 MP and keeps skill chains running.",
      },
      {
        id = "moon_charm",
        name = "Moon Charm",
        type = "Trinket",
        rarity = "rare",
        qty = 1,
        usable = false,
        description = "A rare charm that improves night scouting checks.",
      },
      {
        id = "ironwood",
        name = "Ironwood",
        type = "Material",
        rarity = "common",
        qty = 7,
        usable = false,
        description = "Dense timber used for bows, shields, and camp repairs.",
      },
      {
        id = "sealed_satchel",
        name = "Sealed Satchel",
        type = "Quest",
        rarity = "rare",
        qty = 1,
        usable = false,
        description = "A courier bag marked with the guild crest.",
      },
      {
        id = "smoke_bomb",
        name = "Smoke Bomb",
        type = "Tool",
        rarity = "common",
        qty = 2,
        usable = true,
        description = "Creates cover and restores a small amount of MP.",
        mana = 8,
      },
      {
        id = "trail_tonic",
        name = "Trail Tonic",
        type = "Consumable",
        rarity = "common",
        qty = 1,
        usable = true,
        heal = 18,
        mana = 10,
        description = "A balanced tonic for long field runs.",
      },
    },
    skills = {
      {
        id = "moonshot",
        name = "Moonshot",
        school = "Ranger",
        kind = "Damage",
        cost = 12,
        cooldown = 4,
        description = "A focused arrow that pierces armor and marks the target.",
      },
      {
        id = "rootsnare",
        name = "Rootsnare",
        school = "Warden",
        kind = "Control",
        cost = 16,
        cooldown = 8,
        description = "Pins enemies in place and creates space for the party.",
      },
      {
        id = "quickmend",
        name = "Quick Mend",
        school = "Fieldcraft",
        kind = "Support",
        cost = 18,
        cooldown = 10,
        description = "Restores health to the lowest party member.",
      },
      {
        id = "flare",
        name = "Signal Flare",
        school = "Tactics",
        kind = "Utility",
        cost = 8,
        cooldown = 6,
        description = "Reveals hidden paths and improves encounter initiative.",
      },
    },
    hotbar = {
      "moonshot",
      "rootsnare",
      "quickmend",
    },
    quests = {
      {
        id = "courier",
        name = "The Missing Courier",
        status = "accepted",
        summary = "Find the courier route ledger and return the sealed satchel to camp.",
        reward = "180 XP / 60 gold / guild favor",
        objectives = {
          { text = "Search the old bridge", current = 1, total = 1 },
          { text = "Recover route ledger", current = 0, total = 1 },
          { text = "Return to camp", current = 0, total = 1 },
        },
      },
      {
        id = "wards",
        name = "Silent Wards",
        status = "available",
        summary = "Study the ruin gate and map the old ward pattern before nightfall.",
        reward = "120 XP / crystal dust",
        objectives = {
          { text = "Inspect ward stones", current = 0, total = 3 },
          { text = "Report to Mira", current = 0, total = 1 },
        },
      },
      {
        id = "supplies",
        name = "Camp Supplies",
        status = "available",
        summary = "Gather materials so the camp can repair its field workbench.",
        reward = "90 XP / crafting discount",
        objectives = {
          { text = "Collect ironwood", current = 7, total = 10 },
          { text = "Collect moon thread", current = 12, total = 12 },
        },
      },
    },
    shop = {
      {
        id = "potion",
        name = "Red Potion",
        price = 24,
        type = "Consumable",
        rarity = "common",
        usable = true,
        heal = 35,
        description = "Restores 35 HP. Bought from camp stores.",
      },
      {
        id = "ether",
        name = "Blue Ether",
        price = 34,
        type = "Consumable",
        rarity = "common",
        usable = true,
        mana = 24,
        description = "Restores 24 MP. Bought from camp stores.",
      },
      {
        id = "trail_tonic",
        name = "Trail Tonic",
        price = 42,
        type = "Consumable",
        rarity = "common",
        usable = true,
        heal = 18,
        mana = 10,
        description = "Restores both HP and MP.",
      },
    },
  }, State)
end

local function use_item(state, item)
  if not item or not item.usable then
    state.message = item and (item.name .. " can only be inspected.") or "No item selected."
    return
  end

  if item.qty <= 0 then
    state.message = item.name .. " is out of stock."
    return
  end

  if item.heal then
    state.hero.hp = math.min(state.hero.hpMax, state.hero.hp + item.heal)
  end

  if item.mana then
    state.hero.mp = math.min(state.hero.mpMax, state.hero.mp + item.mana)
  end

  item.qty = item.qty - 1
  state.message = "Used " .. item.name .. "."
end

local function handle_quest_action(state, props)
  local quest = state:findById(state.quests, props.questId)
  if not quest then
    return
  end

  if props.action == "accept-quest" then
    quest.status = "accepted"
    state.trackedQuestId = quest.id
    state.message = "Accepted quest: " .. quest.name
  elseif props.action == "abandon-quest" then
    quest.status = "available"
    if state.trackedQuestId == quest.id then
      state.trackedQuestId = nil
    end
    state.message = "Abandoned quest: " .. quest.name
  elseif props.action == "track-quest" then
    state.trackedQuestId = quest.id
    state.message = "Tracking quest: " .. quest.name
  end
end

return {
  id = "rpg-game",
  name = "RPG Game UI",

  createState = function()
    return create_state()
  end,

  applyArgs = function(state, args)
    if args and args.screen then
      state:setScreen(args.screen)
    end
  end,

  hint = function(state)
    if state.screen == "hud" then
      return "C Character / K Skills / I Bag / Q Quests / M Camp"
    end

    return "Esc closes panel / C K I Q M switch panels"
  end,

  build = function(ctx, width, height, state)
    state = state or create_state()
    local screen = screens[state.screen] or screens.hud
    return screen.build(ctx, width, height, state)
  end,

  handleClick = function(state, props)
    local action = props.action

    if action == "nav" then
      state:setScreen(props.screen)
    elseif action == "quick-potion" then
      use_item(state, state:findById(state.inventory, "potion"))
    elseif action == "rest" then
      state.hero.hp = state.hero.hpMax
      state.hero.mp = state.hero.mpMax
      state.message = "The party rests. HP and MP restored."
    elseif action == "select-item" then
      state.selectedItemId = props.itemId
    elseif action == "use-item" then
      state.selectedItemId = props.itemId
      use_item(state, state:getSelectedItem())
    elseif action == "inspect-item" then
      state.selectedItemId = props.itemId
      state.message = "Inspecting " .. state:getSelectedItem().name .. "."
    elseif action == "sort-items" then
      table.sort(state.inventory, function(left, right)
        if left.type == right.type then
          return left.name < right.name
        end
        return left.type < right.type
      end)
      state.message = "Inventory sorted by type."
    elseif action == "select-skill" then
      state.selectedSkillId = props.skillId
    elseif action == "equip-skill" then
      state.selectedSkillId = props.skillId
      state.hotbar[1] = props.skillId
      state.message = "Assigned " .. state:getSelectedSkill().name .. " to slot 1."
    elseif action == "select-quest" then
      state.selectedQuestId = props.questId
    elseif action == "accept-quest" or action == "abandon-quest" or action == "track-quest" then
      handle_quest_action(state, props)
    elseif action == "buy-item" then
      local item = state:findById(state.shop, props.shopId)
      if item and state.hero.gold >= item.price then
        state.hero.gold = state.hero.gold - item.price
        local bought = state:addInventoryItem(item)
        state.selectedItemId = bought.id
        state.message = "Bought " .. item.name .. "."
      elseif item then
        state.message = "Not enough gold for " .. item.name .. "."
      end
    else
      return false
    end

    return true
  end,

  keypressed = function(state, key)
    local key_screens = {
      c = "character",
      k = "skills",
      i = "inventory",
      q = "quests",
      m = "camp",
      h = "hud",
    }

    if key == "escape" then
      if state.screen ~= "hud" then
        state.screen = "hud"
      end
      return true
    end

    local screen = key_screens[key]
    if screen then
      state.screen = screen
      return true
    end

    return false
  end,
}
