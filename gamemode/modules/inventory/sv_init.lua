local function initilizatePlayer(ply)
    local inventory = Inventory:new(ply, 63)
    ply.inventory = inventory
    inventory:sync()
end
local function getActiveStorage(ply)
    local activeStorage = ply:GetNWEntity("Storage", nil)
    if not IsValid(activeStorage) then return end
    local activatorStorageiD = ply:GetNWInt("StorageiD", nil)
    if activeStorage:GetPos():Distance(ply:GetPos()) > 200 then return end
    return Inventory:GetById(activatorStorageiD)
end

file.CreateDir("fantasy")
file.CreateDir("fantasy/inventory")

function saveInventory(ply)
    if not ply.inventory then return end

    local data = util.TableToJSON(ply.inventory:getSyncData(), true)
    file.Write("fantasy/inventory/" .. ply:SteamID64() .. ".txt", data)
end

local function loadInventory(ply)
    print("Loading inventory for " .. ply:Nick())
    local filePath = "fantasy/inventory/" .. ply:SteamID64() .. ".txt"
    if file.Exists(filePath, "DATA") then
        local data = file.Read(filePath, "DATA")
        if !data then initilizatePlayer(ply) return end
        local inventoryData = util.JSONToTable(data)
        inventoryData.owner = ply
        ply.inventory = Inventory:fromTable(inventoryData)
        ply.inventory:sync()
    else
        initilizatePlayer(ply)
    end
end

hook.Add("PlayerInitialSpawn", "initilizateInventory", function(ply)
    loadInventory(ply)
    hook.Run("fantasy/inventory/load", ply)
end)

hook.Add("PlayerDisconnected", "saveInventory", function(ply)
    saveInventory(ply)
end)

concommand.Add("load_inventory", function(ply)
    loadInventory(ply)
end)

concommand.Add("sync_inventory", function(ply)
    ply.inventory:sync()
end)

concommand.Add("rebuild_inventory", function(ply)
    ply.inventory = Inventory:new(ply, 63)
    ply.inventory:sync()
end)

concommand.Add("testmeta", function(ply)
    local item = ply.inventory:getItemByItemSource("sword")
    item:setMeta("sharp", 10)
    ply.inventory:sync()
end)

concommand.Add("add_item", function(ply, cmd, args)
    local item = Item:new(args[1])
    ply.inventory:addItem(item, 1, 1, 1)
end)

util.AddNetworkString("fantasy/inventory/dropItem")

net.Receive("fantasy/inventory/dropItem", function(len, ply)
    local x = net.ReadInt(32)
    local y = net.ReadInt(32)
    local success, message = ply.inventory:dropItem(x, y)
    if not success then
        ply:ChatPrint(message)
    end
end)

netstream.Hook("fantasy/inventory/dropItem", function(ply, x, y, q)
    local success, message = ply.inventory:dropItem(x, y, q)
    if not success then
        ply:ChatPrint(message)
    end
end)

netstream.Hook("fanatsy/inventory/transferItem", function(ply, owner, fromX, fromY, toX, toY)
    print("fanatsy/inventory/transferItem")
    local inventory
    if !IsValid(owner) then
        inventory = getActiveStorage(ply)
    else
        inventory = ply.inventory
    end
    local b, str = inventory:transferItem(fromX, fromY, toX, toY)
    print(b, str)
end)
netstream.Hook("fantasy/inventory/useItem", function(ply, x, y)
    local inventory = ply.inventory
    local item = inventory:getItem(x, y)
    if not item then return end
    local sItem = item:getItemData()
    local bDelete = sItem:DeleteOnUse(ply)
    if bDelete then
        inventory:removeItem(x, y)
    end
    sItem:OnUse(ply.inventory, item)
end)

util.AddNetworkString("AdminCreateItem")

net.Receive("AdminCreateItem", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    local data = net.ReadTable()
    local itemName = data.idname
    local baseItem = data.baseItem
    local itemData = data
    itemData.class = baseItem

    local jsonData = util.TableToJSON(itemData, true)
    file.Write("fantasy/items/" .. itemName .. ".json", jsonData)
    print("Created item: " .. itemName)

    loadItemsFromJSON()
end)


netstream.Hook("fantasy/transferToInventory", function(ply, fromX, fromY, toX, toY, quantity, toStorage)
    local activeStorage = getActiveStorage(ply)
    if !activeStorage then return end
    local inventory = ply.inventory

    local toInventory = toStorage and activeStorage or inventory
    local fromInventory = toStorage and inventory or activeStorage

    print(toInventory, fromInventory)
    local a, b = fromInventory:transferToInventory(toInventory, fromX, fromY, toX, toY, quantity)
    print(a, b)
end)

netstream.Hook("fantasy/storage/close", function(ply)
    local id = ply:GetNWInt("StorageiD", nil)
    if !id then return end
    local storage = Inventory:GetById(id)
    if !storage then return end
    storage.listeners = storage.listeners or {}
    storage.listeners[ply] = nil

    ply:SetNWEntity("Storage", nil)
    ply:SetNWInt("StorageiD", nil)
end)

concommand.Add("smithing", function(ply)
    local jobs = ply:GetCharacterData("jobs", {})
    jobs["smithing"] = true
    ply:SetCharacterData("jobs", jobs)
end)
