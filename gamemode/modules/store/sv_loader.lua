local json = util.JSONToTable
local tableToJSON = util.TableToJSON
local fileWrite = file.Write
local fileRead = file.Read 
local fileExists = file.Exists
 
function saveShopData()
    local jsonData = tableToJSON(Shops, true)
    fileWrite("shops_data.json", jsonData)
    netstream.Start(nil, "fantasy/store/updateShops", Shops)
end

function loadShopData()
    if fileExists("shops_data.json", "DATA") then
        local jsonData = fileRead("shops_data.json", "DATA")
        for k, i in pairs(util.JSONToTable(jsonData)) do 
            Shops[k] = i
        end
    else
        print("No shops data file found, using default data.")
    end
end

loadShopData()
concommand.Add("loadShopData", function()
    loadShopData()
    netstream.Start(nil, "fantasy/store/updateShops", Shops)
end)
hook.Add("Initialize", "LoadShopsDataOnInit", loadShopData)