local Item = {}
Item.Name = "Зелье Моментальной Маны"
Item.Description = "Обычное дерево."
Item.Icon = 1448
Item.stackable = false
Item.type = "potion"
function Item:OnUse(inventory, item)
    if not IsValid(inventory.owner) then return end
    local itemData = item:getItemData()
    inventory.owner:SetMana(math.Clamp(inventory.owner:GetMana() + 25, 0, inventory.owner:GetMaxMana()))
end

function Item:DeleteOnUse(inventory, item)
    return true
end

function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item 