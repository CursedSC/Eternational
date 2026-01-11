local Item = {}
Item.Name = "Книга навыка"
Item.Description = "ф"
Item.Icon = 1448
Item.stackable = false
Item.type = "skillbook"
Item.notShow = true
function Item:OnUse(inventory, item)
    inventory.owner:AddKnowSkill(self.skill)
    inventory.owner:SyncData()
end

function Item:DeleteOnUse(inventory, item)
    return true
end

function Item:GetDescription(arguments)
    return {color_white, "Книга навыков позволяющаяя изучить навык ", Color(181, 88, 89), " "..skillList[self.skill].Name}
end


return Item 