Fight = Fight or {}
Fight.Skills = Fight.Skills or {}

function Fight.Skills.CanUse(ply)
    -- сюда добавить ограничения когда скилл не может юзаться
    return true
end

local Player = FindMetaTable("Player")
local playerdebuff = {}
function Player:AddPerStatus(name, data, time, name2)
    playerdebuff[self:Name()] = playerdebuff[self:Name()] or {}
    playerdebuff[self:Name()][name] = playerdebuff[self:Name()][name] or {}
    if name2 then 
        playerdebuff[self:Name()][name][name2] = data
        timer.Simple(time, function()
            playerdebuff[self:Name()][name][name2] = nil
        end)
    else 
        local id = table.insert(playerdebuff[self:Name()][name], data)
        timer.Simple(time, function()
            table.remove(playerdebuff[self:Name()][name], id)
        end)
    end
end

function Player:GetPerStatus(name)
    local debyffInt = 0 
    playerdebuff[self:Name()] = playerdebuff[self:Name()] or {}
    playerdebuff[self:Name()][name] = playerdebuff[self:Name()][name] or {}
    for k, v in pairs(playerdebuff[self:Name()][name]) do
        debyffInt = debyffInt + v
    end
    return debyffInt
end

if SERVER then 
    hook.Add("PlayerDeath", "RemovePerStatus", function(ply)
        playerdebuff[ply:Name()] = nil
    end)
end


function Player:GetMana(int)
    return self:GetNWInt("mana", 100)
end