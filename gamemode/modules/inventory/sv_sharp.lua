local function getBonus(weapon)
    local bonusSharp = weapon:getMeta("sharpBonus") or {}
    local temp = table.Copy(sharpBonusId)
    PrintTable(temp)
    for k, v in pairs(bonusSharp) do
        temp[k] = nil
    end
    local addBonus = table.Random(temp)
    print(addBonus)
    bonusSharp[addBonus] = true
    print("Добавление бонуса", addBonus)
    weapon:setMeta("sharpBonus", bonusSharp)
end

local function sharp_active_weapon(ply)
    local weapon = ply.inventory:GetEquippedItem("weapon")
    local currentLevel = weapon:getMeta("sharp") or 0
    
    if currentLevel >= 10 then
        ply:ChatPrint("Ваше оружие уже достигло максимального уровня заточки!")
        return
    end
    ply.inventory:removeItemsBySource("grindstone_tier1", 1)
    local chance = upgradeChances[currentLevel + 1]
    if math.random(1, 100) <= chance then
        currentLevel = currentLevel + 1

        if lvlOdAddBonus[currentLevel] then
            print("Добавление бонуса")
            getBonus(weapon)
        end
        weapon:setMeta("sharp", currentLevel)
        print("Заточка успешна! Теперь уровень: +" .. currentLevel)
        ply.inventory:sync()
        netstream.Start(ply, "fantasy/inventory/sharp", true)
    else
        netstream.Start(ply, "fantasy/inventory/sharp", false)
        print("Заточка не удалась!")
    end
end 

concommand.Add("sharp_active_weapon", function(ply)
    sharp_active_weapon(ply)
end)
 
netstream.Hook("fantasy/inventory/sharp", function(ply, slotid, tool)
    if slotid == "weapon" then
        local hasSharpingItem = ply.inventory:hasItems("grindstone_tier1")  
        if not hasSharpingItem then
            return
        end
        sharp_active_weapon(ply)
    end
end)