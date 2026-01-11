local Item = {}
Item.Name = "Железный Двуручный меч"
Item.WeaponClass = "twohandlesword"
Item.Description = "Обычный железный меч."
Item.Icon = 1821
Item.baseDamage = 20
Item.type = "weapon"
Item.attackSpeed = 1.3
Item.attackRange = 90
Item.weight = 10
Item.attribute = "strength"
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