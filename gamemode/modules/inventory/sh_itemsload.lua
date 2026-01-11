itemList = {}
recipesList = {}
print("Loading items...")
local itemFolder = "fantasy/gamemode/modules/inventory/meta/items/"

local function loadItemsFromFolder(folder)
    local files, directories = file.Find(folder .. "*.lua", "LUA")
    for _, fileName in ipairs(files) do
        print("Loading item: " .. fileName)
        local filePath = folder .. fileName
        if SERVER then
            AddCSLuaFile(filePath)
        end
        local itemData = include(filePath)
        if itemData then
            local itemName = string.gsub(fileName, ".lua", "")
            itemData.idname = itemName
            itemList[itemName] = itemData
        end
    end
    itemsLoaded = true
    hook.Run("OnItemsLoaded", nil)
end

loadItemsFromFolder(itemFolder)
print("Loaded items:")

print("Loading recipes...")
local recipesFolder = "fantasy/gamemode/modules/inventory/meta/recipes/"

local function loadRecipesFromFolder(folder)
    local files, directories = file.Find(folder .. "*.lua", "LUA")
    for _, fileName in ipairs(files) do
        print("Loading recipe: " .. fileName)
        local filePath = folder .. fileName
        if SERVER then
            AddCSLuaFile(filePath)
        end
        local recipeData = include(filePath)
        if recipeData then
            local recipeName = string.gsub(fileName, ".lua", "")
            recipeData.idname = recipeName
            recipesList[recipeName] = recipeData
        end
    end
end

loadRecipesFromFolder(recipesFolder)
print("Loaded recipes:")
