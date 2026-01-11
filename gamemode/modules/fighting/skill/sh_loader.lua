skillList = {}
print("Loading skills...")
local itemFolder = "fantasy/gamemode/modules/fighting/skill/list/"
 
local function loadItemsFromFolder(folder)
    local files, directories = file.Find(folder .. "*.lua", "LUA")
    for _, fileName in ipairs(files) do
        print("Loading skill: " .. fileName) 
        local filePath = folder .. fileName
        if SERVER then
            AddCSLuaFile(filePath)
        end
        local itemData = include(filePath) 
        
        if itemData then 
            local itemName = string.gsub(fileName, ".lua", "")
            skillList[itemName] = itemData
            _G["SKILL_"..string.upper(itemName)] = itemData.Name
        end 
    end  
    skillLoaded = true
   -- checkParams()
    hook.Run("OnSkillsLoaded", nil)
end  
 
loadItemsFromFolder(itemFolder)
