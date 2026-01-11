
/**
 * Item class representing an item in the inventory.
 */
Item = {}
Item.__index = Item

/**
 * Converts the item to a string representation.
 * @return {string} The string representation of the item.
 */
function Item:__tostring()
    return "Предмет ["..self.name.."] Position: ["..self.x..", "..self.y.."]"
end

/**
 * Creates a new item.
 * @param {string} itemSource - The source of the item.
 * @param {string} name - The name of the item.
 * @param {table} meta - The metadata of the item.
 * @param {number} quantity - The quantity of the item.
 * @param {string} typeWorld - The type of the world.
 * @return {table} The newly created item.
 */
function Item:new(itemSource, name, meta, quantity, typeWorld)
    local item = setmetatable({}, Item)
    item.name = name or itemList[itemSource].Name
    item.stackable = itemList[itemSource].stackable or false
    item.x = 1
    item.y = 1
    item.itemSource = itemSource or nil
    item.meta = meta or {}
    item.quantity = quantity or 1
    item.typeWorld = itemList[itemSource].typeWorld  or "none"
    item.weight = itemList[itemSource].weight or 1
    return item
end

/**
 * Gets the data of the item from the item list.
 * @return {table} The data of the item.
 */
function Item:getItemData()
    return itemList[self.itemSource]
end

/**
 * Gets a metadata value by key.
 * @param {string} key - The key of the metadata.
 * @return {any} The value of the metadata.
 */
function Item:getMeta(key)
    return self.meta[key]
end

/**
 * Sets a metadata value by key.
 * @param {string} key - The key of the metadata.
 * @param {any} value - The value to set.
 */
function Item:setMeta(key, value)
    self.meta[key] = value
end

/**
 * Creates an item from a table of data.
 * @param {table} data - The data to create the item from.
 * @return {table} The newly created item.
 */
function Item:fromTable(data)
    local item = setmetatable({}, Item)
    item.name = data.name
    item.stackable = data.stackable or false
    item.x = data.x or 1
    item.y = data.y or 1
    item.itemSource = data.itemSource
    item.meta = data.meta or {}
    item.quantity = data.quantity or 1
    item.typeWorld = data.typeWorld or "personal"
    item.weight = data.weight or 0.1
    return item
end

/**
 * Clones the item.
 * @return {table} The cloned item.
 */
function Item:clone()
    local newItem = Item:new(self.itemSource, self.name, table.Copy(self.meta), self.quantity, self.typeWorld)
    newItem.x = self.x
    newItem.y = self.y
    return newItem
end

/**
 * Checks if the player meets the required stats to use the item.
 * @param {Player} ply - The player to check.
 * @return {boolean, string} Whether the player can use the item and a message.
 */
function Item:CheckNeedStat(ply)
    local itemData = self:getItemData()
    local needStats = itemData.NeedStats
    local playerStats = ply:GetAttributes()
    local playerClass = ply:getClass()
    local playerRace = ply:GetRace()
    if needStats then
        if needStats["Class"] then
            if playerClass ~= needStats["Class"] then
                return false, "Вы не можете надеть этот предмет."
            end
        end
        if needStats["Attributes"] then
            for k, v in pairs(needStats["Attributes"]) do
                if playerStats[k] < v then
                    return false, "Вы не можете надеть этот предмет."
                end
            end
        end
    end
    return true, "Вы надели предмет."
end

/**
 * Checks if the item can be dropped.
 * @return {boolean} Whether the item can be dropped.
 */
function Item:CanDrop()
    return self.typeWorld == "none" or self.typeWorld == "protected"
end
