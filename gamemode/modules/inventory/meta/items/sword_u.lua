local Item = {}
Item.Name = "Укрепленный меч"
Item.WeaponClass = "sword_u"
Item.Description = "Обычный железный меч."
Item.Icon = 320
Item.baseDamage = 20
Item.type = "weapon"
Item.attackSpeed = 0.7
Item.attackRange = 60
Item.attribute = "strength"
Item.NeedStats = {
    ["Attributes"] = {
        ["strength"] = 10
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