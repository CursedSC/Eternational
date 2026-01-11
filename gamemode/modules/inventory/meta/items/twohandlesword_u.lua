local Item = {}
Item.Name = "Двуручный меч"
Item.WeaponClass = "twohandlesword_u"
Item.Description = "Обычный железный меч."
Item.Icon = 224
Item.baseDamage = 40
Item.type = "weapon"
Item.attackSpeed = 1.3
Item.attackRange = 90
Item.attribute = "strength"
Item.NeedStats = {
    ["Attributes"] = {
        ["strength"] = 10,
        ["vitality"] = 10,
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