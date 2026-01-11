netstream.Hook("shopAction/Sell", function(ply, data)
    local shopId = data.shopId
    local itemId = data.itemId
    local itemCount = data.itemCount
    print(shopId, itemId, itemCount)
    PrintTable(Shops)
    local item = Shops[shopId]["Sell"][itemId]
    print(item)
    if not item then return end
    local hasItem, num = ply.inventory:hasItems(item.id)
    print(hasItem, num)
    if !hasItem then return end
    if num < itemCount then return end

    local money = ply:GetCharacterData("money") or 0 
    local removedItems, str = ply.inventory:removeItemsBySource(item.id, itemCount)
    ply:SetCharacterData("money", money + item.cost * itemCount)
end)

netstream.Hook("shopAction/Buy", function(ply, data)
    local shopId = data.shopId
    local itemId = data.itemId
    local itemCount = data.itemCount
    local money = ply:GetCharacterData("money") or 0 
    local item = Shops[shopId]["Buy"][itemId]
    if not item then return end
    if money < (itemCount * item.cost) then return end
    ply:SetCharacterData("money", math.floor(money - itemCount * item.cost))
    local item = Item:new(item.id)
    ply.inventory:addItem(item, itemCount, 1, 1)
end)

netstream.Hook("fantasy/store/editShop", function(ply, data)
    if not ply:IsSuperAdmin() then return end
    local shopIndex = data.shopIndex
    local shopData = data.shopData
    Shops[shopIndex] = shopData
    netstream.Start(ply, "fantasy/store/updateShops", Shops)
    saveShopData()
end)

hook.Add("PlayerInitialSpawn", "fantasy/store/sendShops", function(ply)
    netstream.Start(ply, "fantasy/store/updateShops", Shops)
end)