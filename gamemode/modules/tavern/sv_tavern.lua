local TAVERN_ROOM_PRICE = 50

local Player = FindMetaTable("Player")
function Player:GetPersonalStorage()
    if not self.characterData then return nil end
    if not self.characterData.personalStorage then
        self.characterData.personalStorage = Inventory:new(nil, 15)
    end
    return self.characterData.personalStorage
end

local function isRoomRented(ply)
    local rentData = ply:GetCharacterData("tavernRent", {})
    if not rentData.expiryDate then return false end
    
    local currentTime = os.time()
    return currentTime < rentData.expiryDate
end

local function rentRoom(ply)
    local money = ply:GetCharacterData("money", 0)
    if money < TAVERN_ROOM_PRICE then
        return false, "Недостаточно золота для аренды комнаты"
    end
    
    local currentTime = os.time()
    local expiryDate = currentTime + (24 * 60 * 60) -- 24 часа
    
    ply:SetCharacterData("money", money - TAVERN_ROOM_PRICE)
    ply:SetCharacterData("tavernRent", {
        expiryDate = expiryDate,
        rentedAt = currentTime
    })
    
    return true, "Комната арендована на 24 часа"
end

netstream.Hook("tavernExit", function(ply)
    ply:SetNWBool("InTavern", false)
    ply:SetNWEntity("Storage", nil)
	ply:SetNWInt("StorageiD", nil)
end)

netstream.Hook("openselfstorage", function(ply)
    local b = ply:GetNWBool("InTavern")
    print("openselfstorage", b)
    if !b then return end 
    
    print(b)
    if not isRoomRented(ply) then
        netstream.Start(ply, "tavernRoomNotRented")
        return
    end
    
    local storageInventory = ply:GetPersonalStorage()
	ply:SetNWEntity("Storage", ply)
	ply:SetNWInt("StorageiD", storageInventory.id)
	netstream.Start(ply, "fantasy/storage/open", storageInventory)
end)

hook.Add( "PlayerUse", "tavernEnter", function( ply, ent )
	local id = ent:MapCreationID()
    if id == 1484 and !ply:GetNWBool("InTavern") then  
        if not isRoomRented(ply) then
            ply:ChatPrint("Вам нужно арендовать комнату, чтобы войти в таверну!")
            ply:ChatPrint("Стоимость аренды: " .. TAVERN_ROOM_PRICE .. " золота на 24 часа")
            return false
        end
        ply:SelectWeapon( "hands")
        ply:SetNWBool("InTavern", true)
        timer.Simple(0.1, function()
           print(ply:GetNWBool("InTavern"))
        end)
        netstream.Start(ply, "tavernentry")
        return false
    end 
end )

netstream.Hook("tavernRentRoom", function(ply)
    local success, message = rentRoom(ply)
    if success then
        ply:ChatPrint("Комната успешно арендована!")
        netstream.Start(ply, "tavernRentSuccess")
    else
        ply:ChatPrint(message)
        netstream.Start(ply, "tavernRentFailed", message)
    end
end)

netstream.Hook("tavernCheckRent", function(ply)
    local rentData = ply:GetCharacterData("tavernRent", {})
    local isRented = isRoomRented(ply)
    local timeLeft = 0
    
    if isRented and rentData.expiryDate then
        timeLeft = rentData.expiryDate - os.time()
    end
    
    netstream.Start(ply, "tavernRentStatus", {
        isRented = isRented,
        timeLeft = timeLeft,
        price = TAVERN_ROOM_PRICE,
        upgradePrice = STORAGE_UPGRADE_PRICE
    })
end)

concommand.Add("tavern_rent_room", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    
    local success, message = rentRoom(ply)
    ply:ChatPrint(message)
end)


if TimeLib then
    TimeLib:OnDay("tavernRentCheck", function(currentDate)
        for _, ply in pairs(player.GetAll()) do
            if IsValid(ply) then
                local rentData = ply:GetCharacterData("tavernRent", {})
                if rentData.expiryDate and os.time() >= rentData.expiryDate then
                    -- Аренда истекла
                    ply:SetCharacterData("tavernRent", {})
                    if ply:GetNWBool("InTavern") then
                        ply:SetNWBool("InTavern", false)
                        netstream.Start(ply, "tavernRentExpired")
                    end
                    ply:ChatPrint("Аренда комнаты в таверне истекла!")
                end
            end
        end
    end)
end