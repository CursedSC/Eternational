fighting = fighting or {}
Fight = Fight or {} -- Сохраняем для совместимости

-- Подключение модулей новой боевой системы
include("sh_hitbox.lua")
include("sh_resources.lua")
include("sh_damage.lua")
include("sh_skill.lua")

if SERVER then
    AddCSLuaFile("sh_hitbox.lua")
    AddCSLuaFile("sh_resources.lua")
    AddCSLuaFile("sh_damage.lua")
    AddCSLuaFile("sh_skill.lua")
end

-- Вспомогательные функции игрока (совместимость)
local Player = FindMetaTable("Player")

function Player:GetMana()
    return fighting.Resources:GetMana(self)
end

function Player:GetStamina()
    return fighting.Resources:GetStamina(self)
end

-- Система временных статусов (оставляем, если используется в других местах)
local playerdebuff = {}

function Player:AddPerStatus(name, data, time, name2)
    playerdebuff[self:Name()] = playerdebuff[self:Name()] or {}
    playerdebuff[self:Name()][name] = playerdebuff[self:Name()][name] or {}
    if name2 then 
        playerdebuff[self:Name()][name][name2] = data
        timer.Simple(time, function()
            if IsValid(self) then
                playerdebuff[self:Name()][name][name2] = nil
            end
        end)
    else 
        local id = table.insert(playerdebuff[self:Name()][name], data)
        timer.Simple(time, function()
            if IsValid(self) then
                table.remove(playerdebuff[self:Name()][name], id)
            end
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