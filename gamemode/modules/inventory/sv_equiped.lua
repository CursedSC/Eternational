hook.Add("fantasy/inventory/load", "fantasy/inventory/eq", function(ply)
    local inventory = ply.inventory
    local equipedItems = inventory:GetEquippedItems()
    for _, item in pairs(equipedItems) do
        local itemData = item:getItemData()
        timer.Simple(0.1, function() itemData:OnEquip(inventory, item) end)
    end
end)

hook.Add("PlayerSpawn", "fantasy/inventory/eq", function(ply)
    local inventory = ply.inventory
    local equipedItems = inventory:GetEquippedItems()
    for _, item in pairs(equipedItems) do
        local itemData = item:getItemData()
        timer.Simple(0.1, function() itemData:OnEquip(inventory, item) end)
    end
end)

netstream.Hook("fantasy/inventory/equip", function(ply, item)
    local inv = ply.inventory
    local item = Item:fromTable(item)
    local canEquip, str = item:CheckNeedStat(ply)
    if !canEquip then return end
    local success, message = inv:equipItem(item)
    if success then
        inv:sync()
    else
        ply:ChatPrint(message)
    end
end)

netstream.Hook("fantasy/inventory/unequip", function(ply, slot, posTable)
    local inv = ply.inventory
    local success, message = inv:unequipItem(slot, posTable)
    if success then
        inv:sync()
    else
        ply:ChatPrint(message)
    end
end)
