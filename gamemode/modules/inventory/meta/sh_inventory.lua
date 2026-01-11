--[[
Inventory System

This module defines an Inventory system for a game mode in Garry's Mod. It provides functionality to manage items within an inventory, including adding, removing, transferring, and equipping items.

Classes:
- Inventory: Represents an inventory with various methods to manipulate items.

Functions:
- Inventory:new(owner, maxCapacity): Creates a new inventory instance.
- Inventory:GetById(id): Retrieves an inventory by its ID.
- Inventory:__tostring(): Returns a string representation of the inventory.
- Inventory:sync(): Synchronizes the inventory state with the client.
- Inventory:getItem(x, y): Retrieves an item at the specified grid coordinates.
- Inventory:GetEquippedItem(slot): Retrieves an equipped item from a specified slot.
- Inventory:getSyncData(): Returns the inventory data for synchronization.
- Inventory:mergeItems(): Merges stackable items in the inventory.
- Inventory:transferToInventory(targetInventory, fromX, fromY, toX, toY, quantity): Transfers an item to another inventory.
- Inventory:addItem(item, quantity, current_x, current_y): Adds an item to the inventory.
- Inventory:removeAllItemsBySource(itemSource): Removes all items from the inventory with the specified source.
- Inventory:removeItem(x, y, quantity): Removes a specified quantity of an item from the inventory.
- Inventory:hasItem(x, y, quantity): Checks if the inventory has a specified quantity of an item at the given coordinates.
- Inventory:hasItems(id): Checks if the inventory has items with the specified source ID.
- Inventory:listItems(): Lists all items in the inventory.
- Inventory:removeItemsBySource(itemSource, quantity): Removes a specified quantity of items with the given source from the inventory.
- Inventory:fromTable(data): Creates an inventory instance from a table of data.
- Inventory:getItemByItemSource(itemSource): Retrieves an item by its source.
- Inventory:transferItem(fromX, fromY, toX, toY): Transfers an item within the inventory.
- Inventory:findFreeSlot(): Finds a free slot in the inventory grid.
- Inventory:equipItem(item): Equips an item to the inventory.
- Inventory:unequipItem(slot, posTable): Unequips an item from a specified slot.
- Inventory:dropItem(x, y): Drops an item from the inventory.
- Inventory:GetEquippedItems(): Retrieves all equipped items.
- Inventory:GetEquippedItem(t): Retrieves an equipped item of a specified type.
- Inventory:SyncCallBack(): Placeholder for synchronization callback.

Player MetaTable Extension:
- Player:GetArmorStat(statName): Retrieves the armor stat for a player.

Variables:
- InventoryTableId: A table to store all inventory instances.
- validTypes: A table defining valid item types for equipping.
--]]
InventoryTableId = InventoryTableId or {}
local function getNewId()
    local currentId = #InventoryTableId + 1
    return currentId
end

Inventory = {}
Inventory.__index = Inventory

function Inventory:GetById(id)
    return InventoryTableId[id]
end

function Inventory:__tostring()
    local id = self.id or "че"
	return "Инвентарь ["..(self.owner and self.owner:Name() or "Нет Игрового Владельца").."]["..id.."]"
end

function Inventory:new(owner, maxCapacity)
    local inv = setmetatable({}, Inventory)
    inv.owner = owner or nil
    inv.maxCapacity = maxCapacity or 63
    inv.items = {}
    inv.weight = 0
    inv.equipped = {
        weapon = nil,
        armor = nil,
    }
    local id = getNewId()
    inv.id = id
    InventoryTableId[id] = inv
    return inv
end

function Inventory:sync()
    self:SyncCallBack()
    if CLIENT then return end
    local dataSend = self:getSyncData()
    if istable(self.listeners) then
        for s, listener in pairs(self.listeners) do
            if IsValid(listener) and listener:IsPlayer() then
                local dataSend = self:getSyncData()
                netstream.Start(listener, "fantasy/storage/sync", dataSend)
            end
        end
    end
    if not IsValid(self.owner) or not self.owner:IsPlayer() then return end

    PrintTable(dataSend)
    netstream.Start(self.owner, "fantasy/inventory/sync", dataSend)
