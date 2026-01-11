local Item = {}
Item.Name = "Доспехи"
Item.Model = "models/cloudteam/fantasy/custom/avallon_male.mdl"
Item.Description = "Обычные мужские доспехи."
Item.Icon = 2006
Item.type = "armor"
Item.Stats = {}
Item.Stats["armor"] = 10

function Item:GetDescription(arguments)
    return {color_white, self.Description}
end

function Item:CanEquip(inventory, item)
    local owner = inventory.owner
    return true, "Вы надели доспехи."
end

function Item:OnEquip(inventory, item)
    if not IsValid(inventory.owner) then return end
    local itemData = item:getItemData()
    item:setMeta("playerModel", inventory.owner:GetModel())
    inventory.owner:SetModel(self.Model)
end

function Item:OnUnEquip(inventory, item)
    if not IsValid(inventory.owner) then return end
    local oldModel = item:getMeta("playerModel") or Fantasy.BasicModel
    inventory.owner:SetModel(oldModel)
end

return Item 