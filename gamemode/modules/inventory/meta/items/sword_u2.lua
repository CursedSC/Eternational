local Item = {}
Item.Name = "Меч с дополнительным покрытием"
Item.WeaponClass = "sword_u2"
Item.Description = "Обычный железный меч."
Item.Icon = 260
Item.baseDamage = 25
Item.type = "weapon"
Item.attackSpeed = 0.7
Item.attackRange = 60
Item.attribute = "strength"
Item.NeedStats = {
    ["Attributes"] = {
        ["strength"] = 15
    }
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