end

function Inventory:getItem(x, y)
    for _, item in ipairs(self.items) do
        if item.x == x and item.y == y then
            return item, "Item found"
        end
    end
    return nil, "Item not found"
end

function Inventory:GetEquippedItem(slot)
    if self.equipped and self.equipped[slot] then
        return self.equipped[slot], "Item found in slot"
    else
        return nil, "No item equipped in this slot"
    end
end
function Inventory:getSyncData()
    return self
end

function Inventory:mergeItems()
    local mergedItems = {}
    for _, item in ipairs(self.items) do
        local key = item.x .. "," .. item.y
        if mergedItems[key] then
            if mergedItems[key].name == item.name and mergedItems[key].typeWorld == item.typeWorld then
                mergedItems[key].quantity = mergedItems[key].quantity + item.quantity
            else
                table.insert(mergedItems, item)
            end
        else
            mergedItems[key] = item
        end
    end

    self.items = {}
    for _, item in pairs(mergedItems) do
        table.insert(self.items, item)
    end
    self:sync()
end

function Inventory:transferToInventory(targetInventory, fromX, fromY, toX, toY, quantity)
    quantity = quantity or 1
    local targetItem = self:getItem(fromX, fromY)
    if not targetItem then
        return false, "Item not found"
    end
    local item, msg = targetItem:clone()
    if not item then
        return false, msg
    end

    if item.quantity < quantity then
        return false, "Not enough items to transfer"
    end

    local success, addMsg = targetInventory:addItem(item, quantity, toX, toY)

    if not success then
        return false, addMsg
    end

    self:removeItem(fromX, fromY, quantity)
    self:sync()
    targetInventory:sync()
    if CLIENT then
        local toStorage = (targetInventory.owner == nil)
        netstream.Start("fantasy/transferToInventory", fromX, fromY, toX, toY, quantity, toStorage)
    end
    return true, "Item transferred successfully"
end

function Inventory:addItem(item, quantity, current_x, current_y)
    x, y = current_x or 1, current_y or 1
    quantity = quantity or item.quantity or 1
    if type(item) == "string" then
        item = Item:new(item)
    end
    if #self.items >= self.maxCapacity then
        return false, "Inventory is full"
    end
    local addWeight = quantity * item.weight

    if !current_x then
        for _, invItem in ipairs(self.items) do
            if invItem.name == item.name and invItem.typeWorld == item.typeWorld then
                if item.stackable then
                    invItem.quantity = invItem.quantity + quantity
                    self.weight = self.weight + addWeight
                    self:sync()
                    if SERVER then netstream.Start(self.owner, "fantasy/itemAdd", item.name, item.itemSource, quantity) hook.Call("InventoryChangeItem", nil, self.owner,item.itemSource, quantity) end
                    return true, "Item stacked"
                end
            end
        end
    else
        for _, invItem in ipairs(self.items) do
            if invItem.name == item.name and invItem.x == x and invItem.y == y and invItem.typeWorld == item.typeWorld then
                if item.stackable then
                    invItem.quantity = invItem.quantity + quantity
                    self.weight = self.weight + addWeight
                    self:sync()
                    if SERVER then netstream.Start(self.owner, "fantasy/itemAdd", item.name, item.itemSource, quantity) hook.Call("InventoryChangeItem", nil, self.owner, item.itemSource, quantity) end
                    return true, "Item stacked"
                end
            end
        end
    end

    local freeSpotx, freeSpotY = self:findFreeSlot()
    if not freeSpotx then
        return false, "No free slot found"
    end

    item.x = freeSpotx
    item.y = freeSpotY

    if !self:hasItem(x, y) then
        item.x = x
        item.y = y
    end

    item.quantity = quantity
    table.insert(self.items, item)
    self.weight = self.weight + addWeight
    self:sync()
    if SERVER then logger.ItemLog(self.owner, item.name, quantity)
		hook.Call("InventoryChangeItem", nil, self.owner, item.itemSource, quantity)
        netstream.Start(self.owner, "fantasy/itemAdd", item.name, item.itemSource, quantity)
    end
    return true, "Item added", item
