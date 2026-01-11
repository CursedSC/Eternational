local npcLevels = {}

npcLevels["drg_roach_geim_hilichurl"] = {
    [1] = {Damage = 10, Health = 100},
    [2] = {Damage = 15, Health = 125},
    [3] = {Damage = 20, Health = 150},
    [4] = {Damage = 25, Health = 200},
    [5] = {Damage = 30, Health = 300},
    [6] = {Damage = 35, Health = 350},
    [7] = {Damage = 40, Health = 400},
    [8] = {Damage = 45, Health = 450},
    [9] = {Damage = 50, Health = 500},
    [10] = {Damage = 55, Health = 600},
    [11] = {Damage = 60, Health = 700},
    [12] = {Damage = 65, Health = 800},
    [13] = {Damage = 70, Health = 900},
    [14] = {Damage = 75, Health = 1000},
    [15] = {Damage = 80, Health = 1200},
    [16] = {Damage = 85, Health = 1400},
    [17] = {Damage = 90, Health = 1600},
    [18] = {Damage = 95, Health = 1800},
    [19] = {Damage = 100, Health = 2000},
    [20] = {Damage = 110, Health = 2250},
}

npcLevels["drg_roach_geim_th1"] = {
    [5] = {Damage = 50, Health = 400},
    [6] = {Damage = 55, Health = 450},
    [7] = {Damage = 60, Health = 500},
    [8] = {Damage = 65, Health = 550},
    [9] = {Damage = 70, Health = 600},
    [10] = {Damage = 75, Health = 650},
}

npcLevels["drg_roach_geim_th2"] = {
    [5] = {Damage = 60, Health = 300},
    [6] = {Damage = 65, Health = 350},
    [7] = {Damage = 70, Health = 400},
    [8] = {Damage = 75, Health = 450},
    [9] = {Damage = 80, Health = 500},
    [10] = {Damage = 85, Health = 600},
}

npcLevels["drg_roach_geim_th3"] = {
    [5] = {Damage = 30, Health = 500},
    [6] = {Damage = 35, Health = 550},
    [7] = {Damage = 40, Health = 600},
    [8] = {Damage = 45, Health = 650},
    [9] = {Damage = 50, Health = 700},
    [10] = {Damage = 55, Health = 750},
}

npcLevels["drg_roach_geim_eremite1"] = {
    [5] = {Damage = 12, Health = 200},
    [6] = {Damage = 15, Health = 200},
    [7] = {Damage = 15, Health = 200},
    [8] = {Damage = 18, Health = 200},
    [9] = {Damage = 18, Health = 200},
    [10] = {Damage = 20, Health = 200},
    [11] = {Damage = 25, Health = 300},
    [12] = {Damage = 30, Health = 400},
    [13] = {Damage = 35, Health = 500},
    [14] = {Damage = 35, Health = 600},
    [15] = {Damage = 40, Health = 700},
    [16] = {Damage = 85, Health = 1400},
    [17] = {Damage = 90, Health = 1600},
    [18] = {Damage = 95, Health = 1800},
    [19] = {Damage = 100, Health = 2000},
    [20] = {Damage = 110, Health = 2250},
}

npcLevels["drg_roach_geim_eremite3"] = {
    [10] = {Damage = 20, Health = 200},
    [11] = {Damage = 25, Health = 300},
    [12] = {Damage = 30, Health = 400},
    [13] = {Damage = 35, Health = 500},
    [14] = {Damage = 35, Health = 600},
    [15] = {Damage = 40, Health = 700},
    [16] = {Damage = 85, Health = 1400},
    [17] = {Damage = 90, Health = 1600},
    [18] = {Damage = 95, Health = 1800},
    [19] = {Damage = 100, Health = 2000},
    [20] = {Damage = 110, Health = 2250},
}

npcLevels["drg_roach_geim_eremite_katar"] = {
    [10] = {Damage = 30, Health = 300},
    [11] = {Damage = 35, Health = 400},
    [12] = {Damage = 40, Health = 500},
    [13] = {Damage = 45, Health = 600},
    [14] = {Damage = 50, Health = 700},
    [15] = {Damage = 55, Health = 800},
    [16] = {Damage = 60, Health = 900},
    [17] = {Damage = 65, Health = 1000},
    [18] = {Damage = 70, Health = 1200},
    [19] = {Damage = 75, Health = 1400},
    [20] = {Damage = 80, Health = 1600},
}

npcLevels["drg_roach_geim_darkwraith_banner"] = {
    [15] = {Damage = 40, Health = 500},
    [16] = {Damage = 45, Health = 600},
    [17] = {Damage = 50, Health = 700},
    [18] = {Damage = 55, Health = 800},
    [19] = {Damage = 60, Health = 900},
    [20] = {Damage = 65, Health = 1000},
    [21] = {Damage = 70, Health = 1200},
    [22] = {Damage = 75, Health = 1400},
    [23] = {Damage = 80, Health = 1600},
    [24] = {Damage = 85, Health = 1800},
    [25] = {Damage = 90, Health = 2000},
}

npcLevels["drg_roach_geim_darkwraith_lance"] = {
    [18] = {Damage = 50, Health = 700},
    [19] = {Damage = 55, Health = 800},
    [20] = {Damage = 60, Health = 900},
    [21] = {Damage = 65, Health = 1000},
    [22] = {Damage = 70, Health = 1200},
    [23] = {Damage = 75, Health = 1400},
    [24] = {Damage = 80, Health = 1600},
    [25] = {Damage = 85, Health = 1800},
    [26] = {Damage = 90, Health = 2000},
    [27] = {Damage = 95, Health = 2200},
    [28] = {Damage = 100, Health = 2400},
}

function applyLevel(npc, lvl)
    print("Applying level "..lvl.." to "..npc:GetClass())
    local levelData = npcLevels[npc:GetClass()][lvl]
    if levelData then
        npc:SetHealth(levelData.Health)
        npc:SetMaxHealth(levelData.Health)
        npc:SetNWInt("NPCLevel", lvl)
        npc:SetNWInt("NPCDamage", levelData.Damage)
        npc:SetNWFloat("NPCLootChance", levelData.LootChance)

        npc.Damage = levelData.Damage
        npc.HealthLvl = levelData.Health
    end
end

hook.Add("EntityTakeDamage", "ModifyNPCDamage", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if attacker:IsNPC() then
        local damage = attacker:GetNWInt("NPCDamage", 10)
        dmginfo:SetDamage(damage)
    end
end)
