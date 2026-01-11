local lootTable = {
    ["drg_roach_geim_hilichurl"] = {
        {item = "crystal_1", chance = 100},
        {item = "heal_potion", chance = 10},
        {item = "mana_potion", chance = 10},
        {xp = 10, chance = 100}
    },
    ["drg_roach_geim_aherald2"] = {
        {item = "grindstone_tier1", chance = 100, type = "personal"},
        {item = "grindstone_tier1", chance = 50, type = "none"},
        {xp = 200, chance = 100}
    },
    ["drg_roach_geim_eremite1"] = { -- Убрать после ОБТ
        {item = "sword_u", chance = 5, type = "none"},
        {item = "twohandlesword_u", chance = 5, type = "none"},
        {item = "sword_u2", chance = 2, type = "none"},
        {item = "twohandlesword_u2", chance = 2, type = "none"},
        {xp = 30, chance = 100}
    },
    ["drg_roach_geim_eremite2"] = { -- Убрать после ОБТ
        {xp = 30, chance = 100}
    },
    ["drg_roach_geim_eremite3"] = { -- Убрать после ОБТ
        {item = "sword_u", chance = 5, type = "none"},
        {item = "twohandlesword_u", chance = 5, type = "none"},
        {xp = 30, chance = 100}
    },
} 


hook.Add("OnNPCKilled", "DropLootOnNPCKilled", function(npc, attacker, inflictor)
    if not attacker:IsPlayer() then return end

    local npcClass = npc:GetClass()

    if npc.CustomDrop then
        local loot = npc.CustomDrop
        local r = math.random(100)

        for _, drop in ipairs(loot) do
            if r <= drop.chance then
                if drop.item then
                    local item = Item:new(drop.item)
                    item.typeWorld = drop.type or "none"
                    local a, b = attacker.inventory:addItem(item, 1, 1, 1)
                elseif drop.xp then
                    local lvl = npc:GetNWInt("NPCLevel", 1)
                    attacker:AddExperience(drop.xp * lvl)
                end
            end
        end
    end

	--local ishave, tablequests = attacker:QuestsHave("getitem")
	--if ishave then
	--	for k, v in pairs(tablequests) do
	--		if v.mobClass == npc:GetClass() then
	--			local item = Item:new({item = v.ItemName, chance = 100, type = "personal"})
	--			item.typeWorld = drop.type or "none"
	--			local a, b = attacker.inventory:addItem(item, 1, 1, 1)
	--		end
	--	end
	--end

    local loot = lootTable[npcClass]
    if not loot then return end
    local r = math.random(100)

    for _, drop in ipairs(loot) do
        if r <= drop.chance then
            if drop.item then
                local item = Item:new(drop.item)
                item.typeWorld = drop.type or "none"
                attacker.inventory:addItem(item, 1, 1, 1)
            elseif drop.xp then
                local lvl = npc:GetNWInt("NPCLevel", 1)
                attacker:AddExperience(drop.xp * lvl)
            end
        end
    end
end)
