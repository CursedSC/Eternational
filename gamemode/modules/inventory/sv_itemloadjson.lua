-- Define the path to the JSON files
local jsonFolderPath = "fantasy/items/" 
local listJson = {}     
-- Function to load items from JSON files   
function loadItemsFromJSON()
    local files, _ = file.Find(jsonFolderPath .. "*.json", "DATA")
    for _, fileName in ipairs(files) do
        local filePath = jsonFolderPath .. fileName
        local jsonData = file.Read(filePath, "DATA")
        local itemData = util.JSONToTable(jsonData) 
        if itemData then 
            local itemName = string.gsub(fileName, ".json", "")
            local itemClass = itemList[itemData.class]
            local itemInstance = table.Copy(itemClass)
            for key, value in pairs(itemData) do
                itemInstance[key] = value
            end 
            itemInstance.fromJSON = true
            itemList[itemName] = itemInstance
            listJson[itemName] = itemData
            print("Loaded item from json: " .. itemName)
  
        else
            print("Failed to load item data from: " .. fileName)
        end 
    end
    hook.Run("OnItemsLoadedJson", nil)
    netstream.Start(nil, "fantasy/items/loadjson", listJson)
end
netstream.Hook("fantasy/items/loadjson", function(ply)
    netstream.Start(ply, "fantasy/items/loadjson", listJson)
end)
-- Call the function to load items 
loadItemsFromJSON()  