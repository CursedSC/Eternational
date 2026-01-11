/*questsList = {}
print("Loading quests...")
local itemFolder = "fantasy/gamemode/modules/quest/list/"

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
            questsList[itemName] = itemData
			questsList[itemName].id = itemName
        end
    end
end


loadItemsFromFolder(itemFolder)
*/
