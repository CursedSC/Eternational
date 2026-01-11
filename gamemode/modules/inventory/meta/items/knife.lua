local Item = {}
Item.Name = "Железный нож"
Item.WeaponClass = "knife"
Item.Description = "Обычный железный меч."
Item.Icon = 121
Item.baseDamage = 5
Item.type = "weapon"
Item.attackSpeed = 0.3
Item.attackRange = 60
Item.weight = 1
Item.attribute = "agility"
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