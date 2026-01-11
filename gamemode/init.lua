local meta = FindMetaTable( "Player" )
local entity = FindMetaTable( "Entity" )

meta.__type = "Player"

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
SetGlobalBool("ShowSwordsLine", false)
-- Console Commands --
RunConsoleCommand("sv_kickerrornum", "0")
RunConsoleCommand("sbox_godmode", "0")
RunConsoleCommand("sbox_playershurtplayers", "1")
RunConsoleCommand("sbox_persist", "1")
RunConsoleCommand("mp_falldamage", "1")
RunConsoleCommand("sv_allowcslua", "0") -- Unlike you falco, i don't want people cheating.
RunConsoleCommand("sbox_maxtextscreens", "8")
RunConsoleCommand("sv_gravity", "750")
RunConsoleCommand("drgbase_ai_patrol", "0")

concommand.Add("plyInSkill", function(ply)
    ply.InSkill = false
end)

function GM:PlayerSpawn(ply)
    ply:SetModel("models/cloudteam/fantasy/custom/people_male.mdl")
end

function GM:PlayerInitialSpawn(ply)

end

function GM:PlayerSpawnSENT(ply)
    return ply:IsAdmin()
end

function GM:PlayerSpawnSWEP( ply )
    return ply:IsAdmin()
end

function GM:PlayerSpawnVehicle( ply )
    return ply:IsAdmin()
end

function GM:PlayerSpawnNPC( ply )
    return ply:IsAdmin()
end

function GM:PlayerSpawnEffect( ply )
    return ply:IsAdmin()
end

function GM:PlayerGiveSWEP( ply, class, wep )
    return ply:IsAdmin()
end

function GM:PlayerSpawnProp( ply, model )
    return ply:IsAdmin()
end

function GM:PlayerSpawnedProp(ply, model, ent)
    if ply:IsPlayer() and not ply:IsAdmin() then
        ent:Remove()
    end
end

function GM:GetFallDamage(ply, speed)
    return math.max( 0, math.ceil( 0.2418 * speed - 141.75 ) )
end

function GM:PlayerShouldTakeDamage()
    return true
end

netstream.Hook("dbt/chat/start", function(ply, text)
    hook.Run("PlayerSay", ply, text)
end)

hook.Add("PostEntityTakeDamage", "Horde_HitnumbersDamagePost", function(target, dmginfo, took)
    if not took then return end
    local attacker         = dmginfo:GetAttacker()
    local attackerIsPlayer = attacker:IsPlayer()
    if not ( attackerIsPlayer ) then return end
    if attacker == target  then return end

    local dmgAmount = dmginfo:GetDamage()
    local dmgType   = dmginfo:GetDamageType()
    local dmgCustom   = dmginfo:GetDamageCustom() or 0

    -- Get damage position.
    local pos = dmginfo:GetDamagePosition()
    if pos == Vector(0,0,0) then
        pos = target:GetPos()
    end

    -- Create and send the indicator to players.
    netstream.Start(attacker, "Horde_HitnumbersSpawn", dmgAmount, dmgType, pos, dmgCustom)
end)


hook.Add("PlayerButtonDown", "tount", function(ply, btn)
    if btn == KEY_F then
        netstream.Start(nil, "fantasy/play/anim", ply, "wos_bs_shared_taunt_reverse",  0, true)
    end
end)

netstream.Hook("fantasy/player/target", function(ply, ent)
    if not IsValid(ply) then return end
    if not IsValid(ent) then return end
    ply:SetNWEntity("target", ent)
end)

netstream.Hook("UseSkill", function(ply, skill)
    local weapon = ply:GetActiveWeapon()
    local hasCd = weapon.cd and (weapon.cd < CurTime()) or true
    if IsValid(weapon) and !ply.InSkill and hasCd and ply.characterData.knowSkills[skill] then
        local skillData = skillList[skill]
        if skillData then
            local manaNeed = skillData.Mana or 0
            if ply:GetMana() < manaNeed then return end
            local enum = _G["SKILL_"..string.upper(skill)]
            if (weapon.Type == skillData.WeaponType) and !ply:HasCooldown(enum) then
                skillData.ServerFunc(ply, weapon)
                ply:AddCooldown(enum, skillData.CoolDown)
                ply:RemoveMana(skillData.Mana or 0)
            elseif skillData.WeaponType == nil and !ply:HasCooldown(enum) then
                skillData.ServerFunc(ply, weapon)
                ply:AddCooldown(enum, skillData.CoolDown)
                ply:RemoveMana(skillData.Mana or 0)
            end
        end
    end
end)

hook.Add("PlayerSay","cats2",function(t,a)
    --print("cats2", t, a)
    --local a,e=cats.config.triggerText(t,a)
    --print("cats2", a, e)
    --if a then
    --    cats:DispatchMessage(t,t:SteamID(),e)
    --    --return''
    --end
end)

local execFuncs = {
    ["wood"] = function(ent, inv, combo)
        inv:addItem("wood", combo, 1, 1)
        inv:addItem("stick", combo * 2, 1, 1)
        inv:addItem("last_wood", combo * 2, 1, 1)
    end,
    ["stone"] = function(ent, inv, combo)
        local Type = ent.stoneType
        if Type == "normal" then
            inv:addItem("stone", combo, 1, 1)
            inv:addItem("stone_last", combo, 1, 1)
        elseif Type == "iron" then
            inv:addItem("iron_ore", combo, 1, 1)
            inv:addItem("stone_last", combo, 1, 1)
        elseif Type == "coal" then
            inv:addItem("coal", combo, 1, 1)
            inv:addItem("stone_last", combo, 1, 1)
        elseif Type == "bad" then
            inv:addItem("stone_last", combo, 1, 1)
        end
    end,
}



netstream.Hook("lumber", function(ply, combo, ent)
    local typeEntity = ent:GetClass()
	ply:Freeze(false)
	if combo == 0 then return end
    ent:Restore()
	local inv = ply.inventory
	if not inv then return end
	execFuncs[typeEntity](ent, inv, combo)
end)

TimeLib:OnMinute("TestMinute", function(date)
    print("A minute has passed! Current time: " .. TimeLib:GetCurrentTime())
end)

TimeLib:OnDay("questsystem/setdailyquests", function(date)
	questsystem.refreshDailyQuests()
    print("Daily Quests have been refreshed!")
end)
