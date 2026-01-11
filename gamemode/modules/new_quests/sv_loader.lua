print("Loading quests...")
questslist = {}
local itemFolder = "fantasy/gamemode/modules/new_quests/quests/" -- поменять потом на путь верный

local function loadItemsFromFolder(folder)
    local files, directories = file.Find(folder .. "*.lua", "LUA")
    for _, fileName in ipairs(files) do
        print("Loading quests: " .. fileName)
        local filePath = folder .. fileName
        if SERVER then
            AddCSLuaFile(filePath)
        end
        local itemData = include(filePath)

        if itemData then
            local itemName = string.gsub(fileName, ".lua", "")
            questslist[itemName] = itemData
        end
    end
end


loadItemsFromFolder(itemFolder)
