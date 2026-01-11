local DeriveGamemode = DeriveGamemode
local FindMetaTable = FindMetaTable
local hook_Add = hook.Add
local IsFirstTimePredicted = IsFirstTimePredicted
local include_sv = include_sv
local include_cl = include_cl
local string_lower = string.lower
local string_sub = string.sub
local include_sh = include_sh
local file_Find = file.Find
local pairs = pairs
local string_find = string.find
local table_Count = table.Count
local cloud_reload = cloud_reload
local DOS = DOS or {}
local timer_Create = timer.Create
local player_GetHumans = player.GetHumans
local addStamina = addStamina
local Color = Color
local Material = Material
local ReadData = ReadData
local SaveData = SaveData
local netstream = netstream
local math_Clamp = math.Clamp
local Player = FindMetaTable("Player")

GM.Team = "Demit"
GM.Name = "Fantasy RP"
GM.Author = "Demit"
Fantasy = Fantasy or {}
Fantasy.BasicModel = "models/cloudteam/fantasy/custom/elf_male.mdl"
Fight = Fight or {}
Fight.Skills = Fight.Skills or {}

DeriveGamemode("sandbox")

include_sv = (SERVER) and include or function() end
include_cl = (SERVER) and AddCSLuaFile or include or nil
include_sh = function(f)
    include_sv(f)
    include_cl(f)
end

function DoLog() end

cloud_reload = function(path, filename)
    local reload = string_lower(string_sub(filename, 1, 2 ))

    if reload == "sv" or reload == "init" then
        include_sv(path)
        --MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Cloud Team", Color(255, 55, 50), "] ", color_white, "Прогрузка ", Color(100, 100, 250), "SERVER", color_white, " filename: " .. filename .. "\n")
    elseif reload == "cl" or reload == "cl_init" then
        include_cl(path)
        --MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Cloud Team", Color(255, 55, 50), "] ", color_white, "Прогрузка ", Color(255, 136, 0), "CLIENT", color_white, " filename: " .. filename .. "\n")
    elseif reload == "sh" or reload == "shared" then
        include_sh(path)
        --MsgC(Color(255, 55, 50), "[", Color(10, 200, 250), "Cloud Team", Color(255, 55, 50), "] ",  color_white, "Прогрузка ", Color(120, 225, 100), "SHARED", color_white, " filename: " .. filename .. "\n")
    end
end

function GetFilesSortedByRealm(path)
    local not_sorted, folders = file_Find(path.."/*", "LUA")
    local sorted = {}

    for key, val in pairs(not_sorted) do
        val = string_lower(val)

        if string_find(val, "sh_") then
            sorted[table_Count(sorted) + 1] = val
            not_sorted[key] = nil
        end
    end

    for key, val in pairs(not_sorted) do
        val = string_lower(val)

        if string_find(val, "sv_") then
            sorted[table_Count(sorted) + 1] = val
            not_sorted[key] = nil
        end
    end

    for key, val in pairs(not_sorted) do
        sorted[table_Count(sorted) + 1] = val
    end

    return sorted, folders
end
local fold = GM.FolderName.."/gamemode/"
function DOS.LoadFolder(path)
    local files, folders = file_Find(fold.."/"..path.."/*", "LUA")

    for _,v in pairs(folders) do
        --print("\n[#] Folder - "..v.."\n")
        --print(fold..path.."/"..v)
        DOS.LoadFolder(path.."/"..v)
     end

    for _,v in pairs(files) do
        cloud_reload(fold..path.."/"..v, v)
        --print("inculded",fold..path.."/"..v, v)
    end

end


DOS.LoadFolder("bd")
DOS.LoadFolder("lib")
DOS.LoadFolder("modules")

hook.Add("Move", "DetectPlayerMove", function(ply, mv)
    if not ply.lastPos then
        ply.lastPos = mv:GetOrigin()
        ply.isMoving = false
        return
    end

    local newPos = mv:GetOrigin()
    if newPos ~= ply.lastPos then
        ply.isMoving = true
        ply.lastPos = newPos
    else
        ply.isMoving = false
    end
end)

function Player:IsPlayerMoving()
    return self.isMoving
end


concommand.Add("listitem", function()
    for itemName, itemData in pairs(itemList) do
        print(itemData.Name)
    end 
end)