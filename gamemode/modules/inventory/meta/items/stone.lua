local Item = {}
Item.Name = "Камень"
Item.Description = "Обычное камень."
Item.Icon = 1761
Item.stackable = true
function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item 