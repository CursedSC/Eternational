local options = {}
hook.Add("InitPostEntity", "psdlpslds", function()
    options = { 
        [1] = {
            name = "Выйти из отряда",
            imgur = "b1BHLln",
            func = function()
                SquadSystem:RequestLeave()
            end,
            requirement = function()
                return true
            end,
        }, 
        [3] = {
            name = SquadSystem:L("ACTIONWHEEL_Comms"),
            imgur = "UoBUgTO",
            func = function()
                local nIotion = {}
                for k, i in pairs(SquadSystem.Config.Communications) do
                    local inserttable = {
                        name = k,
                        func = function()
                            SquadSystem:RequestCommunication(k)
                        end,
                    }
                    table.insert(nIotion, inserttable)
                end
    
                NewWheel(nIotion)
            end,
            requirement = function()
                return true
            end,
        },
        [4] = {
            name = SquadSystem:L("ACTIONWHEEL_ToggleNametags"),
            imgur = "9EQhAke",
            func = function()
                SquadSystem:ToggleNametags()
            end,
            requirement = function()
                return true
            end,
        },
        [5] = {
            name = SquadSystem:L("ACTIONWHEEL_Invite"),
            imgur = "6sP5SH9",
            func = function(master)
                local entity = LocalPlayer():GetEyeTrace().Entity
                if not entity:IsPlayer() then return end
                SquadSystem:RequestInvitation(entity)
            end,
            requirement = function()
                if not LocalPlayer():IsSquadLeader() then return false end
                local entity = LocalPlayer():GetEyeTrace().Entity
                if not entity:IsPlayer() then return false end
    
                if LocalPlayer():GetSquad() == entity:GetSquad() then return false end
    
                return true
            end,
        },
    }
end)

hook.Add( "PlayerButtonDown", "dbt.Squad.Wheel", function( ply, button )
	if ( IsFirstTimePredicted() and button == KEY_F and not IsValid(dbt_emote.wheel)) then
        local inSquad = ply:GetSquad()
        if !inSquad then return end 
        local nOpetion = {}
        for k, i in pairs(options) do
            if i.requirement() then
                table.insert(nOpetion, i)
            end
        end

        NewWheel(nOpetion)
	end 
end)