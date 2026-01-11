local Item = {}
Item.Name = "Фолиант"
Item.WeaponClass = "book"
Item.Description = "Катализатор позволяющий использовать продвинутые заклинания."
Item.Icon = 1199
Item.type = "weapon"
Item.baseDamage = 0
Item.type = "weapon"
Item.attackSpeed = 0
Item.attackRange = 0
Item.attribute = "intelligence"
Item.weight = 1
Item.NeedStats = {
    ["Class"] = CLASS_MAGIC,
}

function Item:GetDescription(arguments)
    return {color_white, self.Description}
end

function Item:OnEquip(inventory, item)
    if not IsValid(inventory.owner) then return end
    local itemData = item:getItemData()
    inventory.owner:Give(itemData.WeaponClass)
end

function Item:OnUnEquip(inventory, item)
    if not IsValid(inventory.owner) then return end
    local itemData = item:getItemData()
    inventory.owner:StripWeapon(itemData.WeaponClass)
end

return Item 