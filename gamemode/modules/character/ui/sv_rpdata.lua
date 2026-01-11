function collectRpData(playerReq, target)
    local playerKnow = playerReq:Acquaintance(target) or playerReq == target or playerReq:IsAdmin()
    local tableSend = {}
    tableSend["name"] = playerKnow and target:GetName() or "Неизвестно"
    tableSend["fraction"] = playerKnow and target:GetFraction() or "Неизвестно"
    tableSend["description"] = target:GetDescription()
    tableSend["RolePlayWords"] = target:GetCharacterData("RolePlayWords", false)
    tableSend["RolePlayERP"] = target:GetCharacterData("RolePlayERP", false)
    tableSend["RolePlayTorture"] = target:GetCharacterData("RolePlayTorture", false)
    tableSend["statuses"] = target:GetCharacterData("RPStatuses", {})
    netstream.Start(playerReq, "fantasy/rpdata/open", tableSend)
end

netstream.Hook("fantasy/rpdata/save", function(ply, data)
    ply:SetCharacterData("RolePlayWords", data.RolePlayWords)
    ply:SetCharacterData("RolePlayERP", data.RolePlayERP)
    ply:SetCharacterData("RolePlayTorture", data.RolePlayTorture)
    ply:SetDescription(data.description)    
end)

hook.Add("ShowSpare2", "fantasy_rpdata", function(ply)
    collectRpData(ply, ply)
end)

concommand.Add("fantasy_rpdata", function(ply, cmd, args)
    collectRpData(ply, ply)
end)


netstream.Hook("fantasy/rpdata/admin/request", function(ply, steamid)
    if not ply:IsAdmin() then return end
    local target = player.GetBySteamID(steamid)
    if not IsValid(target) then return end

    netstream.Start(ply, "fantasy/rpdata/admin/data", target:GetCharacterData("RPStatuses", {}))
end)


netstream.Hook("fantasy/rpdata/admin/addstatus", function(ply, data)
    if not ply:IsAdmin() then return end
    if not data or not data.steamid or not data.status then return end
    
    local target = player.GetBySteamID(data.steamid)
    if not IsValid(target) then return end
    local statuses = target:GetCharacterData("RPStatuses", {})

    table.insert(statuses, data.status)

    target:SetCharacterData("RPStatuses", statuses)
end)


netstream.Hook("fantasy/rpdata/admin/removestatus", function(ply, data)
    if not ply:IsAdmin() then return end
    if not data or not data.steamid or not data.statusKey then return end
    
    local target = player.GetBySteamID(data.steamid)
    if not IsValid(target) then return end
    local statuses = target:GetCharacterData("RPStatuses", {})

    statuses[data.statusKey] = nil

    target:SetCharacterData("RPStatuses", statuses)
end)


concommand.Add("fantasy_admin_statusmenu", function(ply)
    if IsValid(ply) and ply:IsAdmin() then
        netstream.Start(ply, "fantasy/rpdata/admin/open")
    end
end)