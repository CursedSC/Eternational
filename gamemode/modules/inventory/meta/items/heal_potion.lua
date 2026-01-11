local Item = {}
Item.Name = "Зелье Моментального Исцеления"
Item.Description = "Обычное дерево."
Item.Icon = 1544
Item.stackable = false
Item.type = "potion"
function Item:OnUse(inventory, item)
    if not IsValid(inventory.owner) then return end
    local itemData = item:getItemData()
    inventory.owner:SetHealth(math.Clamp(inventory.owner:Health() + 25, 0, inventory.owner:GetMaxHealth()))
end

function Item:DeleteOnUse(inventory, item)
    return true
end

function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item 