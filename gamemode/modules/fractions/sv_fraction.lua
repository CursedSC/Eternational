fractions = {}
fractions.List = {}
local rootFolder = "fantasy/fractions"
file.CreateDir("fantasy")
file.CreateDir(rootFolder) 

function fractions.LoadData(name)
    local loadedJson = file.Read(rootFolder.."/"..name..".json")
    if !loadedJson then return {} end 
    local loadedJson = util.JSONToTable(loadedJson)
    return loadedJson
end
 
function fractions.Save(fraction)
    local saveJson = util.TableToJSON(fraction, true)
    local idSave = fraction.id 
    file.Write(rootFolder.."/"..idSave..".json", saveJson)
end
   
if Inventory then 
    fractions.List.impire = Fraction:new()--:Init("impire", fractions.LoadData("impire"))
    fractions.List.kingdom = Fraction:new()--:Init("kingdom",   fractions.LoadData("kingdom"))

    fractions.List.impire:Init("impire", fractions.LoadData("impire"))
    fractions.List.kingdom:Init("kingdom", fractions.LoadData("kingdom"))   
end

hook.Add("PostGamemodeLoaded", "loadFractions", function()
    fractions.List.impire = Fraction:new()--:Init("impire", fractions.LoadData("impire"))
    fractions.List.kingdom = Fraction:new()--:Init("kingdom", fractions.LoadData("kingdom"))
    
    fractions.List.impire:Init("impire", fractions.LoadData("impire"))
    fractions.List.kingdom:Init("kingdom", fractions.LoadData("kingdom"))   
end)

concommand.Add("impire_me", function(ply, cmd, args)
    fractions.List.impire:AddMember(ply, "helper")
end) 

concommand.Add("impire_me_leader", function(ply, cmd, args)
    fractions.List.impire:SetLeader(ply)
    fractions.List.impire:AddMember(ply, "leader")
end) 
 
netstream.Hook("fantasy/fraction/invite", function(ply, target)
    local fractionToInvite = ply:GetFraction()
    if !fractionToInvite then return end
    if !target:IsPlayer() then return end
    target.InInvite = fractionToInvite
    timer.Create("inviteTimer"..target:Name(), 5, 1, function()
        target.InInvite = nil
    end)
    netstream.Start(target, "fantasy/fraction/ask/invite", fractionToInvite)
end)
 
netstream.Hook("fantasy/fraction/accept/invite", function(ply)
    if ply.InInvite then
        print("add")
        fractions.List[ply.InInvite]:AddMember(ply)
        ply.InInvite = nil
    end
end)


hook.Add("Fantasy.CharacterLoaded", "addFraction", function(ply)
    local fraction = ply:GetCharacterData("fraction")
    if fraction then
        local role = ply:GetCharacterData("fractionRole")
        ply:SetNWString("fraction", fraction)
        ply:SetNWString("fractionRole", role)
    end
end)

netstream.Hook("fantasy/fraction/getMembers", function(ply)
    local fractionName = ply:GetFraction()
    if !fractionName then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    PrintTable(fraction)
    local membersData = {}
    for steamID, role in pairs(fraction.members or {}) do
        local memberPlayer = player.GetBySteamID(steamID)
        local isOnline = IsValid(memberPlayer)
        if !isOnline then 
            local steamid64 = util.SteamIDTo64(steamID)
            print(steamid64)
            local loadedjsonPlayer = file.Read("fantasy/character/"..steamid64..".txt")
            local loadedPlayer = util.JSONToTable(loadedjsonPlayer)
            name = loadedPlayer.name
        end

        membersData[steamID] = {
            name = isOnline and memberPlayer:GetName() or name,
            role = role,
            isLeader = (steamID == fraction:GetLeader()),
            lastSeen = isOnline and os.time() or nil,
            player = memberPlayer,
            steamID = steamID
        }
    end
    
    netstream.Start(ply, "fantasy/fraction/membersData", membersData, ply:SteamID() == fraction:GetLeader())
end)

netstream.Hook("fantasy/fraction/changeRole", function(ply, targetSteamID, newRole)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("giveroles") then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    
    local targetPlayer = player.GetBySteamID(targetSteamID)
    if IsValid(targetPlayer) and ply:CanAbovePlayer(targetPlayer) then
        targetPlayer:SetNWString("fractionRole", newRole)
        targetPlayer:SetCharacterData("fractionRole", newRole)
    else 
        local steamid64 = util.SteamIDTo64(targetSteamID)
        local loadedPlayer = loadCharacterSteamID(steamid64)
        if loadedPlayer then
            loadedPlayer.fractionRole = newRole
            saveCharacterSteamID(steamid64, loadedPlayer)
        end
    end

    fraction.members[targetSteamID] = newRole
    fractions.Save(fraction)
end)
 
netstream.Hook("fantasy/fraction/kickMember", function(ply, targetSteamID)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("kick") then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    
    local targetPlayer = player.GetBySteamID(targetSteamID)
    if IsValid(targetPlayer) and ply:CanAbovePlayer(targetPlayer) then
        targetPlayer:SetNWString("fraction", nil)
        targetPlayer:SetNWString("fractionRole", nil)
        targetPlayer:SetCharacterData("fraction", nil)
        targetPlayer:SetCharacterData("fractionRole", nil)
    else 
        local steamid64 = util.SteamIDTo64(targetSteamID)
        local loadedPlayer = loadCharacterSteamID(steamid64)
        if loadedPlayer then
            loadedPlayer.fraction = nil
            loadedPlayer.fractionRole = nil
            saveCharacterSteamID(steamid64, loadedPlayer)
        end
    end
    fraction.members[targetSteamID] = nil
    fractions.Save(fraction)
end)

