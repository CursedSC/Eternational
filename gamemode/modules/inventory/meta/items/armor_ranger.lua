local Item = {}
Item.Name = "Накидка разветчика"
Item.Models = {["Мужчина"] = "models/cloudteam/fantasy/custom/archers_male.mdl", ["Женщина"] = "models/cloudteam/fantasy/custom/archers_female.mdl"}
Item.Description = "Обычные мужские доспехи."
Item.Icon = 1972
Item.type = "armor"
Item.Stats = {}
Item.Stats["speed"] = 5


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
    local playerGender = inventory.owner:GetGender()
    local model = self.Models[playerGender] or self.Models["Мужчина"]
    item:setMeta("playerModel", inventory.owner:GetModel())
    inventory.owner:SetModel(model)
end

function Item:OnUnEquip(inventory, item)
    if not IsValid(inventory.owner) then return end
    local oldModel = item:getMeta("playerModel") or Fantasy.BasicModel
    inventory.owner:SetModel(oldModel)
end

return Item 