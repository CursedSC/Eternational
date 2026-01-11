local Item = {}
Item.Name = "Зелье новичка"
Item.Description = "Зелье, по-видимому созданое каким-то новичком. Лучше это не использовать."
Item.Icon = 1448
Item.stackable = false
Item.weight = 0.6
Item.typeWorld = "quest"
function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item
