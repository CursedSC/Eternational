local Item = {}
Item.Name = "Меч новичка"
Item.Description = "Меч, по-видимому созданый каким-то новичком. Не годен к использованию в битвах."
Item.Icon = 88
Item.stackable = false
Item.weight = 3
Item.typeWorld = "quest"
function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item
