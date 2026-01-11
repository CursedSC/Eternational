Fantasy.acquaintance = {}

function Fantasy.acquaintance.add(player1, player2)
    local acquaintance = player1:GetCharacterData("acquaintance", {})
    local st = player2:SteamID()
    acquaintance[st] = true
    player2:SetCharacterData("acquaintance", acquaintance)
    player2:SyncData()
    netstream.Start(nil, "fnt/hello", player1)
end

hook.Add("KeyPress", "fnt.Check.Main", function(pl, key)

end)

hook.Add("KeyPress", "CheckOpenMenu", function(ply, key)
    if (key == IN_USE and ply:GetEyeTrace().Entity and ply:GetEyeTrace().Entity:IsPlayer()) then
        if ply:GetPos():Distance(ply:GetEyeTrace().Entity:GetPos()) <= 50 then
            local inviteOption = ply:FractionCan("invite")

            local addTable = {
                inviteOption = inviteOption,
            }
            
            netstream.Start(ply, "OpenActionMenu", ply:GetEyeTrace().Entity, addTable)
            ply.TargetAction = ply:GetEyeTrace().Entity
        end
    end
end)

netstream.Hook("PushPlayer", function(ply)
    ply.TargetAction:SetVelocity((ply.TargetAction:GetPos() - ply:GetPos()) * 7)
    ply.TargetAction = nil
end)

netstream.Hook("fnt/acquaintance", function(ply)
    Fantasy.acquaintance.add(ply, ply.TargetAction)
    ply.TargetAction = nil
end)