netstream.Hook("fantasy/fraction/getRoles", function(ply)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("editroles") then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    
    netstream.Start(ply, "fantasy/fraction/rolesData", fraction.Roles)
end) 

netstream.Hook("fantasy/fraction/getRoleList", function(ply)
    local fractionName = ply:GetFraction()
    if !fractionName then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    
    netstream.Start(ply, "fantasy/fraction/getRoleList", fraction.Roles)
end) 

netstream.Hook("fantasy/fraction/updateRolePermission", function(ply, roleName, permKey, value)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("editroles") then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction or roleName == "leader" then return end
    
    fraction.Roles[roleName].acces[permKey] = value
    fractions.Save(fraction)
end)

netstream.Hook("fantasy/fraction/openStorage", function(ply)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("storage") then return end
    
    local fraction = fractions.List[fractionName]
    if !fraction then return end
    
    -- Implement your storage opening logic here
    local storage = fraction:GetStorage()
    -- Open storage UI for player
end)

-- Add this after your other fraction functions

-- Prepare fraction data for network transmission
function fractions.GetNetworkData()
    local networkData = {}
    
    for fractionID, fraction in pairs(fractions.List) do
        -- Create simplified version of faction data for network
        networkData[fractionID] = {
            id = fraction.id,
            Leader = fraction.Leader,
            Roles = fraction.Roles,
            members = fraction.members,
            -- Don't send storage data - that's handled separately
        }
    end
    
    return networkData
end

-- Sync fractions to a specific player
function fractions.SyncToPlayer(ply)
    if !IsValid(ply) then return end
    
    local networkData = fractions.GetNetworkData()
    netstream.Start(ply, "fantasy/fraction/syncData", networkData)
end

-- Sync fractions to all players
function fractions.SyncToAll()
    local networkData = fractions.GetNetworkData()
    netstream.Start(nil, "fantasy/fraction/syncData", networkData)
end

-- Add this to your fractions.Save function
local oldSave = fractions.Save 
function fractions.Save(fraction)
    oldSave(fraction)
    -- Sync changes to all players
    fractions.SyncToAll() 
end

-- Add hooks to sync fractions
hook.Add("PlayerInitialSpawn", "SyncFractionsOnJoin", function(ply)
    timer.Simple(2, function() -- Delay to ensure player is fully initialized
        if IsValid(ply) then
            fractions.SyncToPlayer(ply)
        end
    end) 
end)

-- Add sync after every major faction change
hook.Add("OnFractionChanged", "SyncFractionChanges", function()
    fractions.SyncToAll()
end)

-- Make sure to call the hook in relevant places
local function TriggerFractionChange()
    hook.Run("OnFractionChanged")
end

-- Hook all the faction-changing functions
local originalAddMember = Fraction.AddMember
function Fraction:AddMember(player, role)
    local result = originalAddMember(self, player, role)
    TriggerFractionChange()
    return result
end
-- Role creation handler
netstream.Hook("fantasy/fraction/createRole", function(ply, roleData)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("editroles") then 
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "У вас нет прав на редактирование ролей")
        return 
    end
    
    local fraction = fractions.List[fractionName]
    if !fraction then 
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "Фракция не найдена")
        return 
    end
    
    -- Check if role ID already exists
    if fraction.Roles[roleData.id] then
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "Роль с таким ID уже существует")
        return
    end
    
    -- Create the new role
    fraction.Roles[roleData.id] = {
        name = roleData.name,
        imune = roleData.immune,
        acces = {}
    }
    
    fractions.Save(fraction)
    netstream.Start(ply, "fantasy/fraction/roleUpdateSuccess")
end)

-- Role removal handler
netstream.Hook("fantasy/fraction/removeRole", function(ply, roleId)
    local fractionName = ply:GetFraction()
    if !fractionName or !ply:FractionCan("editroles") then 
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "У вас нет прав на редактирование ролей")
        return 
    end
    
    local fraction = fractions.List[fractionName]
    if !fraction then 
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "Фракция не найдена")
        return 
    end
    
    -- Check if role exists and is not a protected role
    if !fraction.Roles[roleId] or roleId == "leader" or roleId == "member" then
        netstream.Start(ply, "fantasy/fraction/roleUpdateError", "Эту роль нельзя удалить")
        return
    end
     
    -- Reset role to "member" for all players with this role
    for steamID, role in pairs(fraction.members) do
        if role == roleId then
            fraction.members[steamID] = "member"
            
            -- Update online players
            local targetPlayer = player.GetBySteamID(steamID)
            if IsValid(targetPlayer) then
                targetPlayer:SetNWString("fractionRole", "member")
                targetPlayer:SetCharacterData("fractionRole", "member")
            end
        end
    end
     
    -- Remove the role
    fraction.Roles[roleId] = nil
    
    fractions.Save(fraction)
    netstream.Start(ply, "fantasy/fraction/roleUpdateSuccess")
end)

concommand.Add("sync_", function(ply, cmd, args)
    fractions.SyncToPlayer(ply)
end)
-- Add similar hooks for other important fraction-changing functions