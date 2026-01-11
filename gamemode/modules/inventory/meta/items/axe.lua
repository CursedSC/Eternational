local Item = {}
Item.Name = "Топор"
Item.WeaponClass = "tool_pix"
Item.Description = "Обычный железный топор."
Item.Icon = 4716
Item.baseDamage = 10
Item.type = "weapon"
Item.attackSpeed = 0.7
Item.attackRange = 60
Item.attribute = "strength"
Item.weight = 5

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