end

--[[
Функция устарела

function Inventory:removeAllItemsBySource(itemSource)
    local totalRemoved = 0
    for i = #self.items, 1, -1 do
        local invItem = self.items[i]
        if invItem.itemSource == itemSource then
            local addWeight = quantity * invItem.weight

            totalRemoved = totalRemoved + invItem.quantity
            table.remove(self.items, i)
        end
    end
    self:sync()
    return totalRemoved, "Удалено предметов с itemSource [" .. itemSource .. "]: " .. totalRemoved
end]]


function Inventory:removeItem(x, y, quantity)
    quantity = quantity or 1
    for i, invItem in ipairs(self.items) do
        if invItem.x == x and invItem.y == y then
            local addWeight = quantity * invItem.weight

            if invItem.quantity > quantity then
                invItem.quantity = invItem.quantity - quantity
                self.weight = self.weight - addWeight
                self:sync()
				if SERVER then hook.Call("InventoryChangeItem", nil, self.owner, invItem.itemSource, -quantity) end
                return true, "Item removed"
            elseif invItem.quantity == quantity then
                table.remove(self.items, i)
                self.weight = self.weight - addWeight
                self:sync()
				if SERVER then hook.Call("InventoryChangeItem", nil, self.owner, invItem.itemSource, -quantity) end
                return true, "Item removed"
            else
                return false, "Not enough items to remove"
            end
        end
    end
    return false, "Item not found"
end

function Inventory:hasItem(x, y, quantity)
    quantity = quantity or 1
    for _, invItem in ipairs(self.items) do
        if invItem.x == x and invItem.y == y and invItem.quantity >= quantity then
            return true, invItem.quantity
        end
    end
    return false, 0
end

function Inventory:hasItems(id, needQuantity)
    local quantity = 0
    for _, invItem in ipairs(self.items) do
        if invItem.itemSource == id  then
            quantity = quantity + invItem.quantity
        end
    end
    if needQuantity then
        return (quantity >= needQuantity), quantity
    end
    return (quantity != 0), quantity
end

function Inventory:listItems()
    local itemList = {}
    for _, invItem in ipairs(self.items) do
        local metaDescription = invItem:getMeta("description") or "No description"
        table.insert(itemList, invItem.name .. " (x" .. invItem.quantity .. ") - " .. metaDescription)
    end
    return itemList
end

function Inventory:removeItemsBySource(itemSource, quantity)
    quantity = quantity or 1
    local remaining = quantity

    for i = #self.items, 1, -1 do
        local invItem = self.items[i]
        if invItem.itemSource == itemSource then
            if invItem.quantity > remaining then
                invItem.quantity = invItem.quantity - remaining
                local addWeight = remaining * invItem.weight
                self.weight = self.weight - addWeight

                remaining = 0
                break
            else
                local addWeight = invItem.quantity * invItem.weight
                self.weight = self.weight - addWeight
                remaining = remaining - invItem.quantity
                table.remove(self.items, i)
            end
        end
    end

    self:sync()

    if remaining > 0 then
        return false, "Недостаточно предметов для удаления"
    else
		if SERVER then hook.Call("InventoryChangeItem", nil, self.owner, itemSource, -quantity) end
        return true, "Предметы удалены"
    end
end

function Inventory:fromTable(data)
    local inv = setmetatable({}, Inventory)
    inv.owner = data.owner
    inv.maxCapacity = data.maxCapacity or 10
    inv.items = {}
    inv.equipped = {
        weapon = nil,
        armor = nil,
    }

    inv.weight = data.weight or 0
    for _, itemData in ipairs(data.items) do
        local item = Item:fromTable(itemData)
        table.insert(inv.items, item)
    end

    if data.equipped then
        for slot, itemData in pairs(data.equipped) do
            inv.equipped[slot] = Item:fromTable(itemData)
        end
    end

    local id = getNewId()
    inv.id = id
    InventoryTableId[id] = inv
    return inv
end

function Inventory:getItemByItemSource(itemSource)
    for _, item in ipairs(self.items) do
        if item.itemSource == itemSource then
            return item, "Item found"
        end
    end
    return nil, "Item not found"
end

function Inventory:transferItem(fromX, fromY, toX, toY)
    local fromItem = nil
    local fromIndex = nil

    for i, item in ipairs(self.items) do
        if item.x == fromX and item.y == fromY then
            fromItem = item
            fromIndex = i
            break
        end
    end

    if not fromItem then
        return false, "No item found at the source position"
    end

    for _, item in ipairs(self.items) do
        if item.x == toX and item.y == toY then
            if item.name == fromItem.name and item.stackable and item.typeWorld == fromItem.typeWorld then
                item.quantity = item.quantity + fromItem.quantity
                table.remove(self.items, fromIndex)
                self:sync()
                if CLIENT then netstream.Start("fanatsy/inventory/transferItem", self.owner, fromX, fromY, toX, toY) end
                return true, "Item stacked at the destination position"
            else
                return false, "Destination position already occupied by a different item"
            end
        end
    end

    fromItem.x = toX
    fromItem.y = toY
    if CLIENT then netstream.Start("fanatsy/inventory/transferItem", self.owner, fromX, fromY, toX, toY) end
    self:sync()
    return true, "Item moved to the new position"
end

function Inventory:findFreeSlot()
    for y = 1, math.ceil(self.maxCapacity / 7) do
        for x = 1, 7 do
            local isFree = true
            for _, item in ipairs(self.items) do
                if item.x == x and item.y == y then
                    isFree = false
                    break
                end
            end
            if isFree then
                return x, y
            end
        end
    end
    return nil, nil
end

local validTypes = { weapon = true, armor = true }

function Inventory:equipItem(item)
    local itemData = item:getItemData()
    local Type = itemData.type
    if not validTypes[Type] then
        return false, "Invalid item type"
    end

    if itemData.CanEquip then
        local bSucc, str = itemData:CanEquip(self, item)
        if not bSucc then return false, str end
    end

    self.equipped[Type] = item
    self:removeItem(item.x, item.y)
    self:sync()
    if itemData.OnEquip then
        if SERVER then itemData:OnEquip(self, item) end
    end

    return true, Type .. " equipped"
end

function Inventory:unequipItem(slot, posTable)
    if self.equipped[slot] then
        local item = self.equipped[slot]
        self:addItem(item, 1, posTable.x, posTable.y)
        self.equipped[slot] = nil
        self:sync()

        local itemData = item:getItemData()

        if itemData.OnUnEquip then
            if SERVER then itemData:OnUnEquip(self, item) end
        end

        return true, "Item unequipped"
    else
        return false, "No item equipped in this slot"
    end
end

function Inventory:dropItem(x, y, quantity)
    for i, invItem in ipairs(self.items) do
        if invItem.x == x and invItem.y == y then
            if SERVER then
                local clone = invItem:clone()
                PrintTable(clone)
                clone["quantity"] = quantity
                local ent = ents.Create("dropped_item")
                ent:SetPos(self.owner:GetPos() + Vector(0, 0, 50) + self.owner:GetForward() * 50)
                ent:SetItemData(clone)
                ent:Spawn()
            end
            self:removeItem(x, y, quantity)
            return true, "Item dropped"
        end
    end
    return false, "Item not found"
end

function Inventory:GetEquippedItems()
    return self.equipped
end

function Inventory:GetEquippedItem(t)
    return self.equipped[t] or false
end

function Inventory:SyncCallBack()

end

local Player = FindMetaTable("Player")
function Player:GetArmorStat(statName)
    local stat = 0
    local inv = self.inventory or playerInventory
    local playerArmor = inv:GetEquippedItem("armor")
    if playerArmor and playerArmor.itemSource then
        local item = itemList[playerArmor.itemSource]
        if item then
            stat = item.Stats and item.Stats[statName] or 0
        end
    end
    return stat
end
